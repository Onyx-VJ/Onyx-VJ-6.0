package onyxui.factory {
	
	import onyxui.component.*;
	import onyxui.core.*;

	public final class UIFactoryWindow implements IUIFactory {
		
		/**
		 * 	@private
		 */
		private static const window:UIFactory	= new UIFactory(UIWindow);
		
		/**
		 * 	@private
		 */
		private var content:UIFactory;
		
		/**
		 * 	@public
		 */
		public function UIFactoryWindow(c:Class):void {
			content	= new UIFactory(c);
		}
		
		/**
		 * 	@public
		 */
		public function createInstance():UIObject {
			
			var obj:UIWindow		= window.createInstance({
				left:	data.left,
				right:	data.right,
				bottom:	data.bottom,
				top:	data.top,
				width:	data.width,
				height:	data.height
			});
			obj.unserialize(content.data.PluginInfo);
						
			var child:UIObject		= content.createInstance();
			child.unserialize({
				top:		18,
				bottom:		10,
				right:		10,
				left:		10
			});
			obj.addChild(child);

			return obj;
		}
	}
}