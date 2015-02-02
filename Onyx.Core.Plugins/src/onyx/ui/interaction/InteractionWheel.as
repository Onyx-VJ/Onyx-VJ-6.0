package onyx.ui.interaction {
	
	import flash.events.*;
	import flash.geom.*;
	
	import onyx.core.*;
	import onyx.ui.core.*;
	
	internal final class InteractionWheel implements IInteraction {
		
		/**
		 * 	@private
		 */
		private var current:InteractionBinding;
		
		/**
		 * 	@public
		 */
		public function bind(object:UIObject):void {
			object.addEventListener(MouseEvent.MOUSE_OVER,		handleMouse);
		}
		
		/**
		 * 	@public
		 */
		public function unbind(object:UIObject):void {
			object.removeEventListener(MouseEvent.MOUSE_OVER,	handleMouse);
			object.removeEventListener(MouseEvent.MOUSE_OUT,	handleMouse);
		}
		
		/**
		 * 	@private
		 */
		private function handleMouse(event:MouseEvent):void {

			const target:UIObject = event.currentTarget as UIObject;
			switch (event.type) {
				case MouseEvent.MOUSE_OVER:
					
					// set current
					current = Interaction.Bindings[target];
					
					target.addEventListener(MouseEvent.MOUSE_OUT,		handleMouse);
					AppStage.addEventListener(MouseEvent.MOUSE_WHEEL,	handleStage);
					
					break;
				case MouseEvent.MOUSE_OUT:
					target.removeEventListener(MouseEvent.MOUSE_OUT,		handleMouse);
					AppStage.removeEventListener(MouseEvent.MOUSE_WHEEL,	handleStage);
					break;
			}
		}
		
		/**
		 * 	@private
		 */
		private function handleStage(event:MouseEvent):void {
			current.callback(this, event);
		}
		
		public function get type():int {
			return Interaction.WHEEL;
		}
	}
}