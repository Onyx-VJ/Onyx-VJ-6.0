package onyx.event {
	
	import flash.events.*;
	
	import onyx.core.*;
	import onyx.util.*;
	
	final public class EventBinding implements IDisposable {
		
		/**
		 * 	@private
		 */
		private var target:IEventDispatcher;
		
		/**
		 * 	@private
		 */
		private var eventTypes:Vector.<String>;
		
		/**
		 * 	@private
		 */
		private var callback:Callback;
		
		/**
		 * 	@public
		 */
		public function EventBinding(target:IEventDispatcher, callback:Callback, ... eventTypes:Array):void {
			this.target		= target;
			this.callback	= callback;
			if (eventTypes.length) {
				bind.apply(this, eventTypes);
			}
		}
		
		/**
		 * 	@public
		 */
		public function bind(... eventTypes):void {
			
			CONFIG::DEBUG {
				if (this.eventTypes) {
					throw new Error('Already bound!');
				}
			}
			
			this.eventTypes	= Vector.<String>(eventTypes);
			for each (var type:String in this.eventTypes) {
				target.addEventListener(type, callback.exec);
			}
		}
		
		/**
		 * 	@private
		 */
		public function dispose():void {
		}
	}
}