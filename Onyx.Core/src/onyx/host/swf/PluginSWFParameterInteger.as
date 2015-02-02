package onyx.host.swf {
	
	import flash.events.*;
	
	import onyx.core.*;
	import onyx.parameter.*;
	
	use namespace parameter;
	use namespace onyx_ns;
	
	final public class PluginSWFParameterInteger extends PluginSWFParameter implements IParameterNumeric {
		
		/**
		 * 	@private
		 */
		private var _min:int		= 0;
		
		/**
		 * 	@private
		 */
		private var _max:int		= 1;
		
		/**
		 * 	@private
		 */
		private var _precision:int	= 2;
		
		/**
		 * 	@private
		 */
		private var loop:Boolean;
		
		/**
		 * 	@public
		 */
		override public function initialize(target:Object, property:String, parameterType:String, definition:PluginSWFDefinition):void {
			
			super.initialize(target, property, parameterType, definition);
			
			if (definition.precision) {
				_precision = definition.precision;
			}
			
			if (definition.clamp) {
				var keys:Array = definition.clamp.split(',');
				if (keys.length === 2) {
					_min = isNaN(keys[0]) ? 0 : keys[0];
					_max = isNaN(keys[1]) ? 1 : keys[1];
				}
			}
			
			loop = String(definition.loop) === 'true';
		}
		
		/**
		 * 	@public
		 */
		public function get min():Number {
			return this._min;
		}
		
		/**
		 * 	@public
		 */
		public function get max():Number {
			return this._max;
		}
		
		/**
		 * 	@public
		 */
		override public function unserialize(token:*):void {
			
			if (token is Object && token.hasOwnProperty('value')) {
				value = int(token.value);
			} else {
				value = int(token) || 0;
			}
		}
		
		/**
		 * 	@public
		 */
		override public function set value(v:*):void {
			
			if (loop) {
				var diff:int = _max - _min;
				super.value	= ((diff + v) % diff) - diff;
			} else {
				super.value = Math.min(Math.max(v, _min), _max);
			}
		}
	}
}