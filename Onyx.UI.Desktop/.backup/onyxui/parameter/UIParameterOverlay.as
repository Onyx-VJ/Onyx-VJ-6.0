package onyxui.parameter {
	
	import flash.display.*;
	import flash.events.*;
	
	import onyx.parameter.*;
	
	final internal class UIParameterOverlay extends Sprite implements IControlParameterProxy {
		
		/**
		 * 	@private
		 */
		private static const OVERLAY:BitmapData	= new BitmapData(1,1,true,0x33FFFFFF);
		
		/**
		 * 	@private
		 */
		private var parameter:Parameter;
		
		/**
		 * 	@public
		 */
		public function UIParameterOverlay(p:Parameter):void {
			
			parameter = p;
			
			addChild(new Bitmap(OVERLAY));
			
			addEventListener(MouseEvent.MOUSE_DOWN, handleMouse);
			addEventListener(MouseEvent.MOUSE_OVER,	handleMouse);
			addEventListener(MouseEvent.MOUSE_OUT,	handleMouse);
			
			this.name			= 'overlay';
			this.useHandCursor	= this.buttonMode	= true;
		}
		
		/**
		 * 	@public
		 */
		public function getParameter():Parameter {
			return parameter;
		}
		
		/**
		 * 	@private
		 */
		private function handleMouse(event:Event):void {
			event.stopImmediatePropagation();
		}
		
		/**
		 * 	@public
		 */
		public function dispose():void {
			
			removeEventListener(MouseEvent.MOUSE_DOWN, handleMouse);
			removeEventListener(MouseEvent.MOUSE_OVER,	handleMouse);
			removeEventListener(MouseEvent.MOUSE_OUT,	handleMouse);
			
		}
	}
}