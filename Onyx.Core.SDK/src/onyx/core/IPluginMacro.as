package onyx.core {
	
	import onyx.core.*;
	import onyx.plugin.PluginStatus;
	
	/**
	 * 	This interface defines a keyboard shortcut.
	 * 
	 * 	initialize	= keydown
	 * 	dispose		= keyup
	 */
	public interface IPluginMacro extends IPlugin {
		
		/**
		 * 	@public
		 */
		function initialize(context:Object):PluginStatus;
		
		/**
		 * 	@public
		 */
		function repeat():void; 
		
	}
}