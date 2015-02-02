package onyx.display {
	
	import flash.geom.*;
	
	import onyx.core.*;
	import onyx.event.*;
	import onyx.plugin.*;
	
	final public class DisplayLayerRenderModeMixed implements ILayerRenderMode {
		
		/**
		 * 	@private
		 */
		private var channelCPU:ChannelCPU;
		
		/**
		 * 	@private
		 */
		private var channelGPU:ChannelGPU;
		
		/**
		 * 	@private
		 */
		private var blend:IPluginBlendCPU;
		
		/**
		 * 	@private
		 */
		private var generator:IPluginGeneratorCPU;
		
		/**
		 * 	@private
		 */
		private var contextCPU:DisplayContextCPU;
		
		/**
		 * 	@private
		 */
		private var owner:IDisplayLayer;
		
		/**
		 * 	@public
		 */
		public function initialize(owner:IDisplayLayer, contextCPU:IDisplayContextCPU, generator:IPluginGeneratorCPU, file:IFileReference, content:Object):Boolean {
			
			this.owner					= owner;
			this.contextCPU				= contextCPU as DisplayContextCPU;
			
			this.channelCPU				= Onyx.CreateInstance('Onyx.Display.Channel::CPU') as ChannelCPU;
			this.channelCPU._name		= owner.name + ': CPU';
			this.channelCPU.initializeCPU(owner, contextCPU, true, 0x00);
			
			this.generator	= generator;
			this.generator.initialize(contextCPU, channelCPU, file, content);
			
			this.blend		= Onyx.CreateInstance('Onyx.Display.Blend.Normal::CPU') as IPluginBlendCPU;
			this.blend.initialize(contextCPU);
			
			// return true
			return true;
		}
		
		/**
		 * 	@public
		 */
		public function updateChannelName():void {
			this.channelCPU._name	= owner.name + ': CPU';
			this.channelGPU._name	= owner.name + ': GPU';
		}
		
		/**
		 * 	@public
		 */
		public function setBlendMode(value:IPlugin):Boolean {

			var newBlend:IPluginBlendCPU = value as IPluginBlendCPU;
			if (newBlend && newBlend.initialize(contextCPU) === PluginStatus.OK) {
				blend = value as IPluginBlendCPU;
				return true;
			}
			
			return false;
		}
		
		/**
		 * 	@public
		 */
		public function getGenerator():IPluginGenerator {
			return generator;
		}
		
		/**
		 * 	@public
		 */
		public function getChannel():IChannel {
			return channelGPU;
		}
		
		/**
		 * 	@public
		 */
		public function update(time:Number):Boolean {
			return generator.update(time);
		}
		
		/**
		 * 	@public
		 */
		public function getTotalTime():int {
			return generator.getTotalTime();
		}
		
		/**
		 * 	@public
		 */
		public function render():Boolean {
			
			// revalidate
			generator.checkValidation();
			
			// bind channel
			contextCPU.bindChannel(channelCPU);
			generator.render(contextCPU);
			contextCPU.swapBuffer();
			
			for each (var filter:IPluginFilterCPU in channelCPU.filters) {
				
				// check validation
				filter.checkValidation();
				
				// render and swap?
				if (filter.render(contextCPU)) {
					contextCPU.swapBuffer();
				}
			}
			
			// unbind
			contextCPU.unbind();
			
			// dispatch a render! 
			channelCPU.dispatchEvent(new OnyxEvent(OnyxEvent.CHANNEL_RENDER_CPU, channelCPU));
			
			// true!
			return true;
		}
		
		/**
		 *	@public
		 */
		public function clearFilters():void {
			channelCPU.clearFilters();
			channelGPU.clearFilters();
		}
		
		/**
		 * 	@public
		 */
		public function draw(transform:ColorTransform):Boolean {
			//return blend.render(contextCPU.target, contextCPU.surface, channel.internalSurface, transform, null, null);
			return false;
		}

		/**
		 * 	@public
		 */
		public function getBlendMode():IPlugin {
			return blend;
		}
		
		/**
		 * 	@public
		 */
		public function dispose():void {
			generator.dispose();
			blend.dispose();
			channelCPU.dispose();
		}
		
		/**
		 * 	@public
		 */
		public function get type():uint {
			return Plugin.CPU;
		}
		
		/**
		 * 	@public
		 */
		public function serialize(options:uint = 0xFFFFFFFF):Object {
			
			if (!this.generator) {
				return null;
			}
			const data:Object	= {};
			data.generator		= generator.serialize(options);
			data.blend			= blend.serialize(options);
			data.channelCPU		= channelCPU.serialize(options);
			
			return data;
		}
		
		/**
		 * 	@public
		 */
		public function unserialize(token:Object):void {
			generator.unserialize(token.generator);
		}
	}
}