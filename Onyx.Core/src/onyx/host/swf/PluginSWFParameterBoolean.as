package onyx.host.swf {
	
	import onyx.core.*;
	import onyx.parameter.*;
	
	final public class PluginSWFParameterBoolean extends PluginSWFParameter implements IParameterIterator {
		
		/**
		 * 	@private
		 */
		private static const ITERATOR:Vector.<Boolean> = Vector.<Boolean>([false, true]);
		
		/**
		 * 	@public
		 */
		public function format(value:*):String {
			return value;
		}
		
		/**
		 * 	@public
		 */
		public function get currentIndex():int {
			return ITERATOR.indexOf(value);
		}
		
		/**
		 * 	@public
		 */
		public function get iterator():* {
			return ITERATOR;
		}
	}
}