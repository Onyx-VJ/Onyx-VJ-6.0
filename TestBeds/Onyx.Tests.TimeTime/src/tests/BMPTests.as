package tests {
	
	import core.*;
	
	import flash.display.*;
	import flash.events.*;
	import flash.filters.*;
	import flash.geom.*;
	
	final public class BMPTests {
		
		private static const ITERATIONS:int	= 50;
		public static const TEST:String		= 'asdf';
		
		public static function getTests():Array {
			return [
//				new TestRunner('draw other',	ITERATIONS, buffer),
//				new TestRunner('draw self',		ITERATIONS, buffer2),
//				new TestRunner('filter other',	ITERATIONS, drawFilterOther),
//				new TestRunner('filter self',	ITERATIONS, drawFilterSelf),
//				new TestRunner('copy other',	ITERATIONS, copyOther),
//				new TestRunner('copy other2',	ITERATIONS, copyOther2),
//				new TestRunner('copy other3',	ITERATIONS, copyOther3),
//				new TestRunner('copy self',		ITERATIONS, copySelf),
//				new TestRunner('copy twice',	ITERATIONS, copyTwice),
//				new TestRunner('clone',			ITERATIONS, clone),
				new TestRunner('blendAlpha',	ITERATIONS, blendAlpha),
				new TestRunner('blendPre',		ITERATIONS, blendPre),
				new TestRunner('blendMix',		ITERATIONS, blendMix),
			];
		}
		
		private static var bmp:BitmapData		= new BitmapData(960,640,true,0x00);
		private static var bmp2:BitmapData		= bmp.clone();
		private static var b1:BitmapData		= new BitmapData(960,640,false,0x00);
		private static var b2:BitmapData		= bmp.clone();
		private static var filter:BitmapFilter	= new ColorMatrixFilter();
		private static var point:Point			= new Point();
		private static var transform:ColorTransform	= new ColorTransform(1,1,1,0.8);
		private static var matrix:Matrix		= new Matrix(2,0,0,2,5,5);
		private static var RECT:Rectangle		= bmp.rect;
		
		private static function buffer():void {
			bmp.draw(b1, matrix, transform, BlendMode.LIGHTEN);
		}
		
		private static function buffer2():void {
			bmp.draw(bmp, matrix, transform, BlendMode.LIGHTEN);
		}
		
		private static function drawFilterOther():void {
			bmp.applyFilter(b1, b1.rect, point, filter);
		}
		
		private static function drawFilterSelf():void {
			bmp.applyFilter(bmp, bmp.rect, point, filter);
		}
		
		private static function copySelf():void {
			bmp.copyPixels(bmp, bmp.rect, point);
		}
		
		private static function copyOther():void {
			bmp.copyPixels(b1, b1.rect, point);
		}
		
		private static function copyOther2(rect:Rectangle = null, p2:Point = null):void {
			bmp.copyPixels(b1, rect || RECT, p2 || point);
		}
		
		private static function copyOther3():void {
			bmp.copyPixels(b1, RECT, point);
		}
		
		private static function copyTwice():void {
			b1.copyPixels(bmp, bmp.rect, point);
			bmp.copyPixels(b1, b1.rect, point);
		}
		
		private static function clone():void {
			bmp.clone();
		}
		
		private static function blendAlpha():void {
			bmp.draw(bmp2, null, null, BlendMode.LIGHTEN);
		}
		
		private static function blendPre():void {
			b1.draw(b2, null, null, BlendMode.LIGHTEN);	
		}
		
		private static function blendMix():void {
			b1.draw(bmp2, null, null, BlendMode.LIGHTEN);	
		}
	}
}