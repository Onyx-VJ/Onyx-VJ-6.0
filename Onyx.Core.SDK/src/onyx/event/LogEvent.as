package onyx.event {
	
	import flash.events.*;

	public final class LogEvent extends Event {
		
		/**
		 * 	@public
		 */
		public static const LOG:String = 'Onyx.Log';
		
		/**
		 * 	@public
		 */
		public var logType:int;
		
		/**
		 * 	@public
		 */
		public var logMsg:String;
		
		/**
		 * 	@public
		 */
		public function LogEvent(logMsg:String):void {
			
			this.logMsg = logMsg;
			
			super(LOG, false, false);
		}
		
		/**
		 * 	@public
		 */
		override public function clone():Event {
			return new LogEvent(logMsg);
		}
	}
}