package onyx.ui.core {
	
	import flash.geom.*;
	import flash.text.*;
	
	final public class UIStyleManager {
		
		/**
		 * 	@private
		 */
		public static function createDefaultTextFormat(color:uint = 0xdff1f1, align:String = null):TextFormat {
			
			const format:TextFormat = new TextFormat('UIPixelFont', 10, color);
			format.leading			= 2;
			format.align			= align || TextFormatAlign.LEFT;
			format.letterSpacing	= 0.5;
			format.kerning			= true;
			return format;
		};
		
		/**
		 * 	@private
		 */
		public static const FORMAT_DEFAULT:TextFormat				= createDefaultTextFormat(0xffffff);
		
		/**
		 * 	@public
		 */
		public static const TRANSFORM_DEFAULT:ColorTransform		= new ColorTransform(1,1,1,1,0,9,16);
		
		/**
		 * 	@public
		 */
		public static const TRANSFORM_HIGHLIGHT:ColorTransform		= new ColorTransform(1,1,1,1,18,36,64);
		
		/**
		 * 	@public
		 */
		public static const TRANSFORM_SELECTED:ColorTransform		= new ColorTransform(1,1,1,1,32,16,0);
		
		/**
		 * 	@public
		 */
		public static const TRANSFORM_NONE:ColorTransform			= new ColorTransform();
		
		/**
		 * 	@public
		 */
		public static const TRANSFORM_OVER:ColorTransform			= new ColorTransform(2,2,2,2,1,0,9,16);
	}
}