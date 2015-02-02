package onyx.core {
	
	import onyx.core.*;
	import onyx.plugin.*;
	
	/**
	 * 	@public
	 */
	public interface IPluginModule extends IPlugin {

		/**
		 * 	@public
		 * 	Initializes the modules
		 */
		function initialize():PluginStatus;
		
		/**
		 * 	@public
		 */
		function getUserInterface():Class;
		
		/**
		 * 	@public
		 * 	Stars the module
		 */
		function start():void;
		
		/**
		 * 	@public
		 * 	Stops the module
		 */
		function stop():void;
	}
}