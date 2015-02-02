package onyx.event {
	
	import flash.events.*;
	
	public final class InteractionEvent extends Event {
		
		public static const CLICK:String		= 'Interaction.Click'
		public static const RIGHT_DOWN:String	= 'Interaction.RightClick';
		public static const RIGHT_UP:String		= 'Interaction.RightClick';
		public static const RIGHT_CLICK:String	= 'Interaction.RightClick';
		public static const MOUSE_DOWN:String	= 'Interaction.MouseDown';
		public static const MOUSE_UP:String		= 'Interaction.MouseUp';
		public static const MOUSE_MOVE:String	= 'Interaction.MouseMove';
		public static const MOUSE_OVER:String	= 'Interaction.MouseOver';
		public static const MOUSE_OUT:String	= 'Interaction.MouseOut';
		public static const DOUBLE_CLICK:String	= 'Interaction.DoubleClick';
		
		public static const MOUSE_ENTER:String	= 'Interaction.MouseEnter';
		public static const MOUSE_LEAVE:String	= 'Interaction.MouseLeave';
		
		public var x:Number;
		public var y:Number;
		
		/**
		 * 	@public
		 */
		public function InteractionEvent(type:String, x:Number = 0, y:Number = 0):void {
			
			this.x	= x;
			this.y	= y;
			
			super(type, false, false);
		}
		
		/**
		 * 	@public
		 */
		override public function clone():Event{
			return new InteractionEvent(type, x, y);
		}

	}
}