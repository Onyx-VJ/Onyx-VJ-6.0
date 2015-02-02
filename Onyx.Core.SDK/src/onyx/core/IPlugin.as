package onyx.core {
	
	import flash.events.*;
	import flash.geom.*;
	
	import onyx.core.*;
	import onyx.display.*;
	import onyx.parameter.*;
	
	[Compiler(Link)]

	public interface IPlugin extends IDisposable, ISerializable, IEventDispatcher {

		/**
		 * 	@public
		 */
		function get id():String;
		
		/**
		 * 	@public
		 */
		function get name():String;
		
		/**
		 * 	@public
		 */
		function get plugin():IPluginDefinition;
		
		/**
		 * 	@public
		 * 	Returns list of parameters
		 */
		function getParameters():ParameterList;
		
		/**
		 * 	@public
		 */
		function getParameter(id:String):IParameter;
		
		/**
		 * 	@public
		 * 	Returns a value from a parameter
		 */
		function getParameterValue(name:String):*;
		
		/**
		 * 	@public
		 */
		function hasParameter(name:String):Boolean;
		
		/**
		 * 	@public
		 * 	Sets a value to a parameter
		 */
		function setParameterValue(name:String, value:*):void;

		/**
		 * 	@public
		 */
		function checkValidation():void;

	}
}