package onyx.ui.component {
	
	import flash.display.*;
	
	import onyx.ui.core.*;
	
	[UIComponent(id='bitmap')]
	
	public final class UIBitmap extends UIObject {
		
		/**
		 * 	@public
		 */
		private const bitmap:Bitmap	= addChild(new Bitmap()) as Bitmap;
		
		/**
		 * 	@private
		 */
		private var bounds:UIRect;
		
		/**
		 * 	@public
		 */
		public function set data(value:BitmapData):void {
			bitmap.bitmapData	= value;
			if (!bounds) {
				return;
			}
			
			bitmap.width		= bounds.width;
			bitmap.height		= bounds.height;
		}
		
		/**
		 * 	@public
		 */
		public function get data():BitmapData {
			return bitmap.bitmapData;
		}
		
		/**
		 * 	@public
		 */
		override public function arrange(rect:UIRect):void {
			super.arrange(rect);
			bounds = rect.identity();
		}
	}
}