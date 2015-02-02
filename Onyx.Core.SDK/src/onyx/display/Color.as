package onyx.display {
	
	import onyx.util.*;
	
	/**
	 * 	Core color class
	 */
	public final class Color {
		
		/**
		 * 	@public
		 */
		public static const CLEAR:Color		= new Color(0.0, 0.0, 0.0, 0.0);

		/**
		 * 	@public
		 */
		public static const BLACK:Color		= new Color(0.0, 0.0, 0.0, 1.0);
		
		/**
		 * 	@public
		 */
		public static const RED:Color		= new Color(1.0, 0.0, 0.0, 1.0);
		
		/**
		 * 	@public
		 */
		CONFIG::DEBUG public static function Random(alpha:Number = 1.0):Color {
			return new Color(Math.random(), Math.random(), Math.random(), alpha);
		}
		
		/**
		 * 	@public
		 */
		public var r:Number;
		
		/**
		 * 	@public
		 */
		public var g:Number;
		
		/**
		 * 	@public
		 */
		public var b:Number;
		
		/**
		 * 	@public
		 */
		public var a:Number;
		
		/**
		 * 	@public
		 */
		public static function fromNumber(value:uint, alpha:Boolean = false):Color {
			
//			const	r:Number	= ((value & 0xFF0000) >> 16) / 255;
//			const	g:Number	= ((value & 0x00FF00) >> 8) / 255;
//			const	b:Number	= ((value & 0x0000FF)) / 255;
//			const	a:Number	= alpha ? ((value & 0xFF000000) >> 24) / 255 : 1.0;
			return new Color(
				((value & 0xFF0000) >> 16) / 255,
				((value & 0x00FF00) >> 8) / 255,
				((value & 0x0000FF)) / 255,
				alpha ? ((value & 0xFF000000) >> 24) / 255 : 1.0
			);
		}
		
		/**
		 * 	@public
		 */
		public function Color(r:Number = 0, g:Number = 0, b:Number = 0, a:Number = 1.0):void {
			this.r	= r;
			this.g	= g;
			this.b	= b;
			this.a	= a;
		}

		/**
		 * 	@public
		 */
		public function toNumber(alpha:Boolean = false):uint {
			const rgb:uint = uint(r * 255) << 16 | uint(g * 255) << 8 | uint(b * 255); 
			return alpha ? (0xFF * a) << 24 | rgb : rgb
		}
		
		/**
		 * 	@public
		 */
		public function fromInt(value:uint, alpha:Boolean = false):void {
			r = ((value & 0xFF0000) >> 16) / 255;
			g = ((value & 0x00FF00) >> 8) / 255;
			b = ((value & 0x0000FF)) / 255;
			a = alpha ? ((value & 0xFF000000) >> 24) / 255 : 1.0
		}
		
		/**
		 * 	@public
		 */
		public function toArray():Array {
			return [r, g, b];
		}
		
		/**
		 * 	@public
		 */
		CONFIG::DEBUG public function toString():String {
			return '[Color: r=' + r.toFixed(2) + ', g=' + g.toFixed(2) + ', b=' + b.toFixed(2) + ', a=' + a.toFixed(2) + ']';
		}
	}
}