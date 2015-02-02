package onyx.display {

	import onyx.core.*;
	import onyx.event.*;
	import onyx.plugin.*;
	
	public class DisplayChannelBase extends PluginBase {
		
		/**
		 * 	@protected
		 */
		private const channels:Vector.<IChannel>	= new Vector.<IChannel>();
		
		/**
		 * 	@public
		 */
		protected function addChannel(channel:IChannel):void {
			
			// push the channel
			channels.push(channel);
			
			// register
			Onyx.RegisterChannel(channel);
			
			CONFIG::DEBUG {
				Console.Log(CONSOLE::DEBUG, 'adding channel:', channel.name);
			}

			// add
			dispatchEvent(new OnyxEvent(OnyxEvent.CHANNEL_CREATE, channel));
			
		}
		
		/**
		 * 	@public
		 */
		protected function removeChannel(channel:IChannel):void {
			
			// remove channel
			channels.splice(channels.indexOf(channel), 1);
			
			// register
			Onyx.UnRegisterChannel(channel);
			
			// dest
			dispatchEvent(new OnyxEvent(OnyxEvent.CHANNEL_DESTROY, channel));
		}
		
		/**
		 * 	@public
		 */
		public function getChannels():Vector.<IChannel> {
			return channels;
		}
		
		/**
		 * 	@public
		 */
		override public function dispose():void {
			
			// kill
			channels.length = 0;
			
			super.dispose();
		}

	}
}