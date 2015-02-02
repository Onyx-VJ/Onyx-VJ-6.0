package tests {
	
	import core.*;
	
	import flash.display.*;
	import flash.display3D.Context3DTextureFormat;
	import flash.events.*;
	import flash.filters.*;
	import flash.geom.*;
	
	final public class LexTests {
		
		private static const ITERATIONS:int	= 5000000;
		
		public static function getTests():Array {
			return [
				new TestRunner('Named',			ITERATIONS, named),
				new TestRunner('PreDef',		ITERATIONS, predef)
			];
		}
		
		private static function named():void {
			var str:String = Context3DTextureFormat.BGRA;
		}
		
		private static function predef():void {
			var str:String = GPU::TEXTURE_BGRA;
		}
		
	}
}