package {
	
	import flash.display.*;
	import flash.geom.*;
	
	public final class ObjectAttractor {
		
		// store the data for testing
		public var bmp:BitmapData;
		
		/**
		 * 	@private
		 */
		public const bounds:Rectangle	= new Rectangle();
		
		/**
		 * 	@private
		 */
		private var data:Vector.<uint>;
		
		/**
		 * 	@private
		 */
		private var sampleMatrix:Matrix;
		
		/**
		 * 	@private
		 */
		private var sampleMatrixInv:Matrix;
		
		/**
		 * 	@private
		 */
		private var center:Point		= new Point();
		
		/**
		 * 	@private
		 */
		private var colorRect:Rectangle;
		
		/**
		 * 	@private
		 */
		private var nodes:Vector.<Point>;
		
		/**
		 * 	@private
		 */
		private const OFFSET:Point		= new Point();
		
		/**
		 * 	@private
		 */
		public function ObjectAttractor(width:int, height:int, sampleMatrix:Matrix):void {
			
			var w:int			= Math.ceil(width * sampleMatrix.a),
				h:int			= Math.ceil(height * sampleMatrix.d);
			
			// sample matrix
			sampleMatrix		= sampleMatrix.clone();
			sampleMatrixInv		= sampleMatrix.clone();
			sampleMatrixInv.invert();
			
			OFFSET.x				= 0.5 / sampleMatrix.a;
			OFFSET.y				= 0.5 / sampleMatrix.d;
			
			this.sampleMatrix	= sampleMatrix;
			this.bmp			= new BitmapData(w, h, false, 0xFFFFFF);
			
		}
		
		public function resample(target:BitmapData, maxSamples:int):void {
			
			// draw
			bmp.draw(target, sampleMatrix);
			
			var points:uint			= bmp.threshold(bmp, bmp.rect, new Point(), '>', 0xFF444444, 0xFFFFFFFF, 0xFFFFFFFF, false);
			
			// store bounds
			colorRect				= bmp.getColorBoundsRect(0xFFFFFF, 0xFFFFFF, true);
			
			// make it smaller
			bounds.x				= colorRect.x / sampleMatrix.a;
			bounds.y 				= colorRect.y / sampleMatrix.d;
			bounds.width			= colorRect.width / sampleMatrix.a;
			bounds.height			= colorRect.height / sampleMatrix.d;
			
			center.x				= bounds.width * 0.5 + bounds.x;
			center.y				= bounds.height * 0.5 + bounds.y;
			
			// get the color bounds
			var vect:Vector.<uint>	= bmp.getVector(colorRect);
			var p:Array				= [];
			
			// loop and find white pixels
			for (var index:int = 0; index < vect.length; index++) {
				if (vect[index] == 0xFFFFFFFF) {
					
					// add a nodes
					p.push(new Point(colorRect.x + (index % colorRect.width), colorRect.y + Math.floor(index / colorRect.width)));
				}
			}
			
			var v:Array				= [];
			var o:int				= Math.ceil(points / maxSamples);
			var i:int				= 0;
			
			for (index = 0; index < p.length; index+=o) {
				v[i++] = p[index];
			}
			this.nodes = Vector.<Point>(v);
//			this.nodes = Vector.<Point>(p);
		} 
		
		/**
		 * 	@private
		 */
		public function getNearestPoint(p:Point):Point {
			
			if (!colorRect.width) {
				return new Point();
			}
			
			// need to find closest white pixel
			if (bounds.containsPoint(p)) {
				return getNearest(p);
			}
			return getNearest(new Point(Math.min(Math.max(p.x, bounds.x), bounds.x + bounds.width) + OFFSET.x, Math.min(Math.max(p.y, bounds.y), bounds.y + bounds.height) + OFFSET.y));
		}
		
		/**
		 * 	@private
		 */
		private function getNearest(p:Point):Point {
			
			p = sampleMatrix.transformPoint(p);
			var x:int	= p.x;
			var y:int	= p.y;
			
			var closest:Point;
			var closestDist:int = int.MAX_VALUE;
			var index:int		= 0;
			for each (var node:Point in nodes) {
				
				// same?
				if (x === node.x && y === node.y) {
					closest = node;
					break;
				}
				
				var dx:int		= node.x - p.x;
				var dy:int		= node.y - p.y;
				var dist:int	= dx * dx + dy * dy;
				
				// less than 1, just return it 
				if (dist < 2) {
					closest = node;
					break;
				} else {
					if (dist < closestDist) {
						closest		= node;
						closestDist = dist;
					}
				}
				++index;
			}
			
			// remove
			nodes.splice(index, 1);
			
			// closet?
			return closest ? sampleMatrixInv.transformPoint(closest).add(OFFSET) : null;
		}
	}
}
	
	
	
	//			
	//			var target:BitmapData	= this.target;
	//			target.threshold(target, target.rect, target.rect.topLeft, '<=', 0xFF444444, 0x00000000, 0xFFFFFFFFFF);
	//			
	//			target.colorTransform(target.rect, new ColorTransform(1,1,1,1,255,255,255,0));
	//			
	//			var bounds:Rectangle = target.getColorBoundsRect(0xFFFFFFFF, 0xFFFFFFFF, true);
	//			graphics.lineStyle(0, 0xFF0000);
	//			graphics.drawRect(bounds.x, bounds.y, bounds.width, bounds.height);
	//			graphics.endFill();
	//			
	//			var white:Rectangle	= target.getColorBoundsRect(0xFFFFFFFF, 0xFFFFFFFF, true);
	//			
	//			// get it got it 
	//			var bmp:BitmapData	= new BitmapData(Math.ceil(white.width / 4), Math.ceil(white.height / 4), false, 0x00);
	//			var matrix:Matrix	= new Matrix(0.25, 0, 0, 0.25, -white.x * 0.25, -white.y * 0.25); 
	//			bmp.draw(target, matrix);
	//			
	//			var overlay:DisplayObject	= stage.addChildAt(new Bitmap(bmp), 0);
	//			overlay.alpha				= 0.5;