package onyxui.window.mixer {
	
	import flash.display.*;
	import flash.events.*;
	
	import onyx.core.*;
	import onyx.parameter.*;
	
	import onyxui.core.*;
	import onyxui.parameter.*;
	
	public final class BindingState {
		
		/**
		 * 	@private
		 */
		private var callback:Function;
		
		/**
		 * 	@public
		 */
		public function initialize(callback:Function):void {
			
			this.callback	= callback;
			
			UIParameter.show();
			
			AppStage.addEventListener(MouseEvent.CLICK,			handleStage, true);
			// AppStage.addEventListener(MouseEvent.MOUSE_DOWN,	handleStage, true);
			AppStage.addEventListener(MouseEvent.MOUSE_OVER,	handleStage, true);
			AppStage.addEventListener(MouseEvent.MOUSE_OUT,		handleStage, true);
			AppStage.addEventListener(MouseEvent.ROLL_OVER,		handleStage, true);
			// AppStage.addEventListener(MouseEvent.ROLL_OUT,		handleStage, true);
			
		}
		
		/**
		 * 	@private
		 */
		private function handleStage(e:Event):void {
			
			e.preventDefault();
			
			// click?
			if (e.type === MouseEvent.CLICK) {
				
				var target:IControlParameterProxy	= e.target as IControlParameterProxy;
				if (target) {
					var parameter:Parameter			= target.getParameter();
				} else {
					dispose();
				}
				
				// we have a target, so 
				if (parameter) {
					callback(parameter);
				}
				
				// dispose
				dispose();
			}
		}
		
		/**
		 * 	@private
		 */
		public function dispose():void {
			
			// hide!
			UIParameter.hide();
			
			// remove
			AppStage.removeEventListener(MouseEvent.CLICK,		handleStage, true);
			AppStage.removeEventListener(MouseEvent.MOUSE_DOWN,	handleStage, true);
			AppStage.removeEventListener(MouseEvent.MOUSE_OVER,	handleStage, true);
			AppStage.removeEventListener(MouseEvent.MOUSE_OUT,	handleStage, true);
			AppStage.removeEventListener(MouseEvent.ROLL_OVER,	handleStage, true);
			
		}
	}
}