package onyx.parameter {
	
	import flash.events.*;
	import flash.utils.*;
	
	import onyx.core.*;
	import onyx.event.*;
	import onyx.plugin.*;
	import onyx.util.*;
	
	use namespace parameter;
	use namespace onyx_ns;
	
	[Event(name='change', type='flash.events.Event')]
		
	public class Parameter extends EventDispatcher {
		
		/**
		 * 	@protected
		 */
		protected var property:String;

		/**
		 * 	@protected
		 */
		protected var binding:InterfaceBinding;
		
		/**
		 * 	@constructor
		 */
		CONFIG::DEBUG public function Parameter():void {
			GC.watch(this);
		}
		
		/**
		 * 	@public
		 */
		public function get id():String {
			return property;
		}
	
		/**
		 * 	@public
		 */
		final public function bindInterface(binding:InterfaceBinding):void {
			
			if (this.binding) {
				this.binding.unbind();
			}
			
			// store binding
			this.binding = binding;
			
			if (binding) {
				binding.bind(this);
			}
		}
		
		/**
		 * 	@public
		 */
		final public function getBoundInterface():InterfaceBinding {
			return binding;
		}

		/**
		 * 	@public
		 */
		public function set value(v:*):void {}
		
		/**
		 * 	@public
		 */
		public function get value():* {
			
			CONFIG::DEBUG {
				throw new Error('Must override get value');
			}
			
			return null;
		}
		
		/**
		 * 	@public
		 */
		public function serialize(options:uint = 0xFFFFFFFF):Object {
			
			const serial:Object = {
				value:	value
			};
			
			trace(this.id, options);
			
			// add a binding?
			if (binding && ((options & Plugin.SERIALIZE_BINDINGS) > 0)) {
				serial.binding	= binding.serialize();
			}
			
			return serial;
		}
		
		/**
		 * 	@public
		 */
		public function unserialize(token:*):void{
			
			if (token && token.hasOwnProperty('binding')) {
				var binding:InterfaceBinding = new InterfaceBinding();
				binding.unserialize(token.binding);
				this.bindInterface(binding);
				trace('binding!', Debug.object(token));
			}
			
			if (token && token.hasOwnProperty('value')) {
				this.value = token.value;
			}
		}
		
		/**
		 * 	@public
		 */
		public function reset():void {}
		
		/**
		 * 	@public
		 */
		public function dispose():void {
			bindInterface(null);
		}
	}
}