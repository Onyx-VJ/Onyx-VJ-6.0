package onyx.ui.event {
	
	import flash.events.*;
	
	import onyx.core.*;
	
	public final class SelectionEvent extends Event {
		
		/**
		 * 	@public
		 */
		public static const SELECT:String	= 'Onyx.UI.Selection';
		
		/**
		 * 	@public
		 */
		public static const REMOVE:String	= 'Onyx.UI.Remove';
		
		/**
		 * 	@public
		 */
		public var data:IPlugin;
		
		/**
		 * 	@constructor
		 */
		public function SelectionEvent(type:String, data:IPlugin):void {
			
			// store
			this.data	= data;
			
			// type!
			super(type);
		}
		
		/**
		 * 	@public
		 */
		override public function clone():Event {
			return new SelectionEvent(type, data);
		}
		
		/**
		 * 	@public
		 */
		override public function toString():String {
			return formatToString('SelectionEvent', 'data');
		}
	}
}