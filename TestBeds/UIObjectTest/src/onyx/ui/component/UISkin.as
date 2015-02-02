package onyx.ui.component {
	
	import flash.display.*;
	
	import onyx.ui.core.*;
	
	use namespace skin;

	final public class UISkin extends UIObject {
		
		/**
		 * 	@private
		 */
		skin var skinObject:DisplayObject;
		
		/**
		 * 	@public
		 */
		override public function arrange(rect:UIObjectBounds):void {
			
			super.arrange(rect);
			
			if (skinObject) {
				skinObject.width	= bounds.width;
				skinObject.height	= bounds.height;
			}
		}
	}
}