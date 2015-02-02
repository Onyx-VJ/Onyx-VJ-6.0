package onyx.display {
	
	import flash.geom.*;
	
	import onyx.core.*;

	public final class ContentTransform {
		
		/**
		 * 	@public
		 */
		public const matrix:Matrix					= new Matrix();
		
		/**
		 * 	@protected
		 * 	The anchor point we're going to rotate (in terms of content width/height)
		 */
		public const anchor:Point					= new Point();
		
		/**
		 * 	@private
		 * 	Rotation 0-1
		 */
		public var rotation:Number					= 0.0;
		
		/**
		 * 	@public
		 */
		public function ContentTransform(anchorX:Number = 0.5, anchorY:Number = 0.5):void {
			anchor.x = anchorX;
			anchor.y = anchorY;
		}

		/**
		 * 	@public
		 */	
		public function update(renderMatrix:Matrix, context:IDisplayContext, dimensions:Dimensions):void {
			
			// auto center
			var scale:Number		= Math.min(context.width / dimensions.width, context.height / dimensions.height);
			
			renderMatrix.identity();
			renderMatrix.translate(dimensions.width * -anchor.x, dimensions.height * -anchor.y);
			renderMatrix.scale(matrix.a * scale, matrix.d * scale);
			renderMatrix.rotate(rotation * Math.PI);
			renderMatrix.translate(dimensions.width * scale * anchor.x + (matrix.tx * dimensions.width), dimensions.height * scale * anchor.y + (matrix.ty * dimensions.height));
			renderMatrix.translate(
				(context.width * anchor.x) - (dimensions.width * scale * anchor.y),
				(context.height * anchor.x) - (dimensions.height * scale * anchor.y)
			);
		}
	}
}