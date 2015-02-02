package onyx.parameter {
	
	import flash.events.*;
	import flash.utils.*;
	
	import onyx.core.*;
	import onyx.event.*;
	import onyx.util.*;
	
	use namespace parameter;
	use namespace onyx_ns;
	
	final public class ParameterList {
		
		/**
		 * 	@private
		 */
		onyx_ns var parameters:Vector.<IParameter>;
		
		/**
		 * 	@public
		 */
		onyx_ns var hash:Object			= {};
		
		/**
		 * 	@public
		 */
		public function ParameterList(parameters:Vector.<IParameter>):void {
			this.parameters	= parameters;
			for each (var parameter:IParameter in parameters) {
				hash[parameter.id] = parameter;
			}
		}

		/**
		 * 	@public
		 */
		public function unserialize(token:*):Boolean {
			
			for (var i:String in token) {
				var param:Parameter = hash[i];
				if (!param) {
					
					CONFIG::DEBUG { throw new Error(i + ' does not exist!'); }
					
					Console.Log(CONSOLE::ERROR, i, 'does not exist!');
					
					// continue
					continue;
				}
				
				param.unserialize(token[i]);

			}
			
			return true;
		}
		
		/**
		 * 	@public
		 */
		public function serialize(options:uint = 0xFFFFFFFF, parameterMask:Object = null):Object {
			
			if (!parameters.length) {
				return null;
			}

			const serialized:Object = {};
			if (parameterMask) {
				for (var i:String in parameterMask) {
					var parameter:IParameter = hash[i];
					if (parameter) {
						serialized[i] = parameter.serialize(options);
					}
				}
			} else {
				for each (parameter in parameters) {
					serialized[parameter.id] = parameter.serialize(options);
				}
			}
			return serialized;
		}
		
		/**
		 * 	@public
		 */
		public function get iterator():Vector.<IParameter> {
			return this.parameters;
		}
		
		/**
		 * 	@public
		 */
		public function dispose():void {
			for each (var parameter:IParameter in this) {
				delete this[parameter.id];
			}
			parameters = null;
		}
		
		/**
		 * 	@public
		 */
		public function reset():void {
			for each (var parameter:IParameter in parameters) {
				parameter.reset();
			}
		}

		/**
		 * 	@public
		 */
		CONFIG::DEBUG public function toString():String {
			return '[ParameterList:\n\t' + parameters.join('\n\t') + ']';
		}
	}
}