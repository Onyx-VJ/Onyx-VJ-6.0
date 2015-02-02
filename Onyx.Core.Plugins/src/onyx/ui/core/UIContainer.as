package onyx.ui.core {
	
	import flash.display.*;
	import flash.events.*;
	
	import onyx.core.*;
	import onyx.ui.factory.*;
	import onyx.util.*;
	
	/**
	 * 	@public
	 */
	public class UIContainer extends UIObject {
		
		/**
		 * 	@protected
		 */
		public var bounds:UIRect;
		
		/**
		 * 	@public
		 */
		override public function addChild(child:DisplayObject):DisplayObject {
			return addChildAt(child, numChildren);
		}
		
		/**
		 * 	@public
		 */
		override public function addChildAt(child:DisplayObject, index:int):DisplayObject {
			var item:DisplayObject		= super.addChildAt(child, index);
			if (item is UIObject) {
				invalidateChildren();
			}
			return item;
		}
		
		/**
		 * 	@private
		 */
		final protected function invalidateChildren():void {
			
			application.invalidate(new Callback(arrangeChildren));
			
		}
		
		/**
		 * 	@public
		 */
		override public function arrange(rect:UIRect):void {
			
			// arrange
			super.arrange(rect);
			
			// are we an changed size?
			if (!bounds || bounds.width !== rect.width || bounds.height !== rect.height) {
				
				// invalidate?
				bounds = rect.identity();
				
				// invalidate?
				invalidateChildren();
				
			}
		}
		
		/**
		 * 	@public
		 */
		public function arrangeChildren():void {
			
			if (!bounds) {
				return application.invalidate(new Callback(arrangeChildren));
			}
			
			const numChildren:int = this.numChildren;
			for (var count:int = 0; count < numChildren; ++count) {
				var ui:IUIObject = getChildAt(count) as IUIObject;
				if (ui) {
					ui.measure(bounds);
				}
			}
		}
	}
}