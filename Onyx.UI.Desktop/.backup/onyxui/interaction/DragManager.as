package onyxui.interaction {
	
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	
	import onyx.core.*;
	import onyx.util.*;
	
	import onyxui.core.*;
	
	final public class DragManager {
		
		/**
		 * 	@private
		 */
		private static var current:Bitmap;
		
		/**
		 * 	@private
		 */
		private static var offsetX:int;
		private static var offsetY:int;
		private static var callback:Callback;
		private static var targets:Vector.<UIObject>;
		private static var currentTarget:UIObject;
		
		/**
		 * 	@public
		 */
		public static function start(target:UIObject, e:MouseEvent, itargets:Vector.<UIObject>, icallback:Callback):void {
			
			var rect:Rectangle	= target.getRect(AppStage);
			var data:BitmapData	= new BitmapData(rect.width, rect.height, true, 0);
			data.draw(target);
			
			AppStage.addChild(current = new Bitmap(data));
			
			offsetX		= target.width / 2;
			offsetY		= target.height / 2;
			current.x	= rect.x;
			current.y	= rect.y;
			
			AppStage.addEventListener(MouseEvent.MOUSE_MOVE,	handleMouse);
			AppStage.addEventListener(MouseEvent.MOUSE_UP,		handleMouse);
			
			callback	= icallback;
			targets		= itargets;
			
			for each (var ui:UIObject in targets) {
				ui.addEventListener(MouseEvent.MOUSE_OVER, handleMouse);
				ui.addEventListener(MouseEvent.MOUSE_OUT, handleMouse);
			}

		}
		
		/**
		 * 	@private
		 */
		private static function cleanup():void {
			
			AppStage.removeEventListener(MouseEvent.MOUSE_MOVE,	handleMouse);
			AppStage.removeEventListener(MouseEvent.MOUSE_UP,	handleMouse);
			
			for each (var ui:UIObject in targets) {
				ui.removeEventListener(MouseEvent.MOUSE_OVER, handleMouse);
				ui.removeEventListener(MouseEvent.MOUSE_OUT, handleMouse);
			}
			
			AppStage.removeChild(current);
			
			if (currentTarget) {
				
				currentTarget.transform.colorTransform = UIStyle.TRANSFORM_NONE;
				
				callback.exec(currentTarget);
			}
			
			currentTarget = null;
			current = null;
			targets = null;
		}
		
		/**
		 * 	@private
		 */
		private static function handleMouse(event:Event):void {
			switch (event.type) {
				case MouseEvent.MOUSE_OVER:
					
					(event.currentTarget as UIObject).transform.colorTransform = UIStyle.TRANSFORM_HIGHLIGHT;
					
					currentTarget = event.currentTarget as UIObject;
					
					break;
				case MouseEvent.MOUSE_OUT:
					
					// make sure we aren't within it's bounds
					if (currentTarget.getRect(AppStage).contains(AppStage.mouseX, AppStage.mouseY)) {
						return;
					};
					
					currentTarget.transform.colorTransform = UIStyle.TRANSFORM_NONE;
					currentTarget = null;
					
					break;
				case MouseEvent.MOUSE_MOVE:
					
					current.x	= AppStage.mouseX - offsetX;
					current.y 	= AppStage.mouseY - offsetY;
					
					break;
				case MouseEvent.MOUSE_UP:
					
					cleanup();
					
					break;
			}
		}
	}
}