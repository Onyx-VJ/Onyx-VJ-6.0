package onyx.util {
	
	import flash.events.Event;
	
	final public class StateQueue {
		
		/**
		 * 	@private
		 */
		private var queue:Array;
		
		/**
		 * 	@private
		 */
		private var callback:Callback;
		
		/**
		 * 	@private
		 */
		private var current:IState;
		
		/**
		 * 	@public
		 */
		public function initialize(callback:Callback, queue:Array):void {
			
			this.queue		= queue;
			this.callback	= callback;
			
			// queue the first time
			queueNext(null);
			
		}
		
		/**
		 * 	@private
		 */
		private function queueNext(data:Object):void {
			
			current = queue.shift() as IState;
			if (current) {
				current.initialize(new Callback(queueNext), data);
			} else {
				callback.exec();
			}
		}
	}
}