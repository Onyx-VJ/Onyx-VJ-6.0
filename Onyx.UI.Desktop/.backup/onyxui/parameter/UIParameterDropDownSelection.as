package onyxui.parameter {

	import flash.display.*;
	
	import onyx.core.*;
	import onyx.parameter.*;
	
	import onyxui.assets.*;
	import onyxui.core.*;
	import onyxui.renderer.*;
	
	public final class UIParameterDropDownSelection extends UIObject {
		
		/**
		 * 	@public
		 */
		private const selection:DisplayObject		= addChild(new UIDropDownDropBackground());
		
		/**
		 * 	@public
		 */
		override public function resize(width:int, height:int):void {
			
			selection.width	= width;
			selection.height	= height;

		}
		
		/**
		 * 	@public
		 */
		public function show(data:IParameterIterator, renderer:Class):void {
			
			var y:int = 1;
			while (numChildren > 1) {
				removeChildAt(1);
			}
			
			for each (var obj:Object in data.iterator) {
				
				var item:UIRenderer	= new renderer();
				item.data			= obj;
				
				item.resize(selection.width - 1, 16);
				item.moveTo(1, y);
				
				addChild(item);
				
				y += 16;
			}
		}
		
		/**
		 * 	@public
		 */
		public function getSelectedIndex():int {
			if (mouseX < 0 || mouseX > width || mouseY < 0 || mouseY > height) {
				return -1;
			}
			
			return (mouseY / 16) >> 0;
		}
	}
}