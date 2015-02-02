package onyx.event {
	
	import flash.events.*;
	
	import onyx.core.InterfaceMessage;
	
	public final class InterfaceMessageEvent extends Event {
		
		/**
		 * 	@public
		 */
		public static const MESSAGE:String	= 'Interface.Message';
		
		/**
		 * 	@private
		 */
		public var message:InterfaceMessage;
		
		/**
		 * 	@public
		 */
		public function InterfaceMessageEvent(message:InterfaceMessage):void {
			
			// store
			this.message = message;
			
			super(MESSAGE, false, true);
		}
		
		/**
		 * 	@public
		 */
		override public function clone():Event {
			return new InterfaceMessageEvent(message);
		}
	}
}