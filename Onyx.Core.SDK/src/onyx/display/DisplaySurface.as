package onyx.display {
	
	import flash.display.*;
	import flash.geom.*;
	
	import onyx.core.*;
	
	/**
	 * 	@public
	 * 	Base class for bitmap information
	 */
	final public class DisplaySurface extends BitmapData {
		
		/**
		 * 	@public
		 */
		public static const SMOOTH_AUTO:uint		= 0x00;
		
		/**
		 * 	@public
		 */
		public static const SMOOTH_NONE:uint		= 0x01;
		
		/**
		 * 	@public
		 */
		public static const SMOOTH_LINEAR:uint		= 0x02;
		
		/**
		 * 	@private
		 */
		private const rectangle:Rectangle	= new Rectangle();
		
		CONFIG::DEBUG public static var IDS:int	= 0;
		
		/**
		 * 	@public
		 */
		CONFIG::DEBUG public var id:int			= ++IDS;

		/**
		 * 	@public
		 */
		public function DisplaySurface(width:int, height:int, alpha:Boolean, color:uint):void {
			super(width, height, alpha, color);
			rectangle.width 	= width;
			rectangle.height	= height;
		}
		
		
		/**
		 * 	@public
		 */
		final override public function copyPixels(source:BitmapData, rect:Rectangle, point:Point, alpha:BitmapData = null, alphaPoint:Point = null, merge:Boolean = false):void{
			return super.copyPixels(source, rect || rectangle, point || CONST_IDENTITY, alpha, alphaPoint, merge);
		}
		
		/**
		 * 	@public
		 */
		public function clear(color:uint = 0x00):void {
			fillRect(rectangle, color);
		}
		
		/**
		 * 	@public
		 */
		override public function clone():BitmapData {
			const surface:DisplaySurface = new DisplaySurface(width, height, transparent, 0x00);
			surface.copyPixels(this, rectangle, CONST_IDENTITY);
			return surface;
		}
		
		/**
		 * 	@public
		 */
		CONFIG::DEBUG public function toString():String {
			return 'DisplaySurface: ' + id;
		}
	}
}