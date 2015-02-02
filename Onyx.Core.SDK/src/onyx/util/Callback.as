package onyx.util {
	
	import flash.events.*;
		
	final public class Callback {

		/**
		 *	@public
		 */
		public static function proxy(dispatcher:IEventDispatcher, callback:Callback, ... events:Array):void {
			
			const handler:Function = function(e:Event):void {
				
				for each (var type:String in events) {
					dispatcher.removeEventListener(type, handler, false);
					callback.exec(e);
				}
				
			};
			
			for each (var type:String in events) {
				dispatcher.addEventListener(type, handler, false);	
			}
		}

		/**
		 * 	@private
		 */
		public var method:Function;
		
		/**
		 * 	@private
		 */
		private var params:Array;
		
		/**
		 * 	@public
		 */
		public function Callback(method:Function, params:Array = null):void {
			this.method		= method;
			this.params		= params;
		}
		
		/**
		 * 	@public
		 */
		public function exec(... params:Array):* {
			
			const p:Array	= this.params && this.params.length ? this.params.concat(params) : params;
			if (p.length) {
				return method.apply(null, p);
			} else {
				return method();
			}
		}
	}
}