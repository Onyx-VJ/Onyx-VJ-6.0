package onyx.ui.constraint {
	
	import flash.geom.*;
	
	import onyx.ui.core.*;
	
	// TODO, make everything even smaller memory-wise
	
	final public class UIPercentConstraint implements IUIConstraint {
		
		public var percentWidth:Number;
		public var percentHeight:Number;
		public var percentLeft:Number;
		public var percentTop:Number;
		
		public var width:int;
		public var height:int;
		public var left:int;
		public var top:int;
		public var right:int;
		public var bottom:int;
		
		/**
		 * 	@public
		 */
		public function unserialize(token:Object):void {
			
			top			= isNaN(token.top)		?	int.MIN_VALUE	: token.top;
			left		= isNaN(token.left)		?	int.MIN_VALUE	: token.left;
			right		= isNaN(token.right)	?	int.MIN_VALUE	: token.right;
			bottom		= isNaN(token.bottom)	?	int.MIN_VALUE	: token.bottom;
			width		= isNaN(token.width)	?	int.MIN_VALUE	: token.width;
			height		= isNaN(token.height)	?	int.MIN_VALUE	: token.height;
			
			if (token.width) {
				var str:String = token.width;
				if (str.charAt(str.length - 1) === '%') {
					percentWidth = Number(str.substr(0, -1)) / 100;
				}
			}
			
			if (token.height) {
				str	= token.height;
				if (str.charAt(str.length - 1) === '%') {
					percentHeight = Number(str.substr(0, -1)) / 100;
				}
			}
			
			if (token.left) {
				str = token.left;
				if (str.charAt(str.length - 1) === '%') {
					percentLeft = Number(str.substr(0, -1)) / 100;
				}
			}
			if (token.top) {
				str = token.top;
				if (str.charAt(str.length - 1) === '%') {
					percentTop = Number(str.substr(0, -1)) / 100;
				}
			}
		}
		
		/**
		 * 	@public
		 */
		public function measure(parent:UIRect):UIRect {
			
			// set 
			const target:UIRect	= new UIRect();
			
			target.width		= isNaN(percentWidth) ? width : parent.width * percentWidth;
			target.height		= isNaN(percentHeight) ? height : parent.height * percentHeight;
			target.x			= isNaN(percentLeft) ? left : parent.width * percentLeft;
			target.y			= isNaN(percentTop) ? top : parent.height * percentHeight;
			
			// explicit width
			if (!isNaN(percentWidth)) {
				target.width	= parent.width * percentWidth;
			} else if (left !== int.MIN_VALUE && right !== int.MIN_VALUE) {
				target.width	= parent.width - left - right;
			} else if (width !== int.MIN_VALUE) {
				target.width	= width;
			}
			
			// explicit height
			if (!isNaN(percentHeight)) {
				target.height	= parent.height * percentHeight;
			} else if (top !== int.MIN_VALUE && bottom !== int.MIN_VALUE) {
				target.height	= parent.height - bottom - top;
			} else if (height !== int.MIN_VALUE) {
				target.height	= height;
			}
			
			if (!isNaN(percentLeft)) {
				target.x	= parent.width * percentLeft;
			} else if (left === int.MIN_VALUE && right !== int.MIN_VALUE && target.width !== int.MIN_VALUE) {
				target.x		= parent.width - target.width - right;
			} else if (left !== int.MIN_VALUE ) {
				target.x 		= left;
			} else {
				target.x		= 0;
			}
			
			if (!isNaN(percentTop)) {
				target.y	= parent.height * percentTop;
			} else if (top === int.MIN_VALUE && bottom !== int.MIN_VALUE && target.height !== int.MIN_VALUE) {
				target.y = parent.height - target.height - bottom;
			} else if (top !== int.MIN_VALUE) {
				target.y	= top;
			} else {
				target.y	= 0;
			}
			
			return target;
		}
	}
}