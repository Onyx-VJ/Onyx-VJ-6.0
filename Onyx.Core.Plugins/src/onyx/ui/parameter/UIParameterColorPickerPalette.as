package onyx.ui.parameter {
	
	import flash.display.*;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.utils.*;
	
	import onyx.ui.component.UISkin;
	import onyx.ui.core.*;
	
	use namespace skinPart;
	
	[UISkinPart(id='skin',	type='skin',	skinClass='ColorPalette', constraint='relative', left='0', right='0', top='0', bottom='0')]
	
	public final class UIParameterColorPickerPalette extends UIObject {
		
		/**
		 * 	@private
		 */
		private static const PIXEL:BitmapData	= new BitmapData(1,1,false);
		
		/**
		 * 	@private
		 */
		skinPart var skin:UISkin;

		/**
		 * 	@public
		 */
		public function get color():uint {
			PIXEL.draw(skin, new Matrix(1, 0, 0, 1, -skin.mouseX, -skin.mouseY), null, null, new Rectangle(0, 0, 1, 1));
			return PIXEL.getPixel(0, 0);
		}
	}
}