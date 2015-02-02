package onyx.host.swf {
	
	import flash.utils.Dictionary;
	
	import onyx.core.*;
	import onyx.event.OnyxEvent;
	import onyx.parameter.*;
	import onyx.plugin.*;
	
	final public class PluginSWFParameterChannel extends PluginSWFParameter implements IParameterIterator {
		
		/**
		 * 	@public
		 */
		public static function FORMAT_CHANNEL(channel:IDisplayChannel):String {
			return channel ? channel.name : 'none';
		}
		
		/**
		 * 	@private
		 */
		private var allowNull:Boolean = true;
		
		/**
		 * 	@private
		 */
		private var channelType:uint;
		
		/**
		 * 	@private
		 */
		private var ignore:Dictionary	= new Dictionary(true);
		
		/**
		 * 	@public
		 */
		public function PluginSWFParameterChannel(type:uint):void {
			this.channelType	= type;
		}
		
		/**
		 *	@internal
		 */
		override public function initialize(target:Object, property:String, parameterType:String, definition:PluginSWFDefinition):void {
			
			if (!definition.formatFunction) {
				definition.formatFunction = FORMAT_CHANNEL;
			}
			
			// init!
			super.initialize(target, property, parameterType, definition);
			
		}
		
		
		/**
		 * 	@public
		 */
		public function format(value:*):String {
			return value ? value.name : 'none';
		}

		/**
		 * 	@public
		 */
		public function get currentIndex():int {
			return iterator.indexOf(value);
		}
		
		/**
		 * 	@public
		 */
		public function get iterator():* {
			
			var channels:* = Onyx.GetChannels(channelType).concat();
			if (!channels) {
				return;
			}
			
			if (allowNull) {
				channels.unshift(null);
			}
			
			return channels; 
		}
		
		override public function unserialize(token:*):void {
			
			CONFIG::DEBUG {
				Console.Log(CONSOLE::DEBUG, 'unserilaize channel:', token);
			}

			if (token) {
				
				var name:String = String(token);
				var channels:*	= Onyx.GetChannels(channelType);
				for each (var channel:IChannel in channels) {
					if (channel.name === name) {
						value = channel;
						return;
					}
				} 
			}
		}
		
		override public function serialize(options:uint = 0xFFFFFFFF):Object {
			var channel:IChannel = value;
			return channel ? channel.name : null; 
		}
		
		/**
		 * 	@public
		 */
		override public function dispose():void {
			
			// dispose
			super.dispose();
			
		}
	}
}