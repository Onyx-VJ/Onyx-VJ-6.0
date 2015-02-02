package onyx.host.swf {
	
	import flash.events.*;
	
	import onyx.core.*;
	import onyx.display.Color;
	
	use namespace parameter;
	
	final public class PluginSWFParameterString extends PluginSWFParameter {
		
		/**
		 * 	@public
		 */
		override public function serialize(options:uint = 0xFFFFFFFF):Object {
			return this.value;
		}
		
		/**
		 * 	@public
		 */
		override public function unserialize(token:*):void {
			this.value = String(token);
		}
	}
}