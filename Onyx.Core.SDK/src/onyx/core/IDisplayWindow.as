package onyx.core {
	
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	
	import onyx.plugin.*;
	
	[Compiler(Link)]
	
	public interface IDisplayWindow extends IEventDispatcher {
		
		/**
		 * 	@public
		 */
		function get stage():Stage;
		
		function set title(value:String):void;
		function get title():String;
		
		/**
		 * 	@public
		 */
		function close():void;
		
		/**
		 * 	@public
		 */
		function get bounds():Rectangle;
		
		/**
		 * 	@public
		 */
		function set bounds(rect:Rectangle):void;

		/**
		 * 	@public
		 */
		function activate():void;
		
		/**
		 * 	@public
		 */
		function set alwaysInFront(value:Boolean):void;
		
		/**
		 * 	@public
		 */
		function get alwaysInFront():Boolean;
		
		/**
		 * 	@public
		 */
		function set fullScreen(value:Boolean):void;
		
		/**
		 * 	@public
		 */
		function get fullScreen():Boolean;
		
		/**
		 * 	@public
		 */
		function get visible():Boolean;
		
	}
}