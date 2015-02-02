package onyxui.component {
	
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.utils.*;
	
	import onyx.core.*;
	
	import onyxui.assets.*;
	import onyxui.component.*;
	import onyxui.core.*;
	
	use namespace skin;
	
	[UISkinPart(id='skin',		definition='onyxui.component::UISkin',				top='0', left='0', right='0', bottom='0',	skin='onyxui.assets::UIAssetWindowSkin')]
	[UISkinPart(id='title',		definition='onyxui.component::UITextField',			top='2', left='2', right='2', height='15')]

	// TODO, this should be final!
	final public class UIWindow extends UIContainer {
		
		/**
		 * 	@private
		 */
		private static var drag:Point;

		/**
		 * 	@protected
		 */
		skin var title:UITextField;
		
		/**
		 * 	@protected
		 */
		skin var skin:UISkin;
		
		/**
		 * 	@public
		 */
		public function setDraggable(value:Boolean):void {
			if (value) {
				addEventListener(MouseEvent.MOUSE_DOWN, handleMouse);
			}
		}
		
		/**
		 * 	@protected
		 */
		override protected function initialize():void {
			
			// get transform
			this.skin.transform.colorTransform	= UIStyle.TRANSFORM_DEFAULT;
			
			// click goes to top
			addEventListener(MouseEvent.CLICK, handleMouse);
			
		}
		
		/**
		 * 	@public
		 */
		override public function unserialize(token:Object):void {
			
			// unserialize
			super.unserialize(token);
			
			if (token.title) {
				title.text = token.title;
			}
		}
		
		/**
		 * 	@private
		 */
		private function handleMouse(event:MouseEvent):void {
			switch (event.type) {
				case MouseEvent.CLICK:
					
					// event.stopPropagation();
					moveToFront();
					
					break;
				case MouseEvent.MOUSE_DOWN:
					
					if (event.localY < 12) {
						AppStage.addEventListener(MouseEvent.MOUSE_MOVE,	handleMouse);
						AppStage.addEventListener(MouseEvent.MOUSE_UP,		handleMouse);
						
						drag = new Point(mouseX, mouseY);
						moveToFront();

					}
					break;
				case MouseEvent.MOUSE_MOVE:
					
					constraint.top	= event.stageX - drag.x;
					constraint.left	= event.stageY - drag.y;
					
					// arrange(constraint.measure(parentContainer.bounds));
					
					break;
				case MouseEvent.MOUSE_UP:
					
					AppStage.removeEventListener(MouseEvent.MOUSE_MOVE, 	handleMouse);
					AppStage.removeEventListener(MouseEvent.MOUSE_UP,		handleMouse);
					
					break;
			}
		}
		
		/**
		 * 	@public
		 */
		override public function dispose():void {
			
			// click goes to top
			removeEventListener(MouseEvent.CLICK, handleMouse);
			
			// dispose
			super.dispose();
		}
	}
}