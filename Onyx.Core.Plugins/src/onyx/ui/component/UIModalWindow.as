package onyx.ui.component {
	
	import flash.display.*;
	import flash.events.*;
	
	import onyx.core.IDisposable;
	import onyx.ui.core.*;
	
	[UIConstraint(type='fill')]

	public final class UIModalWindow extends UIObject implements IDisposable {
		
		/**
		 * 	@public
		 */
		public function init():void {

			addEventListener(KeyboardEvent.KEY_DOWN,	handleMouse);
			addEventListener(KeyboardEvent.KEY_UP,		handleMouse);
			addEventListener(MouseEvent.MOUSE_DOWN,		handleMouse);
			addEventListener(MouseEvent.MOUSE_UP,		handleMouse);
			addEventListener(MouseEvent.MOUSE_MOVE,		handleMouse);
			addEventListener(MouseEvent.MOUSE_OVER, 	handleMouse);
			addEventListener(MouseEvent.MOUSE_OUT,		handleMouse);
			
			const g:Graphics = graphics;
			g.beginFill(0x00, 0.75);
			g.drawRect(-8, -8, stage.stageWidth, stage.stageHeight);
			g.endFill();
			
			cacheAsBitmap	= true;
			x				= 8;
			y				= 8;
			
		}
		
		/**
		 * 	@private
		 */
		private function handleMouse(e:Event):void {
			e.stopPropagation();
		}

		/**
		 * 	@public
		 */
		override public function dispose():void {
			
			graphics.clear();
			
			removeEventListener(KeyboardEvent.KEY_DOWN,		handleMouse);
			removeEventListener(KeyboardEvent.KEY_UP,		handleMouse);
			removeEventListener(MouseEvent.MOUSE_DOWN,		handleMouse);
			removeEventListener(MouseEvent.MOUSE_UP,		handleMouse);
			removeEventListener(MouseEvent.MOUSE_MOVE,		handleMouse);
			removeEventListener(MouseEvent.MOUSE_OVER, 		handleMouse);
			removeEventListener(MouseEvent.MOUSE_OUT,		handleMouse);
			
			super.dispose();

		}
	}
}