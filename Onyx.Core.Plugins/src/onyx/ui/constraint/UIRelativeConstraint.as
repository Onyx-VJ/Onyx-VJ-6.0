package onyx.ui.constraint {
	
	import flash.geom.*;
	
	import onyx.ui.core.*;
	
	// TODO, make everything even smaller memory-wise
	
	final public class UIRelativeConstraint implements IUIConstraint {
		
		/**
		 * 	@public
		 */
		public static const AUTO:int		= int.MIN_VALUE;
		
		/**
		 * 	@public
		 */
		public var left:int;
		
		/**
		 * 	@public
		 */
		public var top:int;
		
		/**
		 * 	@public
		 */
		public var right:int;
		
		/**
		 * 	@public
		 */
		public var bottom:int;
		
		/**
		 * 	@public
		 */
		public var width:int;
		
		/**
		 * 	@public
		 */
		public var height:int;
		
		/**
		 * 	@public
		 */
		public function unserialize(token:Object):void {
			
			top		= isNaN(token.top)		?	int.MIN_VALUE	: token.top;
			left	= isNaN(token.left)		?	int.MIN_VALUE	: token.left;
			right	= isNaN(token.right)	?	int.MIN_VALUE	: token.right;
			bottom	= isNaN(token.bottom)	?	int.MIN_VALUE	: token.bottom;
			width	= isNaN(token.width)	?	int.MIN_VALUE	: token.width;
			height	= isNaN(token.height)	?	int.MIN_VALUE	: token.height;

		}
		
		/**
		 * 	@public
		 */
		public function measure(parent:UIRect):UIRect {
			
			// set 
			const target:UIRect	= new UIRect();
			
			// explicit width
			if (left !== int.MIN_VALUE && right !== int.MIN_VALUE) {
				target.width	= parent.width - left - right;
			} else if (width !== int.MIN_VALUE) {
				target.width	= width;
			}
			
			// explicit height
			if (top !== int.MIN_VALUE && bottom !== int.MIN_VALUE) {
				target.height	= parent.height - bottom - top;
			} else if (height !== int.MIN_VALUE) {
				target.height	= height;
			}
			
			//
			if (left === int.MIN_VALUE && right !== int.MIN_VALUE && target.width !== int.MIN_VALUE) {
				target.x		= parent.width - target.width - right;
			} else if (left !== int.MIN_VALUE ) {
				target.x 		= left;
			}
			
			if (top === int.MIN_VALUE && bottom !== int.MIN_VALUE && target.height !== int.MIN_VALUE) {
				target.y = parent.height - target.height - bottom;
			} else if (top !== int.MIN_VALUE) {
				target.y = top;
			}
			
			return target;
		}
		
		public function toString():String {
			return '[UIConstraint: ' + [top,left,right,bottom,width,height].toString();
		}
	}
}