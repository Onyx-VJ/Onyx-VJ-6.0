package onyx.ui.interaction {
	
	import flash.events.*;
	import flash.geom.*;
	
	import onyx.ui.core.*;
	
	internal final class InteractionClick implements IInteraction {
		
		/**
		 * 	@private
		 */
		private var eventType:String;
		
		/**
		 * 	@private
		 */
		private var interactionType:int;
		
		/**
		 * 	@public
		 */
		public function InteractionClick(event:String, type:int):void {
			eventType		= event;
			interactionType	= type;
		}
		
		/**
		 * 	@public
		 */
		public function bind(object:UIObject):void {
			object.addEventListener(eventType,		handleMouse);
		}
		
		/**
		 * 	@public
		 */
		public function unbind(object:UIObject):void {
			object.removeEventListener(eventType,	handleMouse);
		}
		
		/**
		 * 	@private
		 */
		private function handleMouse(event:MouseEvent):void {
			
			var binding:InteractionBinding = Interaction.Bindings[event.currentTarget];
			binding.callback(this, event);

		}
		
		public function get type():int {
			return interactionType;
		}
	}
}