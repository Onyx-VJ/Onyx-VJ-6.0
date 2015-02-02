package onyx.ui.event {
	
	import flash.events.*;
	
	final public class DragEvent extends Event {
		
		public static const DRAG_OVER:String	= 'Onyx.Drag.Over';
		public static const DRAG_OUT:String		= 'Onyx.Drag.Out';
		public static const DRAG_DROP:String	= 'Onyx.Drag.Drop';
		
		/**
		 * 	@public
		 */
		public var dragType:uint;
		
		/**
		 * 	@public
		 */
		public var dropData:*;
		
		/**
		 * 	@public
		 */
		public var data:*;
		
		/**
		 * 	@public
		 */
		public function DragEvent(type:String, dragType:uint = 0, dropData:* = null, data:* = null):void {
			
			this.dropData	= dropData;
			this.dragType	= dragType;
			this.data		= data;
			
			super(type, false, false);
		}
		
		/**
		 * 	@public
		 */
		override public function clone():Event {
			return new DragEvent(type, dragType, dropData, data);
		}
	}
}