package onyx.host.swf {
	
	import flash.events.*;
	
	import onyx.core.*;
	import onyx.display.Color;
	
	use namespace parameter;
	
	final public class PluginSWFParameterColorUInt extends PluginSWFParameter {
		
		/**
		 * 	@public
		 */
		override public function serialize(options:uint = 0xFFFFFFFF):Object {
			return "0x" + value.toString(16);
		}
		
		/**
		 * 	@public
		 */
		override public function unserialize(token:*):void {
			if (token is String) {
				var str:String = token as String;
				if (str.charAt(0) === '#') {
					value = uint('0x' + str.substr(1));
				}
			}
			
			value = uint(token);
		}
	}
}