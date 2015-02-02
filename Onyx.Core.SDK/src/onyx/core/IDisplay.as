package onyx.core {
	
	import flash.display.*;
	import flash.geom.*;
	
	import onyx.plugin.*;
	import onyx.util.*;
	
	[Event(name='mouse_enter',	type='onyx.event.InteractionEvent')]
	[Event(name='mouse_leave',	type='onyx.event.InteractionEvent')]
	[Event(name='mouse_move',	type='onyx.event.InteractionEvent')]

	public interface IDisplay extends IDisplayChannel, ISerializable {
		
		/**
		 * 	@public
		 */
		function getStage():Stage;
		
		/**
		 * 	@public
		 */
		function getContext(type:uint = 0x00):IDisplayContext;
		
		/**
		 * 	@public
		 */
		function initialize(window:IDisplayWindow, x:int, y:int, width:int, height:int):PluginStatus;
		
		/**
		 * 	@public
		 */
		function createLayer():IDisplayLayer;
		
		/**
		 * 	@public
		 */
		function getLayers():Vector.<IDisplayLayer>;
		
		/**
		 * 	@public
		 */
		function getLayer(index:int):IDisplayLayer;
		
		/**
		 * 	@public
		 */
		function getLayerIndex(layer:IDisplayLayer):int;
		
		/**
		 * 	@public
		 */
		function pause(value:Boolean):void;
		
		/**
		 * 	@public
		 */
		function swapLayers(a:IDisplayLayer, b:IDisplayLayer):void;
		
		/**
		 * 	@public
		 */
		function render():Boolean;
		
		/**
		 * 	@public
		 */
		function show():void;
		
		/**
		 * 	@public
		 */
		function start():void;
		
		/**
		 *	@public
		 */
		function getWindow():IDisplayWindow;
		
		/**
		 * 	@public
		 */
		function get index():int;
		
		/**
		 * 	@public
		 */
		function drawThumbnail(width:int, height:int):BitmapData;
		
		/**
		 * 	@public
		 */
		function get width():int;
		
		/**
		 * 	@public
		 */
		function get height():int;
		
	}
}