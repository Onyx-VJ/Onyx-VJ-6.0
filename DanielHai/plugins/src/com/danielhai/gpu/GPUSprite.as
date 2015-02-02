package com.danielhai.gpu {
	
	import flash.geom.*;
	
	public final class GPUSprite {
		
		/**
		 * 	@private
		 */
		internal var index:int;
		
		/**
		 * 	@public
		 */
		public const position:Point	= new Point();
		
		/**
		 * 	@public
		 */
		public const scale:Point	= new Point(1, 1);
		
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