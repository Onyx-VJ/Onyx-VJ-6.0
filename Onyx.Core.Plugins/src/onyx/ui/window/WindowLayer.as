package onyx.ui.window {
	
	import flash.display.*;
	import flash.events.*;
	import flash.text.*;
	import flash.utils.*;
	
	import onyx.core.*;
	import onyx.display.*;
	import onyx.event.*;
	import onyx.host.*;
	import onyx.ui.component.*;
	import onyx.ui.core.*;
	import onyx.ui.factory.*;
	import onyx.ui.window.channel.*;
	import onyx.ui.window.layer.*;
	
	use namespace skinPart;
	
	[UIComponent(id='Onyx.UI.Desktop.Layers')]
	
	public final class WindowLayer extends UIContainer {
		
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
		private var layers:Dictionary	= new Dictionary(true);

		/**
		 * 	@public
		 */
		override public function initialize(data:Object):void {
			
			super.initialize(data);

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
			
			var layerDisplay:UILayer	= UIFactoryDefinitions.CreateInstance('Onyx.UI.Desktop.Layers::Layer');
			layerDisplay.addEventListener(MouseEvent.MOUSE_DOWN, handleMouse);
			addChild(layers[layer] = layerDisplay);

			layerDisplay.attach(layer);
			layer.addEventListener(OnyxEvent.LAYER_MOVE, handleMove);

		}
		
		/**
		 * 	@private
		 */
		private function handleMove(e:Event):void {
			var layer:IDisplayLayer = e.currentTarget as IDisplayLayer;
			(layers[layer] as UILayer).arrange(new UIRect(layer.index * 265,0,258,303));
		}
		
		/**
		 * 	@public
		 */
		override public function arrangeChildren():void {
			
			const numChildren:int		= this.numChildren;
			const rect:UIRect	= new UIRect(0, 0, 258, 303);
			for (var count:int = 0; count < numChildren; ++count) {
				var ui:UIObject = getChildAt(count) as UIObject;
				ui.arrange(rect);
				
				rect.x	+= rect.width + 7;
			}
		}
		
		/**
		 * 	@private
		 */
		private function handleMouse(e:MouseEvent):void {
			
			// handle mouse
			current	= e.currentTarget as UILayer;
			
			// only drag
			if (current.mouseY < 180) {
				
				// listen to all the other controls
				for each (var target:UILayer in layers) {
					if (current !== target) {
						target.addEventListener(MouseEvent.MOUSE_OVER, handleRollOver);
					}
				}
			}
		}
		
		/**
		 * 	@private
		 */
		private function handleRollOver(e:MouseEvent):void {
			var target:UILayer	= e.currentTarget as UILayer;
			target.getLayer().parent.swapLayers(current.getLayer(), target.getLayer());
		}
		
		/**
		 * 	@private
		 */
		private function removeRef(event:Event):void {
			
			// listen to all the other controls
			for each (var target:UILayer in layers) {
				target.removeEventListener(MouseEvent.MOUSE_OVER, handleRollOver);
			}
		}
		
		/**
		 * 	@public
		 */
		override public function dispose():void {
			
			// listen to all the other layers
			for each (var target:UILayer in layers) {
				target.removeEventListener(MouseEvent.MOUSE_OVER,	handleRollOver);
				target.removeEventListener(MouseEvent.MOUSE_DOWN,	handleMouse);
				removeChild(target);
			}
			
			// dispose
			super.dispose();
		}
	}
}