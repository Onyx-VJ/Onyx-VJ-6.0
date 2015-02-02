package onyxui.assets {
	
	import flash.display.*;

	[Embed(
		source					= 'src/onyx-title.png'
	)]
	[ExcludeClass]
	final public class UIAssetOnyxTitle extends Bitmap {
		
		private static var blitted:Boolean;
		
		/**
		 * 	@constructor
		 */
		public function UIAssetOnyxTitle():void {
			
			this.smoothing	= true;
			
			if (!blitted) {
				
				bitmapData
				
				blitted = true;
			}
		}
	}
}