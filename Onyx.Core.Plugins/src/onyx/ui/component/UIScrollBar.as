package onyx.ui.component {
	
	import flash.events.*;
	import flash.geom.*;
	
	import onyx.core.*;
	import onyx.ui.core.*;
	
	use namespace skinPart;
	
	[UIComponent(id='scrollBar')]
	
	[UISkinPart(id='track',		type='skin',	transform='default', constraint='relative',	left='0',	right='0', top='0', bottom='0',		skinClass='UIScrollTrack')]
	[UISkinPart(id='thumb',		type='skin',	transform='default', constraint='relative',	left='0',	right='0', top='0',	height='15',	skinClass='UIScrollThumb')]

	final public class UIScrollBar extends UIObject {
		
		/**
		 * 	@private
		 */
		private static var down:Number;
	
		/**
		 * 	@private
		 */
		skinPart var track:UISkin;
		
		/**
		 * 	@private
		 */
		skinPart var thumb:UISkin;
		
		/**
		 * 	@private
		 */
		private var bounds:UIRect;
		
		/**
		 * 	@public
		 */
		override public function initialize(data:Object):void {
			
			super.initialize(data);
			
			thumb.addEventListener(MouseEvent.MOUSE_DOWN, handleMouse);
		}
		
		/**
		 * 	@private
		 */
		private function handleMouse(event:MouseEvent):void {
			
			switch (event.type) {
				case MouseEvent.MOUSE_DOWN:
					
					down = thumb.y - event.stageY;
					
					stage.addEventListener(MouseEvent.MOUSE_MOVE,	handleMouse);
					stage.addEventListener(MouseEvent.MOUSE_UP,		handleMouse);
					
					break;
				case MouseEvent.MOUSE_MOVE:
					
					var y:Number = Math.max(Math.min(down + event.stageY, bounds.height - thumb.height), 0)
					
					thumb.x	= 0;
					thumb.y = y;
					
					(parent as UIScrollPane).signal(y / bounds.height);
					
					break;
				case MouseEvent.MOUSE_UP:
					stage.removeEventListener(MouseEvent.MOUSE_MOVE,	handleMouse);
					stage.removeEventListener(MouseEvent.MOUSE_UP,		handleMouse);
					break;
			}
		}
		
		/**
		 * 	@public
		 */
		public function setRatio(size:Number, pos:Number):void {
			thumb.arrange(new UIRect(0, pos * bounds.height, bounds.width, bounds.height * size));
		}
		
		/**
		 * 	@publci
		 */
		override public function arrange(rect:UIRect):void {
			
			super.arrange(bounds = rect);

			track.arrange(new UIRect(0, 0, rect.width, rect.height));
			thumb.arrange(new UIRect(0, 0, rect.width, 25));
		}
	}
}