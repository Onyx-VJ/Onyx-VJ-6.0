package onyx.host.air {

	import flash.display.*;
	import flash.events.*;
	import flash.geom.Rectangle;
	
	import onyx.core.*;
	
	/**
	 * 	@private
	 * 	TODO: this should be a pluginbase so we can have "parameters"
	 */
	public final class AIRWindow extends EventDispatcher implements IDisplayWindow {
		
		/**
		 * 	@private
		 */
		private static function handleCancelClose(e:Event):void {
			e.preventDefault();
			e.stopImmediatePropagation();
		}
		
		/**
		 * 	@private
		 */
		private var _window:NativeWindow;
		
		/**
		 * 	@private
		 */
		private var _stage:Stage;
		
		/**
		 * 	@public
		 */
		public function AIRWindow(window:NativeWindow):void {
			
			_window	= window;
			_stage	= window.stage;
			_window.addEventListener(Event.CLOSING, handleClose);
			
			// set default opts
			_stage.align		= StageAlign.TOP_LEFT;
			_stage.scaleMode	= StageScaleMode.NO_SCALE;
			
		}
		
		/**
		 * 	@private
		 */
		private function handleClose(e:Event):void {
			if (dispatchEvent(e) && dispatchEvent(new Event(Event.CLOSE)) && !e.isDefaultPrevented()) {
				_window.close();
			} else {
				e.preventDefault();
			}
		}
		
		/**
		 * 	@public
		 */
		public function get visible():Boolean {
			return _window.visible;
		}
		
		/**
		 * 	@public
		 */
		public function set bounds(value:Rectangle):void {
			_window.bounds = value;
		}
		
		public function get bounds():Rectangle {
			return _window.bounds;
		}
		
		public function get stage():Stage {
			return _window.stage;
		}
		
		/**
		 * 	@public
		 */
		public function set alwaysInFront(value:Boolean):void {
			_window.alwaysInFront = value;
		}
		
		public function get alwaysInFront():Boolean {
			return _window.alwaysInFront;
		}
		
		public function close():void {
			_window.close();
		}
		
		public function activate():void {
			
			if (!_window.closed) {
				_window.activate();
			}
		}
		
		public function get closable():Boolean {
			return _window.hasEventListener(Event.CLOSING);
		}
		
		public function set closable(value:Boolean):void {
			_window.addEventListener(Event.CLOSING, handleCancelClose, false, 0, true);
		}

		/**
		 * 	@public
		 */
		public function set fullScreen(value:Boolean):void {
			_stage.displayState	= value ? StageDisplayState.FULL_SCREEN_INTERACTIVE : StageDisplayState.NORMAL;
		}
		
		/**
		 * 	@public
		 */
		public function get fullScreen():Boolean {
			return _stage.displayState === StageDisplayState.FULL_SCREEN_INTERACTIVE || _stage.displayState === StageDisplayState.FULL_SCREEN;
		}
		
		public function set title(value:String):void {
			_window.title = value;
		}
		public function get title():String {
			return _window.title;
		}
		
	}
}