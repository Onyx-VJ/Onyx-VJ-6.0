package onyx.util.geom {
	
	import flash.geom.*;

	public final class GeomUtil {
		
		// Returns a point containing the intersection between two lines
		// http://keith-hair.net/blog/2008/08/04/find-intersection-point-of-two-lines-in-as3/
		// http://www.gamedev.pastebin.com/f49a054c1
		// optimized
		public static function getIntersection(p1:Point, p2:Point, p3:Point, p4:Point): Point {
			
			var a1:Number = p2.y - p1.y;
			var b1:Number = p1.x - p2.x;
			var a2:Number = p4.y - p3.y;
			var b2:Number = p3.x - p4.x;
			
			var denom:Number	= a1 * b2 - a2 * b1;
			if (denom == 0) {
				return null;	
			}
			
			var c1:Number = p2.x * p1.y - p1.x * p2.y;
			var c2:Number = p4.x * p3.y - p3.x * p4.y;
			
			var p:Point = new Point((b1 * c2 - b2 * c1)/denom, (a2 * c1 - a1 * c2)/denom);
			
			if (Point.distance(p, p2) > Point.distance(p1, p2)) return null;
			if (Point.distance(p, p1) > Point.distance(p1, p2)) return null;
			if (Point.distance(p, p4) > Point.distance(p3, p4)) return null;
			if (Point.distance(p, p3) > Point.distance(p3, p4)) return null;
			
			return p;
		}
	}
}