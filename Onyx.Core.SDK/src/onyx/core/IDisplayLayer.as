package onyx.core {
	
	import onyx.display.*;
	import onyx.parameter.*;
	
	[Compiler(Link)]
	
	public interface IDisplayLayer extends IDisplayChannel {
		
		/**
		 * 	@public
		 * 	Load
		 */
		function load(reference:IFileReference, token:Object):void;
		
		/**
		 * 	@public
		 */
		function setGenerator(instance:IPluginGenerator, file:IFileReference, content:Object):Boolean;
		
		/**
		 * 	@public
		 */
		function getGenerator():IPluginGenerator; 
		
		/**
		 * 	@public
		 * 	Unload the generator, and destroyed the filters
		 */
		function unload(clear:Boolean = true):void;
		
		/**
		 * 	@public
		 * 	Returns the index of the layer within the display
		 */
		function get index():int;
		
		/**
		 * 	@public
		 */
		function set time(value:Number):void;
		
		/**
		 * 	@public
		 */
		function get time():Number;
		
		/**
		 * 	@public
		 */
		function getTimeInfo():LayerTime;
		
		/**
		 * 	@public
		 */
		function get path():String;
		
		/**
		 * 	@public
		 */
		function get parent():IDisplay;
		
		/**
		 * 	@public
		 */
		function isVisible():Boolean;
		
		/**
		 * 	@public
		 */
		function draw():Boolean;

	}
}