package onyx.geom {
	
	import flash.geom.*;

	public final class Rect extends Rectangle {
		
		/**
		 * 	@public
		 */
		public function Rect(x:Number = 0, y:Number = 0, w:Number = 0, h:Number = 0):void {
			this.x		= x;
			this.y		= y;
			this.width	= w;
			this.height	= h;
		}
	}
}