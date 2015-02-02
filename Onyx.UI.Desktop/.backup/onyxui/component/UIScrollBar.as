package onyxui.core {
	
	import flash.events.*;
	import flash.geom.*;
	
	import onyx.core.*;
	
	import onyxui.assets.*;
	import onyxui.core.*;
	
	final public class UIScrollBar extends UIObject {
	
		/**
		 * 	@private
		 */
		private const track:UISkin		= addChild(new UISkin(UIScrollTrack)) as UISkin;
		private const thumb:UISkin		= addChild(new UISkin(UIScrollThumb)) as UISkin;
		
		private const bounds:Rectangle	= new Rectangle();
		private var down:Number;
		
		override public function initialize():void {
			thumb.addEventListener(MouseEvent.MOUSE_DOWN, handleMouse);
		}
		
		/**
		 * 	@private
		 */
		private function handleMouse(event:MouseEvent):void {
			switch (event.type) {
				case MouseEvent.MOUSE_DOWN:
					
					down = thumb.y - event.stageY;
					
					AppStage.addEventListener(MouseEvent.MOUSE_MOVE, handleMouse);
					AppStage.addEventListener(MouseEvent.MOUSE_UP, handleMouse);
					
					break;
				case MouseEvent.MOUSE_MOVE:
					
					var y:Number = Math.max(Math.min(down + event.stageY, bounds.height - thumb.height), 0)
					
					thumb.moveTo(0, y);
					
					(parent as UIScrollPane).signal(y / bounds.height);
					
					break;
				case MouseEvent.MOUSE_UP:
					AppStage.removeEventListener(MouseEvent.MOUSE_MOVE, handleMouse);
					AppStage.removeEventListener(MouseEvent.MOUSE_UP, handleMouse);
					break;
			}
		}
		
		/**
		 * 	@public
		 */
		public function setRatio(size:Number, pos:Number):void {
			thumb.resize(bounds.width, bounds.height * size);
		}
		
		/**
		 * 	@publci
		 */
		override public function resize(width:int, height:int):void {
			bounds.width	= width;
			bounds.height	= height;
			track.resize(width, height);
			thumb.resize(width, 25);
		}
	}
}