package onyxui.component {
	
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	
	import onyx.core.*;
	import onyx.parameter.*;
	
	import onyxui.component.*;
	import onyxui.core.*;
	
	public class UIContainer extends UIObject {
		
		/**
		 * 	@public
		 */
		public const bounds:Rectangle = new Rectangle();
		
		/**
		 * 	@protected
		 */
		override protected function initialize():void {
			arrangeChildren();
		}
		
		/**
		 * 	@public
		 */
		override final public function addChild(dsp:DisplayObject):DisplayObject {
			return addChildAt(dsp, numChildren);
		}
		
		/**
		 * 	@public
		 */
		override final public function addChildAt(dsp:DisplayObject, index:int):DisplayObject {
			const ui:UIObject	= dsp as UIObject;
			if (parent && ui) {
				ui.arrange(ui.constraint.measure(bounds));
			}
			return super.addChildAt(dsp, index);
		}
		
		/**
		 * 	@protected
		 */
		protected function moveToFront():void {
			parent.setChildIndex(this, parent.numChildren - 1);
		}

		/**
		 * 	@public
		 */
		public function removeAllChildren():void {
			while (numChildren) {
				var disposable:IDisposable = removeChildAt(0) as IDisposable;
				if (disposable) {
					disposable.dispose();
				}
			}
		}
		
		/**
		 * 	@public
		 */
		override public function arrange(rect:Rectangle):void {

			x = bounds.x = rect.x;
			y = bounds.y = rect.y;

			if (bounds.width === rect.width && bounds.height === rect.height) {
				return;
			}
			
			bounds.width	= rect.width;
			bounds.height	= rect.height;
			
			// arrange children again
			arrangeChildren();
		}
		
		/**
		 * 	@private
		 */
		private function arrangeChildren():void {
			
			for (var count:int = numChildren - 1; count >= 0; --count) {
				var ui:UIObject = this.getChildAt(count) as UIObject;
				if (ui) {
					ui.arrange(ui.constraint.measure(bounds));
				}
			}
		}
//		
//		/**
//		 * 	@public
//		 */
//		override public function resize(width:int, height:int):void {
////			
////			// loop and deal with children
////			const factory:UIFactory			= UIFactory.DEFINITIONS[Object(this).constructor];
////			var bounds:Rectangle			= new Rectangle();
////			
////			for each (var def:UIFactory in factory.children) {
////				
////				var obj:UIObject			= def.createInstance();
////				def.constraint.measure(this, bounds);
////				
////				obj.moveTo(bounds.x,		bounds.y);
////				obj.resize(bounds.width,	bounds.height);
////				
////			}
//
//		}
	}
}