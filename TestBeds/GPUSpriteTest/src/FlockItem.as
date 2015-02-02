package {
	
	import flash.display.*;
	import flash.geom.Point;
	
	import onyx.display.GPUSprite;

	public final class FlockItem {
		
		/**
		 * 	@public
		 */
		public var heading:Number	= (Math.random() * Math.PI * 2) - Math.PI;
		
		/**
		 * 	@public
		 */
		public var speed:Number		= Math.random() * 10.0 + 5.5;
		
		/**
		 * 	@public
		 */
		public var target:Point		= new Point(Math.random() * 1920, Math.random() * 1080);
		
		/**
		 * 	@public
		 */
		public var sprite:GPUSprite;
		
		public var turnSpeed:Number	= 0.05 + Math.random() * 0.4;
		
		/**
		 * 	@public
		 */
		public const position:Point	= new Point();
		
		/**
		 * 	@public
		 */
		public function FlockItem(sprite:GPUSprite):void {
			this.sprite		= sprite;
		}
		
		/**
		 * 	@public
		 */
		public function toString():String {
			return 'FL: ' + position.toString();	
		}
	}
}