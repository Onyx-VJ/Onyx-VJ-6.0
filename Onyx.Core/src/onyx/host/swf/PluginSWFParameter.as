package onyx.host.swf {

	import onyx.core.*;
	import onyx.event.*;
	import onyx.parameter.*;
	import onyx.plugin.*;
	import onyx.util.*;
	
	use namespace onyx_ns;
	use namespace parameter;

	public class PluginSWFParameter extends Parameter implements IParameter {
		
		/**
		 * 	@internal
		 */
		protected var target:Object;
		
		/**
		 * 	@protected
		 */
		protected var parameterType:String;
		
		/**
		 * 	@protected
		 */
		protected var definition:PluginSWFDefinition;
		
		/**
		 * 	@protected
		 */
		protected var locked:Boolean;
		
		/**
		 * 	@constructor
		 */
		CONFIG::DEBUG public function PluginSWFParameter():void {
			GC.watch(this);
		}
		
		/**
		 *	@internal
		 */
		public function initialize(target:Object, property:String, type:String, definition:PluginSWFDefinition):void {
			
			this.target			= target;
			this.definition		= definition;
			this.parameterType	= type;
			this.property		= property;
			
		}
		
		/**
		 * 	@public
		 */
		final public function lock(value:Boolean):void {
			locked = value;
		}
		
		/**
		 * 	@public
		 */
		public function isBindable():Boolean {
			return true;
		}
		
		/**
		 * 	@public
		 */
		final public function get info():* {
			return definition;
		}
		
		/**
		 * 	@public
		 */
		final public function get name():String {
			
			CONFIG::DEBUG {
				if (!definition) {
					return '';
				}
			}
			
			return definition.name || definition.id;
		}
		
		/**
		 * 	@public
		 */
		final override public function get id():String {
			return definition.id;
		}		
		/**
		 * 	@public
		 */
		final public function get type():String {
			return parameterType;
		}
		
		/**
		 * 	@public
		 */
		override public function set value(v:*):void {

			const old:*			= this.value;
			target[property]	= v ? v : null;
			
			// we've changed
			dispatchEvent(new ParameterEvent(ParameterEvent.VALUE_CHANGE, this));
			
		}
		
		/**
		 * 	@public
		 */
		final public function isHidden():Boolean {
			return definition.display === 'false';
		}

		/**
		 * 	@public
		 */
		override public function get value():* {
			return target[property];
		}
		
		/**
		 * 	@public
		 */
		override public function reset():void {
			if (definition.reset !== undefined) {
				unserialize({ value: definition.reset });
			}
		}
		
		/**
		 * 	@public
		 */
		public function getDisplayValue():String {
			return value;
		}
		
		CONFIG::DEBUG {
			override public function toString():String {
				return '[Parameter ' + this.name + '(' + this.type + ':' + Object(this).constructor + '): ' + this.value + ']';
			}
		}
	}
}