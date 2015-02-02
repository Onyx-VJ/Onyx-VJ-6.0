package onyxui.renderer {

	import flash.display.*;
	import flash.text.*;
	
	import onyx.core.*;
	import onyx.plugin.*;
	
	import onyxui.assets.*;
	import onyxui.core.*;
	
	public final class UIRendererIcon extends UIRenderer {
		
		/**
		 * 	@private
		 */
		private var icon:DisplayObject;
		
		/**
		 * 	@public
		 */
		override public function set data(data:*):void {
			
			var plugin:IPluginDefinition = data as IPluginDefinition;
			
			while (numChildren > 0) {
				removeChildAt(0);
			}
			
			if (plugin) {
				icon = plugin.icon;
				if (icon) {
					addChild(icon);
				}
			}
		}
		
		/**
		 * 	@public
		 */
		override public function resize(width:int, height:int):void {
			
//			if (icon) {
//				icon.width	= width;
//				icon.height	= height;
//			}
			super.resize(width, height);
			
		}
	}

}