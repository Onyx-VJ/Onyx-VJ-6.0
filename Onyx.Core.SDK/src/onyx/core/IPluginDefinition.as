package onyx.core {
	
	import flash.display.*;
	
	import onyx.core.*;
	import onyx.display.*;
	import onyx.plugin.*;
	
	[Compiler(Link)]
	
	public interface IPluginDefinition extends ISerializable, IPluginFactory {

		/**
		 * 	@public
		 * 	Same as
		 */
		function get id():String;

		/**
		 * 	@public
		 * 	Returns metadata about the plugin
		 */
		function get info():Object;
		
		/**
		 * 	@public
		 */
		function get dependencies():String;
		
		/**
		 * 	@public
		 */
		function get type():uint;
		
		/**
		 * 	@public
		 */
		function get name():String;
		
		/**
		 * 	@public
		 */
		function get icon():DisplayObject;
		
		/**
		 * 	@public
		 */
		function get enabled():Boolean;
		
	}
}