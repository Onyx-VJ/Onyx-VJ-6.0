package onyx.display {
	
	import flash.geom.*;
	
	import onyx.core.*;
	import onyx.event.*;
	import onyx.plugin.*;
	
	final public class DisplayLayerRenderModeGPU implements ILayerRenderMode {
		
		/**
		 * 	@private
		 */
		private var channel:ChannelGPU;
		
		/**
		 * 	@private
		 */
		private var blend:IPluginBlendGPU;
		
		/**
		 * 	@private
		 */
		private var generator:IPluginGeneratorGPU;
		
		/**
		 * 	@private
		 */
		private var context:DisplayContextGPU;
		
		private var owner:IDisplayLayer;
		
		/**
		 * 	@public
		 */
		public function initialize(owner:IDisplayLayer, context:IDisplayContextGPU, generator:IPluginGeneratorGPU, file:IFileReference, content:Object):Boolean {
			
			this.owner			= owner;
			this.context		= context as DisplayContextGPU;
			
			this.channel		= Onyx.CreateInstance('Onyx.Display.Channel::GPU') as ChannelGPU;
			this.channel._name	= owner.name + ': GPU';
			this.channel.initialize(context);
			
			this.generator	= generator;
			this.generator.initialize(context, channel, file, content);
			
			this.blend		= Onyx.CreateInstance('Onyx.Display.Blend.Normal::GPU') as IPluginBlendGPU;
			this.blend.initialize(context);
			
			// return true
			return true;
		}
		
		/**
		 * 	@public
		 */
		public function updateChannelName():void {
			this.channel._name	= owner.name + ': GPU';
		}
		
		/**
		 * 	@public
		 */
		public function setBlendMode(value:IPlugin):Boolean {

			var newBlend:IPluginBlendGPU = value as IPluginBlendGPU;
			if (newBlend && newBlend.initialize(context) === PluginStatus.OK) {
				blend = value as IPluginBlendGPU;
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
			generator.render(context);
			context.swapBuffer();
			
			for each (var filter:IPluginFilterGPU in channel.filters) {
				
				filter.checkValidation();
				
				// render and swap?
				if (filter.render(context)) {
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
		 * 	@public
		 */
		public function draw(transform:ColorTransform):Boolean {
			
			if (blend) {
				blend.render(context.texture, channel.internalTexture, transform);
			} else {
				Console.LogError('No blendmode to render!');
			}
			
			return true;
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
		 *	@public
		 */
		public function clearFilters():void {
			channel.clearFilters();
		}
		
		/**
		 * 	@public
		 */
		public function get type():uint {
			return Plugin.GPU;
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