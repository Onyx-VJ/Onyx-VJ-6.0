package onyx.macro {
	
	import flash.events.Event;
	import flash.geom.Matrix;
	
	import onyx.core.*;
	import onyx.display.Color;
	import onyx.display.DisplayContextGPU;
	import onyx.display.DisplayTexture;
	import onyx.event.OnyxEvent;
	import onyx.plugin.*;
	import onyx.util.encoding.*;
	import onyx.util.tween.*;
	
	use namespace parameter;
	
	[PluginInfo(
		id			= 'Onyx.Macro.DisplayBufferGPU',
		name		= 'Onyx.Macro.DisplayBufferGPU',
		version		= '1.0',
		vendor		= 'Daniel Hai',
		description = 'DisplayBufferGPU'
	)]
	
	public final class MacroDisplayBufferGPU extends PluginBase implements IPluginMacro {
		
		/**
		 * 	@private
		 */
		private const textures:Vector.<DisplayTexture>	= new Vector.<DisplayTexture>(4, true);
		
		/**
		 * 	@private
		 */
		private var index:int;
		
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
		private var recording:Boolean	= true;
		
		/**
		 * 	@public
		 */
		public function initialize(data:Object):PluginStatus {
			
			var display:IDisplay = Onyx.GetDisplay(0);
			if (!display) {
				return new PluginStatus('Error, no display');
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
			
			this.channel	= channel as IChannelGPU;
			this.channel.addEventListener(OnyxEvent.CHANNEL_RENDER_GPU, handleRender);
			
			return PluginStatus.OK;
		}
		
		/**
		 * 	@private
		 */
		private function handleRender(e:OnyxEvent):void {
			
			if (recording) {
				
				var texture:DisplayTexture = textures[index++] = context.requestTexture(context.width, context.height, true);
				context.bindTexture(texture);
				context.clear(Color.BLACK);
				context.blit(channel.texture);
				context.unbind();
				
				if (index === textures.length) {
					recording = false;
				}
				
			} else {
				
				
				
				// texture?
				index = (index + 1) % textures.length;
				
				// prevent default
				e.preventDefault();
				
				// present -- background color comes from the surface
				context.clear(Color.BLACK);
				
				// present
				context.present(textures[index]);
			}
		}
		
		/**
		 * 	@public
		 */
		public function repeat():void {}
		
		override public function dispose():void {
			
			if (context) {
				for each (var texture:DisplayTexture in textures) {
					context.releaseTexture(texture);
				}
			}

			if (channel) {
				channel.removeEventListener(OnyxEvent.CHANNEL_RENDER_GPU, handleRender);
			}

			// dispose
			super.dispose();
		}
	}
}