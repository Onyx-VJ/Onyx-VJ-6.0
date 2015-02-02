package onyx.ui.interaction {
	
	import flash.events.*;
	import flash.geom.*;
	
	import onyx.core.*;
	import onyx.ui.core.*;
	
	internal final class InteractionDrag implements IInteraction {
		
		/**
		 * 	@private
		 */
		private var current:InteractionBinding;
		
		/**
		 * 	@private
		 */
		private const down:Point	= new Point();
		
		/**
		 * 	@private
		 */
		public const diff:Point		= new Point();
		
		/**
		 * 	@public
		 */
		public function bind(object:UIObject):void {
			object.addEventListener(MouseEvent.MOUSE_DOWN, handleMouse);
		}
		
		/**
		 * 	@public
		 */
		public function unbind(object:UIObject):void {
			object.removeEventListener(MouseEvent.MOUSE_DOWN, handleMouse);
		}
		
		/**
		 * 	@private
		 */
		private function handleMouse(event:MouseEvent):void {
			
			// set current
			current = Interaction.Bindings[event.currentTarget];
			down.x	= event.stageX;
			down.y	= event.stageY;
			diff.x	= 0;
			diff.y	= 0;
			
			// add
			AppStage.addEventListener(MouseEvent.MOUSE_MOVE,	handleStage);
			AppStage.addEventListener(MouseEvent.MOUSE_UP,		handleStage);
			AppStage.addEventListener(MouseEvent.MOUSE_OVER,	handleStage, true);
			AppStage.addEventListener(MouseEvent.MOUSE_OUT,		handleStage, true);
			AppStage.addEventListener(MouseEvent.ROLL_OVER,		handleStage, true);
			AppStage.addEventListener(MouseEvent.ROLL_OUT,		handleStage, true);

		}
		
		/**
		 * 	@private
		 */
		private function handleStage(event:MouseEvent):void {
			
			switch (event.type) {
				case MouseEvent.MOUSE_MOVE:
					
					event.stopImmediatePropagation();
					
					diff.x	= event.stageX - down.x;
					diff.y	= event.stageY - down.y;
					
					current.callback(this, event);
					
					break;
				case MouseEvent.MOUSE_UP:

					// add
					AppStage.removeEventListener(MouseEvent.MOUSE_MOVE,	handleStage);
					AppStage.removeEventListener(MouseEvent.MOUSE_UP,	handleStage);
					AppStage.removeEventListener(MouseEvent.MOUSE_OVER,	handleStage, true);
					AppStage.removeEventListener(MouseEvent.MOUSE_OUT,	handleStage, true);
					AppStage.removeEventListener(MouseEvent.ROLL_OVER,	handleStage, true);
					AppStage.removeEventListener(MouseEvent.ROLL_OUT,	handleStage, true);
					
					current.callback(this, event);
					current = null;
					
					break;
			}
			
		}
		
		/**
		 * 	@public
		 */
		public function get type():int {
			return Interaction.LEFT_DRAG;
		}
	}
}