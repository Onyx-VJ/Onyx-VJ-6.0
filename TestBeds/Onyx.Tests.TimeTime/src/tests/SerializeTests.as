package tests {
	
	import core.*;
	
	import flash.events.*;
	import flash.utils.ByteArray;
	
	public final class SerializeTests {
		
		private static const INTERATIONS:int	= 100000;
		private static const OBJECT:Object		= {
			'a':	1,
			'b':	2,
			'c':	3,
			'd':	4,
			'e':	5
		}
		
		public static function getTests():Array {
			return [
				new TestRunner('json',		INTERATIONS, test1, OBJECT),
				// new TestRunner('objut', 	INTERATIONS, test2, OBJECT)
			];
		}
		
		/**
		 * 	@private
		 */
		private static function test1(input:Object):void {
			const obj:Object	= JSON.parse(JSON.stringify(obj));
		}
		
		/**
		 * 	@private
		 */
		private static function test2(input:Object):void {
			const bytes:ByteArray	= new ByteArray();
			bytes.writeObject(input);
			bytes.position			= 0;
			bytes.readObject();
			
		}
		
	}
}