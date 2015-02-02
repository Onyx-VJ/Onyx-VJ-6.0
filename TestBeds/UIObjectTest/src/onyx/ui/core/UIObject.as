package onyx.ui.core {
	
	import avmplus.*;
	
	import flash.display.*;
	import flash.events.*;
	import flash.utils.*;
	
	import onyx.ui.core.*;
	import onyx.ui.utils.*;
	
	use namespace skin;

	public class UIObject extends Sprite {
		
		/**
		 * 	@protected
		 */
		public var bounds:UIObjectBounds;
		
		/**
		 * 	@protected
		 */
		public const constraint:UIConstraint = new UIConstraint();

		/**
		 * 	@public
		 */
		public function initialize(data:Object):void {}
		
		/**
		 * 	@public
		 */
		public function arrange(rect:UIObjectBounds):void {
			
			bounds	= rect;
			x		= rect.x;
			y		= rect.y;
			
			// arrange
			arrangeChildren();
		}
		
		/**
		 * 	@public
		 */
		public function arrangeChildren():void {
			
			const numChildren:int = this.numChildren;
			for (var count:int = 0; count < numChildren; ++count) {
				var ui:UIObject = getChildAt(count) as UIObject;
				if (ui) {
					ui.arrange(ui.constraint.measure(this.bounds));
				}
			}
			
		}
		
		/**
		 * 	@public
		 */
		public function createChildren(children:Array):void {}
		
		/**
		 * 	@protected
		 */
		public function addSkinPart(id:QName, item:UIObject):void {
			
			if (id) {
				this[id]	= item;
			}
			
			super.addChild(item);
		}
		
		/**
		 * 	@protected
		 */
		public function dispose():void {} 
	}
}