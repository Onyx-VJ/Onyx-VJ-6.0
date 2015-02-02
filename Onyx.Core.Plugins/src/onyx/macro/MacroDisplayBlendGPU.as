package onyx.macro {
	
	import onyx.core.*;
	import onyx.display.*;
	import onyx.event.*;
	import onyx.plugin.*;
	import onyx.util.encoding.*;
	import onyx.util.tween.*;
	
	use namespace parameter;
	
	[PluginInfo(
		id			= 'Onyx.Macro.DisplayBlendGPU',
		name		= 'Onyx.Macro.DisplayBlendGPU',
		version		= '1.0',
		vendor		= 'Daniel Hai',
		description = 'DisplayBlendGPU'
	)]
	
	public final class MacroDisplayBlendGPU extends PluginBase implements IPluginMacro {
		
		/**
		 * 	@private
		 */
		private var context:IDisplayContextGPU;
		
		/**
		 * 	@private
		 */
		private var channel:IChannelGPU;
		
		/**
		 * 	@private
		 */
		private var texture:DisplayTexture;
		
		/**
		 * 	@private
		 */
		private var target:DisplayTexture;
		
		/**
		 * 	@private
		 */
		private var blend:IPluginBlendGPU;
		
		/**
		 * 	@private
		 */
		private var first:Boolean = true;
		
		/**
		 * 	@public
		 */
		public function initialize(data:Object):PluginStatus {
			
			var display:IDisplay = Onyx.GetDisplay(0);
			if (!display) {
				return new PluginStatus('Error, no display');
			}
			
			blend			= Onyx.CreateInstance(String(data)) as IPluginBlendGPU;
			if (!blend) {
				return new PluginStatus('invalid blend mode:' + String(data));
			}
			
			// ok now we need to start buffering
			for each (var channel:IChannel in display.getChannels()) {
				if (channel is IChannelGPU) {
					break;
				}
			}
			
			if (!channel) {
				return new PluginStatus('not gpu context');
			}
			
			// create the textures
			context = display.getContext(Plugin.GPU) as IDisplayContextGPU;
			if (!context) {
				return new PluginStatus('invalid context');
			}
			
			if (blend.initialize(context) !== PluginStatus.OK) {
				return new PluginStatus('blend error');
			}
			
			this.channel	= channel as IChannelGPU;
			this.texture	= context.requestTexture(context.width, context.height, true);
			this.target		= context.requestTexture(context.width, context.height, true);
			
			// add a listener
			this.channel.addEventListener(OnyxEvent.CHANNEL_RENDER_GPU, handleRender);
			
			// ok?
			return PluginStatus.OK;
		}
		
		/**
		 * 	@private
		 */
		private function handleRender(e:OnyxEvent):void {
			
			if (first) {
				
				// bind
				context.bindTexture(texture);
				context.clear(Color.BLACK);
				context.blit(channel.texture);
				context.unbind();

				// first
				first = false;
				
			} else {
				
				context.bindTexture(target);
				context.clear(Color.BLACK);
				
				// render
				blend.render(texture, channel.texture);
				
				// unbind
				context.unbind();
				
				// swap
				var temp:DisplayTexture = target;
				target		= texture;
				texture		= temp;
				
				// present it
				context.clear(Color.BLACK);
				context.present(texture);
				
				// prevent default
				e.preventDefault();

			}
		}
		
		/**
		 * 	@public
		 */
		public function repeat():void {}
		
		/**
		 * 	@public
		 */
		override public function dispose():void {
			
			if (blend) {
				blend.dispose();
			}
			
			if (context && texture) {
				context.releaseTexture(texture);
				context.releaseTexture(target);
			}

			if (channel) {
				channel.removeEventListener(OnyxEvent.CHANNEL_RENDER_GPU, handleRender);
			}

			// dispose
			super.dispose();
		}
	}
}