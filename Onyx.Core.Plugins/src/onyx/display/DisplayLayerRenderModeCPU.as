package onyx.display {
	
	import flash.geom.*;
	
	import onyx.core.*;
	import onyx.event.*;
	import onyx.plugin.*;
	
	final public class DisplayLayerRenderModeCPU implements ILayerRenderMode {
		
		/**
		 * 	@private
		 */
		private var channel:ChannelCPU;
		
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
		private var context:DisplayContextCPU;
		
		/**
		 * 	@private
		 */
		private var owner:IDisplayLayer;
		
		/**
		 * 	@public
		 */
		public function initialize(owner:IDisplayLayer, context:IDisplayContextCPU, generator:IPluginGeneratorCPU, file:IFileReference, content:Object):Boolean {
			
			this.owner			= owner;
			this.context		= context as DisplayContextCPU;
			
			this.channel		= Onyx.CreateInstance('Onyx.Display.Channel::CPU') as ChannelCPU;
			this.channel._name	= owner.name;
			this.channel.initializeCPU(owner, context, true, 0x00);
			
			this.generator	= generator;
			this.generator.initialize(context, channel, file, content);
			
			this.blend		= Onyx.CreateInstance('Onyx.Display.Blend.Normal::CPU') as IPluginBlendCPU;
			this.blend.initialize(context);
			
			return true;
		
		}
		
		/**
		 * 	@public
		 */
		public function updateChannelName():void {
			this.channel._name	= owner.name;
		}
		
		/**
		 * 	@public
		 */
		public function setBlendMode(value:IPlugin):Boolean {

			var newBlend:IPluginBlendCPU = value as IPluginBlendCPU;
			if (newBlend && newBlend.initialize(context) === PluginStatus.OK) {
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
			return channel;
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
			context.bindChannel(channel);
			
			// render
			generator.render(context);
			
			// swap
			context.swapBuffer();
			
			for each (var filter:IPluginFilterCPU in channel.filters) {
				
				// check validation
				filter.checkValidation();
				
				var value:Boolean =  filter.render(context);
				// render and swap?
				if (value) {
					context.swapBuffer();
				}
			}
			
			// unbind
			context.unbind();
			
			// dispatch a render! 
			channel.dispatchEvent(new OnyxEvent(OnyxEvent.CHANNEL_RENDER_CPU, channel));
			
			// true!
			return true;
		}
		
		/**
		 *	@public
		 */
		public function clearFilters():void {
			channel.clearFilters();
		}
		
		/**
		 * 	@public
		 */
		public function draw(transform:ColorTransform):Boolean {
			return blend.render(context.target, context.surface, channel.internalSurface, transform, null, null);
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
			channel.dispose();
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
			data.channel		= channel.serialize(options);
			
			return data;
		}
		
		/**
		 * 	@public
		 */
		public function unserialize(token:Object):void {
			
			if (token.generator) {
				generator.unserialize(token.generator);
			}
			if (token.channel) {
				channel.unserialize(token.channel);
			}
		}
	}
}