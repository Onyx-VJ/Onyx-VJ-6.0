package onyx.event
{
	import flash.events.Event;

	public final class DataEvent extends Event {
		
		/**
		 * 	@public
		 */
		public static const DATA:String = 'data';
		
		/**
		 * 	@public
		 */
		public var data:*;
		
		/**
		 * 	@public
		 */
		public function DataEvent(type:String, data:*):void {
			super(type, false, false);
			this.data = data;
		}
		
		override public function clone():Event {
			return new DataEvent(type, data);
		}
	}
}