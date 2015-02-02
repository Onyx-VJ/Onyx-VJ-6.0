package onyx.display {
	
	import flash.display.*;
	import flash.events.*;
	import flash.ui.*;
	
	import onyx.core.*;
	import onyx.display.*;
	import onyx.event.*;
	
	public final class DisplayMouseProxy {
		
		private var contexts:Vector.<IDisplayContext>;
		private var stage:Stage;
		private var width:int;
		private var height:int;
		
		/**
		 * 	@public
		 */
		public function DisplayMouseProxy(window:IDisplayWindow, x:int, y:int, width:int, height:int, ... contexts:Array):void {
			
			this.width		= width;
			this.height		= height;
			this.contexts	= Vector.<IDisplayContext>(contexts);
			this.stage		= window.stage;

		}
		
		/**
		 * 	@public
		 */
		public function initialize():void {
			
			// stage?
			stage.addEventListener(MouseEvent.MOUSE_MOVE,		handleMouse);
			stage.addEventListener(MouseEvent.ROLL_OVER,		handleMouse);
			stage.addEventListener(MouseEvent.MOUSE_DOWN,		handleMouse);
			
			stage.addEventListener(MouseEvent.MOUSE_MOVE,		forwardMouse);
			stage.addEventListener(MouseEvent.MOUSE_UP,			forwardMouse);
			stage.addEventListener(MouseEvent.MOUSE_DOWN,		forwardMouse);
			
		}
		
		private function forwardMouse(e:MouseEvent):void {
			
			var type:String;
			
			switch (e.type) {
				case MouseEvent.MOUSE_DOWN:
					type = InteractionEvent.MOUSE_DOWN;
					break;
				case MouseEvent.MOUSE_MOVE:
					type = InteractionEvent.MOUSE_MOVE;
					break;
				case MouseEvent.MOUSE_UP:
					type	= InteractionEvent.MOUSE_UP;
					break;
				case MouseEvent.CLICK:
					type	= InteractionEvent.CLICK;
					break;
				case MouseEvent.DOUBLE_CLICK:
					type	= InteractionEvent.DOUBLE_CLICK;
					break;
				case MouseEvent.RIGHT_CLICK:
					type	= InteractionEvent.RIGHT_CLICK;
					break;
			}
			
			if (type) {
				
				
				var de:InteractionEvent = new InteractionEvent(type, (e.stageX / stage.stageWidth) * width, (e.stageY / stage.stageHeight) * height);
				for each (var context:IDisplayContext in contexts) {
					context.dispatchEvent(de);
				}
			}
		}
		
		/**
		 * 	@private
		 */
		private function handleMouse(e:Event):void {
			
			switch (e.type) {
				case Event.MOUSE_LEAVE:
					
					// remove listener
					stage.removeEventListener(Event.MOUSE_LEAVE,		handleMouse);
					stage.addEventListener(MouseEvent.MOUSE_MOVE,		handleMouse);
					
					// hide the mouse
					// Mouse.show();
					
					var de:InteractionEvent = new InteractionEvent(InteractionEvent.MOUSE_LEAVE);
					for each (var context:IDisplayContext in contexts) {
						context.dispatchEvent(de);
					}
										
					break;
				case MouseEvent.MOUSE_MOVE:
					
					// remove listener
					stage.addEventListener(Event.MOUSE_LEAVE,			handleMouse);
					stage.removeEventListener(MouseEvent.MOUSE_MOVE,	handleMouse);
					
					de = new InteractionEvent(InteractionEvent.MOUSE_ENTER);
					for each (context in contexts) {
						context.dispatchEvent(de);
					}
					
					// hide
					// Mouse.hide();
					
					break;
			}
		}
		
		public function dispose():void {
			
			// stage?
			stage.removeEventListener(MouseEvent.MOUSE_MOVE,		handleMouse);
			stage.removeEventListener(MouseEvent.ROLL_OVER,			handleMouse);
			stage.removeEventListener(MouseEvent.MOUSE_DOWN,		handleMouse);
			
			stage.removeEventListener(MouseEvent.MOUSE_MOVE,		forwardMouse);
			stage.removeEventListener(MouseEvent.MOUSE_UP,			forwardMouse);
			stage.removeEventListener(MouseEvent.MOUSE_DOWN,		forwardMouse);
			
		}
	}
}