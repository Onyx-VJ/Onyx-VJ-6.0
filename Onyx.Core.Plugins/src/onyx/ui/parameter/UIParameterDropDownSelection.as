package onyx.ui.parameter {

	import flash.display.*;
	
	import onyx.core.*;
	import onyx.parameter.*;
	import onyx.ui.component.*;
	import onyx.ui.core.*;
	import onyx.ui.factory.*;
	import onyx.ui.renderer.*;
	
	use namespace skinPart;
	
	[UISkinPart(id='selection',	type='skin',	transform='theme::default',	constraint='relative', left='0', right='0', top='0', bottom='0', skinClass='DropDownBackground')]

	public final class UIParameterDropDownSelection extends UIObject {
	
		/**
		 * 	@public
		 */
		skinPart var selection:UISkin;
		
		/**
		 * 	@private
		 */
		private var bounds:UIRect;
		
		/**
		 * 	@public
		 */
		override public function initialize(data:Object):void {
			
			super.initialize(data);
			
			this.transform.colorTransform	= UIStyleManager.TRANSFORM_DEFAULT;

		}
		
		/**
		 * 	@public
		 */
		override public function arrange(rect:UIRect):void {
			
			super.arrange(rect);
			
			selection.arrange(bounds = rect.identity());
		}
		
		/**
		 * 	@public
		 */
		public function show(data:IParameterIterator, factory:UIFactory):void {
			
			var y:int = 1;
			while (numChildren > 1) {
				removeChildAt(1);
			}
			
			for each (var obj:* in data.iterator) {
				
				var item:UIRenderer	= addChild(factory.createInstance()) as UIRenderer;
				item.update(data, obj);
				item.arrange(new UIRect(1, y, bounds.width, 16));
				
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