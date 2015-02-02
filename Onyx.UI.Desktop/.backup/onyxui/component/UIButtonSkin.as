package onyxui.component {
	
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	
	import onyx.util.*;
	
	import onyxui.core.*;
	
	final public class UIButtonSkin extends UISkin {
		
		/**
		 * 	@private
		 */
		private static function handleMouse(event:MouseEvent):void {
			const mc:MovieClip	= event.currentTarget as MovieClip;
			switch (event.type) {
				case MouseEvent.ROLL_OVER:
					mc.gotoAndStop(2);
					break;
				case MouseEvent.ROLL_OUT:
					mc.gotoAndStop(1);
					break;
			}
		}
		
		/**
		 * 	@public
		 */
		override protected function initialize():void {
			if (mc) {
				mc.stop();	
			}
		}
		
		/**
		 * 	@public
		 */
		public function setSelected(value:Boolean):void {
			
			if (value) {
				mc.removeEventListener(MouseEvent.ROLL_OUT, handleMouse);
				mc.removeEventListener(MouseEvent.ROLL_OVER, handleMouse);
			} else {
				mc.addEventListener(MouseEvent.ROLL_OVER, handleMouse);
				mc.addEventListener(MouseEvent.ROLL_OUT, handleMouse);
			}
		}
		
		/**
		 *	@public 
		 */
		override public function arrange(rect:Rectangle):void {
			super.arrage(rect);
			
			if (mc) {
				mc.width	= rect.width;
				mc.height	= rect.height;
			}
		}
	}
}