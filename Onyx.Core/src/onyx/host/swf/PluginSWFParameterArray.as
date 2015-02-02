package onyx.host.swf {
	
	import onyx.core.*;
	import onyx.parameter.*;
	
	final public class PluginSWFParameterArray extends PluginSWFParameter implements IParameterIterator {

		/**
		 * 	@private
		 */
		private var iter:Vector.<String> 
		
		/**
		 * 	@private
		 */
		private var formatFunction:Function;
		
		/**
		 * 	@private
		 */
		private var labels:Vector.<String>;
		
		/**
		 * 	@public
		 */
		override public function initialize(target:Object, property:String, parameterType:String, definition:PluginSWFDefinition):void {
			
			// store the iterator
			iter = Vector.<String>((definition.values || '').split(','));
			
			// format?
			if (definition.labels) {
				
				// store labels
				labels	= Vector.<String>(definition.labels.split(','));
				
				// store the format function
				formatFunction = FORMAT_ARRAY;
				
				delete definition.labels;
				
				// formatFunction;// this.formatFunction;
			}
			
			// delete the values, since we don't need it anymore
			delete definition.values;
			
			// initialize
			super.initialize(target, property, parameterType, definition);
			
		}
		
		/**
		 * 	@public
		 */
		public function get currentIndex():int {
			return iter.indexOf(String(value));
		}
		
		/**
		 * 	@private
		 */
		private function FORMAT_ARRAY(value:*):String {
			var index:int = iter.indexOf(value);
			if (index !== -1) {
				return labels[index];
			}
			return value;
		}
		
		/**
		 * 	@public
		 */
		public function format(value:*):String {
			if (formatFunction !== null) {
				return formatFunction(String(value));
			}
			return value;
		}
		
		/**
		 * 	@public
		 */
		public function getIndexFromLabel(value:String):int {
			return labels.indexOf(value);
		}
		
		/**
		 * 	@public
		 */
		public function get iterator():* {
			return iter;
		}
	}
}