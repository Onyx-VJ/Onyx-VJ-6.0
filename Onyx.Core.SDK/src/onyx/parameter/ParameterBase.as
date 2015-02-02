package onyx.parameter {
	
	import flash.events.*;
	import flash.utils.*;
	
	import onyx.core.*;
	import onyx.event.*;
	import onyx.plugin.*;
	
	use namespace onyx_ns;
	use namespace parameter;
	
	public class ParameterBase extends EventDispatcher {
		
		/**
		 * 	@protected
		 */
		onyx_ns var parameters:ParameterList;
		
		/**
		 * 	@protected
		 */
		protected var invalid:Boolean			= true;
		
		/**
		 * 	@protected
		 * 	Stores an object of invalid parameters
		 */
		private var invalidParameters:Object	= {};
		
		/**
		 * 	@private
		 * 	THIS SHOULD ONLY BE CALLED FROM THE PLUGIN HOST!
		 */
		final parameter function initializeParameterInvalidation():void {
			
			if (!parameters) {
				return;
			}
			
			for each (var parameter:IParameter in parameters.iterator) {
				
				// add listener
				parameter.addEventListener(ParameterEvent.VALUE_CHANGE, invalidated);
				invalidParameters[parameter.id]		= parameter;
			}
		}
		
		/**
		 * 	@public
		 */
		final public function checkValidation():void {
			
			if (invalid) {
				
				validate(invalidParameters);
				
				invalidParameters	= {};
				invalid				= false;
			}
			
		}
		
		/**
		 *	@public
		 */
		final public function setParameterValue(id:String, value:*):void {
			
			var index:int		= id.indexOf('/');
			if (index > 1) {
				var prop:String = id.substr(index + 1);
				id = id.substr(0, index);
			}
			
			const p:IParameter	= parameters.hash[id];
			CONFIG::DEBUG {
				if (!p) {
					throw new Error(id + ' Not Found.');
				}
			}

			// parameters
			if (prop && p is IParameterObject) {
				var children:Vector.<IParameter> = (p as IParameterObject).getChildParameters();
				for each (var child:IParameter in children) {
					if (child.id === prop) {
						child.value = value;
						return;
					}
				}
			}
			
			p.value = value;
		}
		
		/**
		 *	@public
		 */
		final public function getParameterValue(id:String):* {
			
			var index:int		= id.indexOf('/');
			if (index > 1) {
				var prop:String = id.substr(index + 1);
				id = id.substr(0, index);
			}
			
			const p:Parameter	= parameters.hash[id];
			CONFIG::DEBUG {
				if (!p) {
					throw new Error(id + ' Not Found.');
				}
			}
			
			// parameters
			if (prop && p is IParameterObject) {
				var children:Vector.<IParameter> = (p as IParameterObject).getChildParameters();
				for each (var child:IParameter in children) {
					if (child.id === prop) {
						return child.value;
					}
				}
			}

			return p.value;
		}
		
		/**
		 * 	@public
		 */
		public function getParameters():ParameterList {
			return parameters;
		}
		
		/**
		 * 	@public
		 */
		public function hasParameter(id:String):Boolean {
			return parameters && parameters.hash[id] !== undefined;
		}
		
		/**
		 * 	@public
		 */
		final public function getParameter(id:String):IParameter {
			return parameters ? parameters.hash[id] : null;
		}
		
		/**
		 * 	@public
		 * 	This function is called when there are parameters that have changed, or the invalid flag is true
		 */
		protected function validate(invalidParameters:Object):void {}
		
		/**
		 * 	@final protected
		 */
		final private function invalidated(e:ParameterEvent):void {

			// blah
			var parameter:IParameter			= e.parameter;
			if (!invalidParameters[parameter.id]) {
				invalidParameters[parameter.id]		= new ParameterInvalidation(parameter, undefined);
				invalid								= true;
			}
			
			// re-dispatch
			dispatchEvent(e);
		}
		
		/**
		 * 	@public
		 */
		public function unserialize(token:*):void {

			if (token && parameters) {
				parameters.unserialize(token.parameters);
			}
		}
		
		/**
		 * 	@public
		 */
		public function dispose():void {
			
			if (parameters) {
				
				// add listener
				for each (var parameter:Parameter in parameters) {
					parameter.removeEventListener(ParameterEvent.VALUE_CHANGE, invalidated);
				}
				parameters.dispose();
			}
		}
	}
}