package mode {
	
	import flash.display.Stage;
	import flash.events.*;
	
	public class Mode {
		
		protected var app:Main;
		protected var stage:Stage;
		
		/**
		 * 	@public
		 */
		public function init(app:Main):void {
			this.app	= app;
			this.stage	= app.stage;
		}
		
		/**
		 * 	@public
		 */
		public function show():void {
			
		}
		
		/**
		 * 	@public
		 */
		public function hide():void {
			
		}
		
		/**
		 * 	@public
		 */
		public function handleKey(e:KeyboardEvent):void {
			
		}
	}
	
}