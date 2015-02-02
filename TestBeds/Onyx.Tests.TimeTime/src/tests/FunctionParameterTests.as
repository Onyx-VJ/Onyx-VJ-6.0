package tests {
	
	import core.*;
	
	import flash.events.*;

	public final class FunctionParameterTests {
		
		private static const INTERATIONS:int	= 500000;
		
		public static function getTests():Array {
			return [
				new TestRunner('Array',		INTERATIONS, arrayArgs),
				new TestRunner('Event', 	INTERATIONS, eventArgs),
				new TestRunner('Object',	INTERATIONS, objArgs),
				new TestRunner('Star',		INTERATIONS, starArgs)
			];
		}

		/**
		 * 	@private
		 */
		private static function arrayArgs(... args:Array):void {}
		
		/**
		 * 	@private
		 */
		public static function objArgs(arg:Object = null):void {}
		
		/**
		 * 	@private
		 */
		public static function eventArgs(e:Event = null):void {}
		
		/**
		 * 	@private
		 */
		public static function starArgs(arg:* = null):void {}

	}
}