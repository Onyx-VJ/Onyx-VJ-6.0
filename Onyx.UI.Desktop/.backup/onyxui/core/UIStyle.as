package onyxui.core {
	
	import flash.geom.*;
	import flash.text.*;
	
	import onyxui.assets.*;
	import onyxui.core.*;
	
	final public class UIStyle {
		
		/**
		 * 	@public
		 */
		public static const PIXEL:String								= 'UIPixelFont';
		
		/**
		 * 	@private
		 */
		public static function createDefaultTextFormat(name:String, color:uint = 0xdff1f1, align:String = null):TextFormat {
			const format:TextFormat = new TextFormat(name, 10, color);
			format.leading			= 2;
			format.align			= align || TextFormatAlign.LEFT;
			return format;
		};
		
		/**
		 *
		 */
		public static function TextField(format:TextFormat = null):flash.text.TextField {
			
			const label:flash.text.TextField	= new flash.text.TextField();
			label.embedFonts					= true;
			label.antiAliasType					= AntiAliasType.ADVANCED;
			label.defaultTextFormat				= format || UIStyle.FORMAT_DEFAULT;
			label.mouseEnabled					= false;
			label.height						= 16;
			
			return label;
		}
		
		/**
		 * 	@private
		 */
		public static const FORMAT_DEFAULT:TextFormat				= createDefaultTextFormat(PIXEL, 0xffffff);
		
		/**
		 * 	@private
		 */
		public static const FORMAT_BLUE:TextFormat					= createDefaultTextFormat(PIXEL, 0xDDF9FF);
		
		/**
		 * 	@private
		 */
		public static const FORMAT_CENTER:TextFormat				= createDefaultTextFormat(PIXEL, 0xffffff, TextFormatAlign.CENTER);
		
		/**
		 * 	@private
		 */
		public static const FORMAT_RIGHT:TextFormat					= createDefaultTextFormat(PIXEL, 0xffffff, TextFormatAlign.RIGHT);
		
		/**
		 * 	@private
		 */
		public static const FORMAT_CONTROL_LABEL:TextFormat			= createDefaultTextFormat(PIXEL, 0x3333ff, TextFormatAlign.CENTER);
		
		/**
		 * 	@public
		 */
		public static const TRANSFORM_DEFAULT:ColorTransform		= new ColorTransform(1,1,1,1,0,9,16);
		
		/**
		 * 	@public
		 */
		public static const TRANSFORM_HIGHLIGHT:ColorTransform		= new ColorTransform(1,1,1,1,50,50,50);
		
		/**
		 * 	@public
		 */
		public static const TRANSFORM_NONE:ColorTransform			= new ColorTransform();
		
		/**
		 * 	@public
		 */
		public static const TRANSFORM_OVER:ColorTransform			= new ColorTransform(2,2,2,2,1,0,9,16);
		
		/**
		 * 	@public
		 */
		public static const TRANSFORM_SELECTED:ColorTransform		= new ColorTransform(1,1,1,1,48,48,48);

	}
}