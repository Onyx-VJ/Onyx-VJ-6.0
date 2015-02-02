package onyx.ui.interaction {
	
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.utils.Dictionary;
	
	import onyx.core.*;
	import onyx.ui.core.*;
	import onyx.ui.event.*;
	import onyx.util.*;
	
	final public class DragManager {
		
		/**
		 * 	@public
		 */
		public static const GENERATOR:uint		= 0x00000001;
		
		/**
		 * 	@public
		 */
		public static const FILTER_CPU:uint		= 0x00000002;
		public static const FILTER_GPU:uint		= 0x00000003;
		
		/**
		 * 	@private
		 * 	The drag proxy
		 */
		private static var dragProxy:Bitmap;
		
		/**
		 * 	@private
		 * 	The current item currently being dragged over
		 */
		private static var currentDragOver:UIObject;
		private static var currentType:uint;
		
		/**
		 * 	@private
		 */
		private static var offsetX:int;
		private static var offsetY:int;
		private static var targets:Dictionary;
		private static var data:*;
		
		/**
		 * 	@private
		 */
		private static const objectHash:Object	= {};
		
		/**
		 * 	@public
		 */
		public static function registerTarget(target:UIObject, type:uint, data:* = null):void {
			var dict:Dictionary	= objectHash[type];
			if (!dict) {
				dict = objectHash[type] = new Dictionary(true);	
			}
			
			// store data we want to pass over
			dict[target]		= data;
		}
		
		/**
		 * 	@public
		 */
		public static function unregisterTarget(target:UIObject, type:uint):void {
			var dict:Dictionary	= objectHash[type];
			if (dict && dict[target]) {
				delete dict.target;
			}
		}
		
		/**
		 * 	@public
		 */
		public static function startDrag(type:uint, data:*, e:MouseEvent, target:UIObject = null):void {
			
			if (!target) {
				target = e.currentTarget as UIObject; 
			}
			
			if (!target) {
				return;
			}
			
			// store the current type of drag
			currentType				= type;
			
			// store
			DragManager.data		= data;
			
			var rect:Rectangle		= target.getRect(AppStage);
			var proxy:BitmapData	= new BitmapData(rect.width, rect.height, true, 0);
			proxy.draw(target, null, new ColorTransform(1,1,1,.8));
			
			AppStage.addChild(dragProxy = new Bitmap(proxy));
			
			offsetX		= target.width / 2;
			offsetY		= target.height / 2;
			dragProxy.x	= rect.x;
			dragProxy.y	= rect.y;
			
			AppStage.addEventListener(MouseEvent.MOUSE_MOVE,	handleMouse);
			AppStage.addEventListener(MouseEvent.MOUSE_UP,		handleMouse);
			
			targets = objectHash[type];	
			for (var i:Object in targets) {
				var ui:UIObject = i as UIObject;
				ui.addEventListener(MouseEvent.MOUSE_OVER,	handleMouse);
				ui.addEventListener(MouseEvent.MOUSE_OUT,	handleMouse);
			}

		}
		
		/**
		 * 	@private
		 */
		private static function cleanup():void {
			
			AppStage.removeEventListener(MouseEvent.MOUSE_MOVE,	handleMouse);
			AppStage.removeEventListener(MouseEvent.MOUSE_UP,	handleMouse);
			
			for (var i:Object in targets) {
				var ui:UIObject = i as UIObject;
				ui.removeEventListener(MouseEvent.MOUSE_OVER,	handleMouse);
				ui.removeEventListener(MouseEvent.MOUSE_OUT,	handleMouse);
			}
			
			AppStage.removeChild(dragProxy);
			
			if (currentDragOver) {
				currentDragOver.dispatchEvent(new DragEvent(DragEvent.DRAG_DROP, currentType, data, targets[currentDragOver]));
			}
			
			currentDragOver = null;
			dragProxy	= null;
			targets		= null;
			data		= null;
		}
		
		/**
		 * 	@private
		 */
		private static function handleMouse(event:Event):void {
			
			switch (event.type) {
				case MouseEvent.MOUSE_OVER:
					
					if (currentDragOver) {
						currentDragOver.dispatchEvent(new DragEvent(DragEvent.DRAG_OUT, currentType));
					}
					
					currentDragOver = event.currentTarget as UIObject;
					currentDragOver.dispatchEvent(new DragEvent(DragEvent.DRAG_OVER, currentType));
					
					break;
				case MouseEvent.MOUSE_OUT:
					
					// make sure we aren't within it's bounds
					if (currentDragOver.getRect(AppStage).contains(AppStage.mouseX, AppStage.mouseY)) {
						return;
					};

					currentDragOver.dispatchEvent(new DragEvent(DragEvent.DRAG_OUT, currentType));
					currentDragOver = null;
					
					break;
				case MouseEvent.MOUSE_MOVE:
					
					dragProxy.x		= AppStage.mouseX - offsetX;
					dragProxy.y 	= AppStage.mouseY - offsetY;
					
					break;
				case MouseEvent.MOUSE_UP:
					
					cleanup();
					
					break;
			}
		}
	}
}