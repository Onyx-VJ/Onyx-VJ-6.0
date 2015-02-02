package onyx.ui.core {
	
	import avmplus.*;
	
	import flash.display.*;
	import flash.events.*;
	import flash.utils.*;
	
	import onyx.core.*;
	import onyx.ui.constraint.*;
	import onyx.ui.core.*;
	import onyx.ui.factory.*;
	
	use namespace skinPart;

	public class UIObject extends Sprite implements IUIObject {
		
		/**
		 * 	@protected
		 */
		CONFIG::DEBUG	public var constraint:IUIConstraint;
		CONFIG::RELEASE protected var constraint:IUIConstraint;

		/**
		 * 	@public
		 */
		public function initialize(data:Object):void {
			
			if (data.constraint) {
				switch (data.constraint.type) {
					case 'fill':
						constraint = new UIFillConstraint();
						break;
					case 'relative':
						constraint = new UIRelativeConstraint();
						constraint.unserialize(data.constraint);
						break;
					case 'absolute':
						constraint	= new UIAbsoluteConstraint();
						constraint.unserialize(data.constraint);
						break;
				}
			}
			
			// children?
			var children:Array = data.skins;
			
			// create the children?
			if (children) {
				for each (var child:Object in children) {
					addSkinPart(child.id, UIFactoryDefinitions.CreateInstance(child.type, child));
				}
			}
		}
		
		/**
		 * 	@protected
		 */
		CONFIG::DEBUG protected function drawRect(rect:UIRect, color:uint = 0xFFCC00):void {
			const g:Graphics = this.graphics;
			g.clear();
			g.lineStyle(0, color, 0.8);
			g.drawRect(0, 0, rect.width, rect.height);
		}
		
		/**
		 * 	@public
		 */
		public function get application():UIStage {
			return stage.getChildByName('STAGE') as UIStage;
		}
		
		/**
		 * 	@public
		 */
		public function arrangeSkins(rect:UIRect):void {
			
			const numChildren:int = this.numChildren;
			for (var count:int = 0; count < numChildren; ++count) {
				var ui:IUIObject = getChildAt(count) as IUIObject;
				if (ui) {
					ui.measure(rect);
				}
			}
		}
		
		/**
		 * 	@public
		 */
		public function measure(parent:UIRect):UIRect {

			// if constraint?
			if (constraint) {
				var bounds:UIRect	= constraint.measure(parent); 
				arrange(bounds);
				return bounds;
			}
			
			return null;
		}
		
		/**
		 * 	@public
		 */
		public function setSize(width:int, height:int):void {} 
		
		/**
		 * 	@public
		 */
		public function arrange(rect:UIRect):void {
			
			x		= rect.x;
			y		= rect.y;
			
		}
		
		/**
		 * 	@protected
		 */
		public function addSkinPart(id:String, item:IUIObject):void {
			if (id) {
				this[id]	= item;
			}
			
			super.addChild(item as UIObject);

		}
		
		/**
		 * 	@public
		 */
		public function destroyChildren():void {
			
			const children:int = this.numChildren - 1;
			while (children-- >= 0) {
				
				var child:IDisposable	= getChildAt(0) as IDisposable;
				if (child) {
					child.dispose();
				}
				removeChildAt(0);
			}
			
		}

		/**
		 * 	@protected
		 */
		public function dispose():void {
			
			var children:int = this.numChildren - 1;
			while (children-- >= 0) {
				
				var child:IDisposable	= getChildAt(0) as IDisposable;
				if (child) {
					child.dispose();
				}
				removeChildAt(0);
			}
		}
	}
}