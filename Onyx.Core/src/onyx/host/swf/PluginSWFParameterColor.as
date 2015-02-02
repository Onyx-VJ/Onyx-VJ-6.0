package onyx.host.swf {
	
	import flash.events.*;
	
	import onyx.core.*;
	import onyx.display.Color;
	
	use namespace parameter;
	
	final public class PluginSWFParameterColor extends PluginSWFParameter {
		
		/**
		 * 	@public
		 */
		override public function serialize(options:uint = 0xFFFFFFFF):Object {
			const color:Color	= this.value;
			return "0x" + color.toNumber().toString(16);
		}
		
		/**
		 * 	@public
		 */
		override public function set value(unsigned_int:*):void {
			
			var color:Color	= target[property] as Color;
			color.fromInt(unsigned_int);
			
			super.value		= color;
		}
		
		/**
		 * 	@public
		 */
		override public function get value():* {
			return (target[property] as Color).toNumber(true);
		}
		
		/**
		 * 	@public
		 */
		override public function unserialize(token:*):void {
			this.value = uint(token);
		}
	}
}