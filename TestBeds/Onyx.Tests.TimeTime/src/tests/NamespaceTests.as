package tests
{
	import core.*;
	
	import flash.events.*;
	
	use namespace test;
	
	final public class NamespaceTests {
		
		private static const INTERATIONS:int	= 200000;
		
		public static function getTests():Array {
			return [
				new TestRunner('get namespace::var',	INTERATIONS, namespaceget),
				new TestRunner('get qname::var',		INTERATIONS, namespacegetqname),
				new TestRunner('get use namespace',		INTERATIONS, namespacegetuse),
				new TestRunner('set namespace::var',	INTERATIONS, namespaceset),
				new TestRunner('set qname::var',		INTERATIONS, namespacesetqname),
				new TestRunner('set use namespace',		INTERATIONS, namespacesetuse),
				
				new TestRunner('dyn get namespace::var',	INTERATIONS, dynnamespaceget),
				new TestRunner('dyn get qname::var',		INTERATIONS, dynnamespacegetqname),
				new TestRunner('dyn get use namespace',		INTERATIONS, dynnamespacegetuse),
				new TestRunner('dyn set namespace::var',	INTERATIONS, dynnamespaceset),
				new TestRunner('dyn set qname::var',		INTERATIONS, dynnamespacesetqname),
				new TestRunner('dyn set use namespace',		INTERATIONS, dynnamespacesetuse),
			];
		}
		
		private static const obj:NamespaceTests		= new NamespaceTests();
		
		private static const qname:QName			= new QName(test, 'testvar');
		
		/**
		 * 	@PRIVATE
		 */
		private static function namespaceget():void {
			obj.test::testvar;
		}
		
		/**
		 * 	@PRIVATE
		 */
		private static function namespacegetqname():void {
			obj[qname];
		}
		
		/**
		 * 	@PRIVATE
		 */
		private static function namespacegetuse():void {
			obj.testvar;
		}
		
		/**
		 * 	@PRIVATE
		 */
		private static function namespaceset():void {
			obj.test::testvar = 1;
		}
		
		/**
		 * 	@PRIVATE
		 */
		private static function namespacesetqname():void {
			obj[qname] = 1;
		}
		
		/**
		 * 	@PRIVATE
		 */
		private static function namespacesetuse():void {
			obj.testvar = 1;
		}
		
		/**
		 * 	@PRIVATE
		 */
		private static function dynnamespaceget():void {
			obj.test::['testvar'];
		}
		
		/**
		 * 	@PRIVATE
		 */
		private static function dynnamespacegetqname():void {
			obj[qname];
		}
		
		/**
		 * 	@PRIVATE
		 */
		private static function dynnamespacegetuse():void {
			obj['testvar'];
		}
		
		/**
		 * 	@PRIVATE
		 */
		private static function dynnamespaceset():void {
			obj.test::['testvar'] = 1;
		}
		
		/**
		 * 	@PRIVATE
		 */
		private static function dynnamespacesetqname():void {
			obj[qname] = 1;
		}
		
		/**
		 * 	@PRIVATE
		 */
		private static function dynnamespacesetuse():void {
			obj['testvar'] = 1;
		}
		
		test var testvar:Object;
	}
}