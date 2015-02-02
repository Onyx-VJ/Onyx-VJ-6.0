package onyx.host.swf {
	
	import onyx.core.*;
	import onyx.parameter.*;
	import onyx.plugin.*;
	
	use namespace parameter;
	
	public final class PluginSWFParameterFunction extends PluginSWFParameter implements IParameterExecutable {

		/**
		 * 	@public
		 */
		public function execute():void {
			target[property]();
		}
		
		/**
		 * 	@public
		 */
		override public function set value(v:*):void {
			// don't do anything
		};
		
		/**
		 * 	@public
		 */
		override public function get value():* {
			return undefined;
		}
	}
}