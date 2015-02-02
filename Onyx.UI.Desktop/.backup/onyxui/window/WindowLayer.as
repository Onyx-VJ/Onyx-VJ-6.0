package onyxui.window {
	
	import flash.display.*;
	import flash.events.*;
	import flash.text.*;
	
	import onyx.core.*;
	import onyx.display.*;
	import onyx.event.*;
	import onyx.host.*;
	
	import onyxui.assets.*;
	import onyxui.core.*;
	import onyxui.window.layer.*;
	
	public final class WindowLayer extends UIObject {
		
		/**
		 * 	@private
		 */
		private var displays:Vector.<IDisplay>	= Onyx.GetDisplays();
		
		/**
		 * 	@private
		 */
		private var selected:UILayer;
		
		/**
		 * 	@private
		 */
		private var current:UILayer;
		
		/**
		 * 	@private
		 */
		private var controls:Vector.<UILayer>	= new Vector.<UILayer>();

		/**
		 * 	@public
		 */
		override public function initialize():void {
			
			super.initialize();
			
			Onyx.addEventListener(OnyxEvent.DISPLAY_CREATE, handler);
			for each (var display:IDisplay in Onyx.GetDisplays()) {
				initDisplay(display);
			}
			
			stage.addEventListener(MouseEvent.MOUSE_UP, removeRef);
		}
		
		/**
		 * 	@private
		 */
		private function initDisplay(display:IDisplay):void {
			for each (var layer:IDisplayLayer in display.getLayers()) {
				createLayer(layer);
			}
			display.addEventListener(OnyxEvent.LAYER_CREATE, handler);
		}
		
		/**
		 * 	@private
		 */
		private function handler(e:OnyxEvent):void {
			switch (e.type) {
				case OnyxEvent.LAYER_CREATE:
					createLayer(e.data as IDisplayLayer);
					break;
				case OnyxEvent.DISPLAY_CREATE:
					initDisplay(e.data as IDisplay);
					break;
			}
		}
		
		/**
		 * 	@private
		 */
		private function handleLayer(event:OnyxEvent):void {
			createLayer(event.data as IDisplayLayer);
		}
		
		/**
		 * 	@private
		 */
		private function createLayer(layer:IDisplayLayer):void {
			
			var control:UILayer = new UILayer(layer);
			control.addEventListener(MouseEvent.MOUSE_DOWN, handleMouse);
			controls.push(control);
			addChild(control);

		}
		
		/**
		 * 	@public
		 */
		public function getControls():Vector.<UIObject> {
			return Vector.<UIObject>(controls);
		}
		
		/**
		 * 	@private
		 */
		private function handleMouse(e:MouseEvent):void {
			current	= e.currentTarget as UILayer;
			if (current.mouseY < 180) {
				
				// listen to all the other controls
				for each (var target:UILayer in controls) {
					if (current !== target) {
						target.addEventListener(MouseEvent.MOUSE_OVER, handleRoll);
					}
				}
			}
		}
		
		/**
		 * 	@private
		 */
		private function handleRoll(e:MouseEvent):void {
//			
//			var target:UILayer	= e.currentTarget as UILayer;
//			if (target.parent === current.layer.parent) {
//				target.layer.parent.swapLayers(current.layer, target.layer);
//			}
		}
		
		/**
		 * 	@private
		 */
		private function removeRef(event:Event):void {
			
			// listen to all the other controls
			for each (var target:UILayer in controls) {
				target.removeEventListener(MouseEvent.MOUSE_OVER, handleRoll);
			}
		}
		
		/**
		 * 	@public
		 */
		override public function dispose():void {
			
			// listen to all the other controls
			for each (var target:UILayer in controls) {
				target.removeEventListener(MouseEvent.MOUSE_OVER,	handleRoll);
				target.removeEventListener(MouseEvent.MOUSE_DOWN,	handleMouse);
				removeChild(target);
			}
			
			// dispose
			super.dispose();
		}
	}
}