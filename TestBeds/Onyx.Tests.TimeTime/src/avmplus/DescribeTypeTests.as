package avmplus {
	
	import core.*;
	
	import flash.utils.*;

	final public class DescribeTypeTests {
		
		private static const INTERATIONS:int	= 100000;
		
		public static function getTests():Array {
			return [
				new TestRunner('json',		INTERATIONS, test1, DescribeTypeTests)
			];
		}
		
		/**
		 * 	@private
		 */
		private static function test1(input:Object):void {
			describeTypeAsJSON(input);
		}
		
		/**
		 * 	@private
		 */
		public static function getQualifiedClassName(o:*):String {
			return avmplus.getQualifiedClassName(o);
		}
		
		/**
		 * 	@private
		 */
		public static function describeTypeXMLObject(o:*):XML {
			var c:String = avmplus.getQualifiedClassName(o);
			return avmplus.describeType(o, INCLUDE_BASES | INCLUDE_INTERFACES | INCLUDE_METADATA | INCLUDE_TRAITS);
		}
		
		/**
		 * 	@private
		 */
		public static function describeTypeAsXML(o:*):XML {
			return avmplus.describeType(o, INCLUDE_BASES | INCLUDE_INTERFACES | INCLUDE_METADATA | INCLUDE_TRAITS);
		}
		
		/**
		 * 	@private
		 */
		public static function describeTypeAsJSON(o:*):Object {
			return describeTypeJSON(o, INCLUDE_BASES | INCLUDE_INTERFACES | INCLUDE_METADATA | INCLUDE_TRAITS | USE_ITRAITS);
		}
		
		/**
		 * 	@private
		 */
		public static function describeTypeUtil(c:Class):Object {
			return flash.utils.describeType(c);
		}
	}
}