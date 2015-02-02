package onyx.logging {
	
	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	import flash.system.*;
	import flash.utils.*;
	
	import onyx.*;
	import onyx.core.*;
	import onyx.display.*;
	import onyx.plugin.*;
	import onyx.util.*;
	
	use namespace parameter;
	
	[PluginInfo(
		id			= 'Onyx.Logging.SystemProfile',
		name		= 'Onyx.Logging.SystemProfile',
		version		= '1.0',
		vendor		= 'Daniel Hai',
		description	= 'Basic System Profile'
	)]
	
	/**
	 * 	@public
	 */
	final public class SystemProfile extends PluginModule implements IPluginModule {
		
		/**
		 * 	@public
		 * 	Initializes the modules
		 */
		public function initialize():PluginStatus {
			return PluginStatus.OK;
		}
		
		/**
		 * 	@public
		 * 	Stars the module
		 */
		public function start():void {
			
			var capabilities:XML = describeType(Capabilities);
			for each (var accessor:XML in capabilities.accessor) {
				Console.Log(CONSOLE::INFO, accessor.@name, '\t', Capabilities[String(accessor.@name)]);
			}
			
		}
		
		/**
		 * 	@public
		 * 	Stops the module
		 */
		public function stop():void {}
		
		/**
		 * 	@public
		 */
		public function get priority():int {
			return 0;
		}
	}
}