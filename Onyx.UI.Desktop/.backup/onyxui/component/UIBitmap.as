package onyxui.core {
	
	import flash.display.*;
	import flash.geom.*;
	import flash.text.*;
	
	import onyx.core.*;
	import onyx.display.*;
	
	final public class UIBitmap extends UIObject  {
		
		/**
		 * 	@private
		 */
		private const bitmap:Bitmap		= addChild(new Bitmap()) as Bitmap;
		private const bounds:Rectangle	= new Rectangle();
		
		/**
		 * 	@public
		 */
		public function attach(surface:DisplaySurface):void {
			
			if (!surface) {
				return;
			}
			
			
			bitmap.bitmapData	= surface.nativeSurface;
			bitmap.width		= bounds.width;
			bitmap.height		= bounds.height;
			trace(bounds, surface.rect, bitmap.transform.matrix);
			
		}
		
		/**
		 *	@public 
		 */
		override public function resize(width:int, height:int):void {
			
			bounds.width	= width;
			bounds.height	= height;
			
			if (bitmap.bitmapData) {
				bitmap.width	= width
				bitmap.height	= height;
			}
		}
	}
}