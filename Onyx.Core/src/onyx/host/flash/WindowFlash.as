package onyx.host.flash {
	
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	
	import onyx.core.*;

	/**
	 *	@private 
	 */
	final public class WindowFlash extends EventDispatcher implements IDisplayWindow {
		
		/**
		 * 	@private
		 */
		private var _stage:Stage;
		
		/**
		 * 	@public
		 */
		public function WindowFlash(stage:Stage):void {
			_stage	= stage;
		}
		
		/**
		 * 	@public
		 */
		public function set bounds(rect:Rectangle):void {}
		
		/**
		 * 	@public
		 */
		public function activate():void {}
		
		/**
		 * 	@public
		 */
		public function close():void {}
		
		/**
		 * 	@public
		 */
		public function get stage():Stage {
			return _stage;
		}
		
		/**
		 * 	@public
		 */
		public function get visible():Boolean {
			return true;
		}
		
		/**
		 * 	@public
		 */
		public function get bounds():Rectangle {
			return new Rectangle(0, 0, stage.stageWidth, stage.stageHeight);
		}
		
		/**
		 * 	@public
		 */
		public function set alwaysInFront(value:Boolean):void {}
		
		/**
		 * 	@public
		 */
		public function get alwaysInFront():Boolean {
			return false;
		}
		
		/**
		 * 	@public
		 */
		public function set fullScreen(value:Boolean):void {}
		
		/**
		 * 	@public
		 */
		public function get fullScreen():Boolean {
			return false;
		}
	}
}