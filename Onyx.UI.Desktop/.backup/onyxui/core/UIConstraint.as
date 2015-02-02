package onyxui.core {
	
	import flash.geom.*;
	
	// TODO, make everything a bit smaller memory-wise
	
	final public class UIConstraint {
		
		public var left:Number;
		public var top:Number;
		public var right:Number;
		public var bottom:Number;
		
		public var width:Number;
		public var height:Number;
		
		/**
		 * 	@public
		 */
		public function unserialize(token:Object):void {
			
			if (!token) {
				return;
			}
			
			top		= isNaN(top)	? (token.top !== undefined)		?	token.top : NaN		: top;
			left	= isNaN(left)	? (token.left !== undefined)	?	token.left : NaN	: left;
			right	= isNaN(right)	? (token.right !== undefined)	?	token.right : NaN	: right;
			bottom	= isNaN(bottom)	? (token.bottom !== undefined)	?	token.bottom : NaN	: bottom;
			width	= isNaN(width)	? (token.width !== undefined)	?	token.width: NaN	: width;
			height	= isNaN(height)	? (token.height !== undefined)	?	token.height : NaN	: height;

		}
		
		/**
		 * 	@public
		 */
		public function measure(parent:Rectangle):Rectangle {
			
			const target:Rectangle	= new Rectangle();
			
			// explicit width
			if (isNaN(width) && !isNaN(left) && !isNaN(right)) {
				target.width	= parent.width - left - right;
			} else if (!isNaN(width)) {
				target.width	= width;
			}
			
			// explicit height
			if (isNaN(height) && !isNaN(bottom) && !isNaN(top)) {
				target.height	= parent.height - bottom - top;
			} else if (!isNaN(height)) {
				target.height	= height;
			}
			
			if (isNaN(left) && !isNaN(right) && target.width) {
				target.x		= parent.width - target.width - right;
			} else if (!isNaN(left)) {
				target.x 		= left;
			}
			
			if (isNaN(top) && !isNaN(bottom) && target.height) {
				target.y = parent.height - target.height - bottom;
			} else if (!isNaN(top)) {
				target.y = top;
			}
			
			return target;
		}
		
		CONFIG::DEBUG {
			public function toString():String {
				return '[UIConstraint: ' + ['left:'+ left, 'top:'+ top, 'right:'+ right, 'bottom:'+ bottom, 'width:'+ width, 'height:'+ height].join(' ') + ']';
			}
		}
	}
}