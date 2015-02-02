package onyx.core {
	
	final public class InterfaceMessage {
		
		/**
		 * 	@public
		 * 	The origin plugin that dispatched this message
		 */
		public var origin:IPluginModuleInterface;
		
		/**
		 * 	@public
		 */
		public var key:uint;
		
		/**
		 * 	@public
		 */
		public var value:Number;
		
		/**
		 * 	@public
		 */
		public function InterfaceMessage():void {}
		
		/**
		 * 	@public
		 */
		public function toString():String {
			return (origin ? origin.formatMessage(key) : '');
		}
	}
}