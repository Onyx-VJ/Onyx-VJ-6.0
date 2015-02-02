package onyx.display {
	
	import flash.geom.*;
	
	import spark.primitives.Rect;

	public final class GPUSprite {
		
		/**
		 * 	@private
		 */
		public var index:int;
		
		/**
		 * 	@public
		 */
		public const position:Point	= new Point();
		
		/**
		 * 	@public
		 */
		public var scale:Number		= 0.15;
		
		/**
		 * 	@public
		 */
		public var rotation:Number	= 0;
		
		/**
		 * 	@public
		 */
		public var alpha:Number		= 1;
		
		/**
		 * 	@public
		 */
		public var rect:Rectangle;

		/**
		 * 	@public
		 */
		public function GPUSprite(index:int, rect:Rectangle):void {
			this.index	= index;
			this.rect	= rect;
		}
	}
}