package onyx.display {
	
	final public class Color {
		
		public static const CLEAR:Color	= new Color();
		public static const BLACK:Color	= new Color(0,0,0,1.0);
		public static const RED:Color	= new Color(1.0,0,0,1.0);
		
		public var r:Number;
		public var g:Number;
		public var b:Number;
		public var a:Number;
		
		/**
		 * 	@constructor
		 */
		public function Color(r:Number = 0.0, g:Number = 0.0, b:Number = 0.0, a:Number = 0.0):void {
			this.r	= r;
			this.g	= g;
			this.b	= b;
			this.a	= a;
		}
	}
}