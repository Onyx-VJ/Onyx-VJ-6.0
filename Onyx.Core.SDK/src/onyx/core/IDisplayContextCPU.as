package onyx.core {
	
	import flash.display.*;
	import flash.events.*;
	import flash.filters.*;
	import flash.geom.*;
	import flash.utils.*;
	
	import onyx.core.*;
	import onyx.display.*;
	import onyx.geom.*;
	import onyx.parameter.*;
	import onyx.plugin.*;
	
	public interface IDisplayContextCPU extends IDisplayContext {
		
		/**
		 * 	@public
		 */
		function clear(color:uint = 0x00):void;
		
		/**
		 * 	@public
		 */
		function get rect():Rect;
		
		/**
		 * 	@public
		 */
		function draw(drawable:IBitmapDrawable, matrix:Matrix = null, transform:ColorTransform = null, blendMode:String = null, clipRect:Rectangle = null, smoothing:Boolean = true, quality:String = null):void;
		
		/**
		 * 	@public
		 */
		function copyPixels(source:BitmapData, merge:Boolean = false, rect:Rectangle = null, position:Point = null, alphaBitmap:BitmapData = null, alphaPoint:Point = null):void;
		
		/**
		 * 	@public
		 */
		function applyFilter(filter:BitmapFilter, source:BitmapData = null, rect:Rectangle = null, position:Point = null):void;
		
		/**
		 * 	@public
		 */
		function paletteMap(red:Array = null, green:Array = null, blue:Array = null, alpha:Array = null, source:BitmapData = null, rect:Rectangle = null, point:Point = null):void;
		
		/**
		 * 	@public
		 */
		function bindChannel(channel:IChannelCPU):void;
		
		/**
		 * 	@public
		 */
		function swapBuffer():void;
		
		/**
		 * 	@public
		 */
		function get surface():DisplaySurface;
		
		/**
		 * 	@public
		 */
		function get target():DisplaySurface;
		
		/**
		 * 	@public
		 */
		function getTempSurface(alpha:Boolean):DisplaySurface;
		
		/**
		 * 	@public
		 */
		function requestSurface(transparent:Boolean):DisplaySurface;
		
		/**
		 * 	@public
		 */
		function releaseSurface(surface:DisplaySurface):void;
		
	}
}