package onyx.filter.cpu {
	
	import com.ru.*;
	
	import flash.display.*;
	import flash.geom.*;
	
	import onyx.core.*;
	import onyx.display.*;
	import onyx.plugin.*;
	import onyx.util.*;
	import onyx.util.geom.GeomUtil;
	
	use namespace parameter;
	
	[PluginInfo(
		id			= 'Onyx.Core.Display.Filter.PerspectiveTransform',
		name		= 'Transform::Perspective',
		depends		= 'Onyx.Core.Display',
		vendor		= 'Daniel Hai',
		version		= '1.0'
	)]
	
	[Parameter(type='point',		id='topLeft',	 		clamp='-3,3',	reset='0,0')]
	[Parameter(type='point',		id='topRight',	 		clamp='-3,3',	reset='1,0')]
	[Parameter(type='point',		id='bottomLeft',	 	clamp='-3,3',	reset='0,1')]
	[Parameter(type='point',		id='bottomRight',	 	clamp='-3,3',	reset='1,1')]
	[Parameter(type='boolean',		id='smoothing',			reset='true')]
	[Parameter(type='array',		id='culling',			values='negative,none,positive',	reset='negative')]

	public final class PerspectiveTransform extends PluginFilterCPU implements IPluginFilterCPU {

		/**
		 * 	@parameter
		 */
		parameter const topLeft:Point		= new Point(0, 0);
		
		/**
		 * 	@parameter
		 */
		parameter const topRight:Point		= new Point(1, 0);
		
		/**
		 * 	@parameter
		 */
		parameter const bottomLeft:Point	= new Point(0, 1);
		
		/**
		 * 	@parameter
		 */
		parameter const bottomRight:Point	= new Point(1, 1);
		
		/**
		 * 	@private
		 */
		parameter var smoothing:Boolean		= true;
		
		/**
		 * 	@private
		 */
		parameter var culling:String		= TriangleCulling.NEGATIVE;
		
		/**
		 * 	@private
		 */
		private var shape:Shape				= new Shape();
		
		/**
		 * 	@private
		 */
		private var buffer:BitmapData;
		
		/**
		 * 	@private
		 */
		private var drawPoints:Vector.<Number>;//		= new Vector.<Number>(6, true);
		private var drawIndex:Vector.<int>;
		private var drawUV:Vector.<Number>;
		
		/**
		 * 	@public
		 */
		public function initialize(owner:IChannelCPU, context:IDisplayContextCPU):PluginStatus {
			
			this.context	= context;
			this.owner		= owner;
			
			// try to re-use teh same bitmapdata for everything that we do
			this.buffer		= SharedCache.get('BitmapData', context.width, context.height, true);
			
			// return ok
			return PluginStatus.OK;
		}
		
		/**
		 * 	@public
		 */
		override protected function validate(invalidParameters:Object):void {
			
			const w:int	= context.width;
			const h:int	= context.height;
			
			var center:Point	= GeomUtil.getIntersection(topLeft, bottomRight, topRight, bottomLeft);
			trace('perspective validate', topLeft, topRight, bottomLeft, bottomRight, center);
			if (!center) {
				
				drawPoints	= null;
				drawIndex	= null;
				drawUV		= null;
				
				return;
			}
			
			// Lengths of first diagonal
			var ll1:Number = Point.distance(topLeft, center);
			var ll2:Number = Point.distance(center, bottomRight);
			
			// Lengths of second diagonal
			var lr1:Number = Point.distance(topRight, center);
			var lr2:Number = Point.distance(center, bottomLeft);
			
			// Ratio between diagonals
			var f:Number = (ll1 + ll2) / (lr1 + lr2);
			
			drawPoints	= Vector.<Number>([
				topLeft.x		* w, topLeft.y		* h,
				topRight.x		* w, topRight.y		* h, 
				bottomLeft.x	* w, bottomLeft.y	* h, 
				bottomRight.x	* w, bottomRight.y	* h
			]);
			
			drawIndex	= Vector.<int>([0, 1, 2, 1,3, 2]);
			drawUV		= Vector.<Number>([0,0,(1/ll2)*f, 1,0,(1/lr2), 0,1,(1/lr1), 1,1,(1/ll1)*f]);
			
		}
		
		/**
		 * 	@public
		 */
		public function render(context:IDisplayContextCPU):Boolean {
			
			// copy pixels out
			buffer.copyPixels(context.surface, buffer.rect, CONST_IDENTITY);
			
			var graphics:Graphics	= shape.graphics;
			graphics.clear();
			graphics.beginBitmapFill(buffer, null, false, smoothing)
			graphics.drawTriangles(drawPoints, drawIndex, drawUV, culling);
			
			context.clear();
			context.draw(shape);
			
			return true;
		}
		
		/**
		 * 	@public
		 */
		override public function dispose():void {
		
			buffer = SharedCache.release('BitmapData', context.width, context.height, true);

		}
	}
}