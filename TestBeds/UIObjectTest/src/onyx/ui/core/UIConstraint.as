package onyx.ui.core {
	
	import flash.geom.*;
	
	// TODO, make everything a bit smaller memory-wise
	
	final public class UIConstraint {
		
		public var left:int			= int.MIN_VALUE;
		public var top:int			= int.MIN_VALUE;
		public var right:int		= int.MIN_VALUE;
		public var bottom:int		= int.MIN_VALUE;
		
		// size
		public var width:int		= int.MIN_VALUE;	
		public var height:int		= int.MIN_VALUE;
		
		/**
		 * 	@public
		 */
		public function unserialize(token:Object):void {
			
			if (!token) {
				return;
			}
			
			top		= (top === int.MIN_VALUE)		? (token.top !== undefined)		?	token.top : int.MIN_VALUE		: top;
			left	= (left === int.MIN_VALUE)		? (token.left !== undefined)	?	token.left : int.MIN_VALUE	: left;
			right	= (right === int.MIN_VALUE)		? (token.right !== undefined)	?	token.right : int.MIN_VALUE	: right;
			bottom	= (bottom === int.MIN_VALUE)	? (token.bottom !== undefined)	?	token.bottom : int.MIN_VALUE	: bottom;
			width	= (width === int.MIN_VALUE)		? (token.width !== undefined)	?	token.width: int.MIN_VALUE	: width;
			height	= (height === int.MIN_VALUE)	? (token.height !== undefined)	?	token.height : int.MIN_VALUE	: height;

		}
		
		/**
		 * 	@public
		 */
		public function measure(parent:UIObjectBounds):UIObjectBounds {
			
			// set 
			const target:UIObjectBounds	= new UIObjectBounds();
			
			// explicit width
			if (width === int.MIN_VALUE && left >= 0 && right >= 0) {
				target.width	= parent.width - left - right;
			} else if (width !== int.MIN_VALUE) {
				target.width	= width;
			}
			
			// explicit height
			if (height === int.MIN_VALUE && bottom >= 0 && top >= 0) {
				target.height	= parent.height - bottom - top;
			} else if (height !== int.MIN_VALUE) {
				target.height	= height;
			}
			
			if (left === int.MIN_VALUE && right >= 0 && target.width >= 0) {
				target.x		= parent.width - target.width - right;
			} else if (left !== int.MIN_VALUE ) {
				target.x 		= left;
			}
			
			if (top === int.MIN_VALUE && bottom >= 0 && target.height >= 0) {
				target.y = parent.height - target.height - bottom;
			} else if (top !== int.MIN_VALUE) {
				target.y = top;
			}
			
			trace('measure', parent, target);
			
			return target;
		}
	}
}