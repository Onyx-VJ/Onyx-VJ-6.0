package onyx.ui.core {
	
	public final class UIObjectBounds {
		
		public var width:int;
		public var height:int;
		public var x:int;
		public var y:int;
		
		/**
		 * 	@public
		 */
		public function UIObjectBounds(x:int = 0, y:int = 0, width:int = 0, height:int = 0):void {
			this.x		= x,
			this.y		= y,
			this.width	= width,
			this.height	= height;
		}
		
		public function toString():String {
			return '[UIBounds:' + [x,y,width,height].join(',') + ']';
		}
	}
}