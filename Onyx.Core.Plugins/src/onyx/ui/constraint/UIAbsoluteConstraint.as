package onyx.ui.constraint {
	
	import flash.geom.*;
	
	import onyx.ui.core.*;
	
	// TODO, make everything even smaller memory-wise
	
	final public class UIAbsoluteConstraint implements IUIConstraint {
		
		/**
		 * 	@public
		 * 	Stores x,width
		 */
		public var hori:uint;
		
		/**
		 * 	@public
		 * 	Stores y,height
		 */
		public var vert:uint;
		
		/**
		 * 	@public
		 */
		public function unserialize(token:Object):void {
			const tokens:Array	= String(token.bounds).split(',');
			hori				= tokens[0] << 16 | tokens[2];
			vert				= tokens[1] << 16 | tokens[3];
				
		}
		
		/**
		 * 	@public
		 */
		public function measure(parent:UIRect):UIRect {
			
			// set 
			const target:UIRect	= new UIRect();
			target.x			= (hori & 0xFFFF0000) >> 16;
			target.width		= (hori & 0x0000FFFF);
			target.y			= (vert & 0xFFFF0000) >> 16;
			target.height		= (vert & 0x0000FFFF);
			
			return target;
		}
		
		/**
		 * 	@public
		 */
		public function toString():String {
			
			// set 
			const target:UIRect	= new UIRect();
			target.x			= (hori & 0xFFFF0000) >> 16;
			target.width		= (hori & 0x0000FFFF);
			target.y			= (vert & 0xFFFF0000) >> 16;
			target.height		= (vert & 0x0000FFFF);
			
			return '[UIConstraint type=\'absolute\' ' + target.toString() + ']';
		}
	}
}