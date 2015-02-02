package tests {
	
	import core.*;
	
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.events.*;
	import flash.filters.BitmapFilter;
	import flash.filters.ColorMatrixFilter;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import spark.primitives.Rect;
	
	import tests.reflect.*;
	
	final public class ReflectionTest {
		
		private static const ITERATIONS:int	= 10000;
		
		public static function getTests():Array {
			return [
				new TestRunner('reflect',	ITERATIONS, reflect),
				new TestRunner('getter',	ITERATIONS, getter),
				new TestRunner('reflect1',	ITERATIONS, reflect1),
				new TestRunner('getter1',	ITERATIONS, getter1)
			];
		}
		
		private static const obj:TestInterface = new TestClass();
		private static const channels:Array		= [];
		
		private static function reflect():void {
			var a:TestInterfaceA = obj as TestInterfaceA;
			if (a) {
				a.blah();
			}
		}
		
		private static function getter():void {
			switch (obj.type) {
				case 0:
					(obj as TestInterfaceA).blah();
					break;
			}
		}
		
		private static function reflect1():void {
			if (obj is TestInterfaceA) {
				channels[0] = obj;
			}
		}
		
		private static function getter1():void {
			channels[obj.type] = obj;
		}
	}
}