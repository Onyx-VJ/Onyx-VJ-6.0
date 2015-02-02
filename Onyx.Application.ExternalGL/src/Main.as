package {
	
	import flash.display.*;
	import flash.external.*;
	import flash.system.*;
	
	public final class Main extends Sprite {
		
		/**
		 * 	@constructor
		 */
		public function Main():void {

			stage.nativeWindow.activate();
			Security.showSettings();
						
		}
	}
}