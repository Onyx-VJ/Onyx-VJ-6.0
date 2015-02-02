package {
	
	import flash.display.*;
	import flash.filesystem.*;
	import flash.desktop.*;
	
	/**
	 * 	@public
	 */
	final public class ManifestCreator extends Sprite {
		
		/**
		 * 	@public
		 */
		public function ManifestCreator():void {
			
			stage.nativeWindow.close();
			
			NativeApplication.nativeApplication.exit(0);
		}
	}
}