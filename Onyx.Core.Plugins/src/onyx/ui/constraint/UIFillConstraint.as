package onyx.ui.constraint {
	
	import onyx.ui.core.*;
	
	public final class UIFillConstraint implements IUIConstraint {
		
		/**
		 * 	@public
		 */
		public function unserialize(token:Object):void {
		}
		
		/**
		 * 	@public
		 */
		public function measure(parent:UIRect):UIRect {
			return parent.identity();
		}
	}
}