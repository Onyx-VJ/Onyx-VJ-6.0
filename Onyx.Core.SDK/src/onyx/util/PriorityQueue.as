package onyx.util {
	
	final public class PriorityQueue {
		
		/**
		 * 	@private
		 */
		private const loading:Array				= [];
		
		/**
		 * 	@private
		 */
		private const queue:Array				= [];
		
		/**
		 * 	@private
		 */
		private var concurrent:int				= 1;
		
		/**
		 * 	@private
		 * 	This handler is called when a new item is called to be executed
		 */
		private var execHandler:Function;
		
		/**
		 * 	@public
		 */
		public function PriorityQueue(concurrent:int = 2):void {
			this.concurrent		= concurrent;
		}
		
		/**
		 * 	@public
		 */
		public function get numLoading():uint {
			return loading.length;
		}
		
		/**
		 * 	@public
		 */
		public function get numQueued():uint {
			return queue.length;
		}
		
		/**
		 * 	@public
		 */
		public function addItem(data:Object, exec:Callback, result:Callback):void {
			
			var item:PriorityQueueItem	= new PriorityQueueItem();
			item.exec					= exec;
			item.result					= result;
			
			// push
			queue.push(item);
			
			// execute
			executeNext();
			
		}
		
		/**
		 * 	@private
		 */
		private function executeNext():void {
			
			while (queue.length && loading.length < concurrent) {
				
				// add the item to the loading queue
				var item:PriorityQueueItem = queue.shift() as PriorityQueueItem;
				
				// add the item
				loading.push(item);
				
				// execute!
				item.exec.exec([item]);
			}
		}
		
		/**
		 * 	@public
		 * 	Denotes that an item has been completed, and the queue should continue
		 */
		public function flagCompletion(item:PriorityQueueItem, ... args:Array):void {
			
			var index:int = loading.indexOf(item);
			
			// remove the item
			loading.splice(item, 1);
			
			// load the next one
			executeNext();
		}
		
		/**
		 * 	@public
		 */
		public function dispose():void {
			
			// remove everything in the queue
			queue.splice(0, queue.length);
			
		}
	}
}
import onyx.util.Callback;

final class PriorityQueueItem {
	
	public var exec:Callback;
	public var result:Callback;

}