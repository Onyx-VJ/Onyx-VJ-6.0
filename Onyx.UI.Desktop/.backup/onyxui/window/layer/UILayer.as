package onyxui.window.layer {
	
	import flash.display.*;
	import flash.events.*;
	import flash.filters.*;
	import flash.text.*;
	
	import onyx.core.*;
	import onyx.display.*;
	import onyx.event.*;
	import onyx.plugin.*;
	
	import onyxui.assets.*;
	import onyxui.core.*;
	import onyxui.parameter.*;
	
	final public class UILayer extends UIContainer {
		
		/**
		 * 	@private
		 */
		public var layer:IDisplayLayer;
		
		/**
		 * 	@private
		 */
		private var blendDrop:UIParameterDropDown;
		
		/**
		 * 	@private
		 */
		private var preview:UIBitmap;
		
		/**
		 * 	@private
		 */
		private var path:TextField;
		
		/**
		 * 	@private
		 */
		private var list:UIFilterList;
		
		/**
		 * 	@private
		 */
		private var transport:UITransportControl;
		
		/**
		 * 	@private
		 */
		private var color:UIParameterColorTransform;
		
		/**
		 * 	@private
		 */
		private var scrub:UITransportScrub;
		
		/**
		 * 	@public
		 */
		private const closeButton:SimpleButton	= new UIAssetFilterCloseButton();
		
		/**
		 * 	@public
		 */
		public function UILayer(layer:IDisplayLayer):void {
			this.layer = layer;
		}
		
		/**
		 * 	@public
		 */
		override public function initialize():void {
			
			// initialize
			super.initialize();
			
			preview				= getChild('preview');
			
			blendDrop			= getChild('blendMode');
			blendDrop.attach(layer.getParameter('blendMode'));
			
			path				= getChild('pathLabel', 'label');
			path.filters = [new DropShadowFilter(2,45,0,1,0,0,1,1)];
			path.cacheAsBitmap = true;
			
			color				= getChild('color');
			color.attach(layer.getParameter('colorTransform'));
			
			list				= getChild('filterList');
			list.attach(layer);
			
			transport			= getChild('transport');
			transport.attach(layer);
			
			scrub				= getChild('scrub');
			scrub.attach(layer);
			
			addChild(closeButton).visible	= false;
			
			// update
			updatePosition();
			
			// layer listen
			layer.addEventListener(OnyxEvent.LAYER_LOAD,		handleLayer);
			layer.addEventListener(OnyxEvent.LAYER_UNLOAD,		handleLayer);
			layer.addEventListener(OnyxEvent.LAYER_MOVE,		handleLayer);
			
			// close
			closeButton.addEventListener(MouseEvent.CLICK,		handleMouse);
		}
		
		/**
		 * 	@private
		 */
		private function handleLayer(e:Event):void {
				
			switch (e.type) {
				case OnyxEvent.LAYER_MOVE:
					
					return updatePosition();
					
				// something is loaded
				case OnyxEvent.LAYER_LOAD:
					
					var generator:IPluginGenerator = layer.generator as IPluginGenerator;
					
					// attach
					preview.attach(layer.getSurface());
										
					closeButton.visible	= true;
					
					path.text = layer.path;
					scrub.setEnabled(true);
					
					return;
				case OnyxEvent.LAYER_UNLOAD:
					
					closeButton.visible	= false;
					
					path.text = '';
					scrub.setEnabled(false);
					
					return;
			}
		}
		
		/**
		 * 	@private
		 */
		private function handleMouse(event:MouseEvent):void {
			switch (event.currentTarget) {
				case closeButton:
					
					if (event.ctrlKey) {

						var layers:Vector.<IDisplayLayer>	= Onyx.GetDisplay(0).getLayers();
						for each (var layer:IDisplayLayer in layers) {
							layer.unload();
						}
						
					} else {
						this.layer.unload();
					}
					
					break;
			}
		}
		
		/**
		 * 	@public
		 */
		private function updatePosition():void {
			
			// move me
			x = layer.index * (bounds.width + 4);

		}
		
		/**
		 * 	@public
		 */
		override public function resize(width:int, height:int):void {
			
			closeButton.x	= bounds.width - 20; 
			closeButton.y	= 2;
			
			super.resize(width, height);
			
		}
		
		/**
		 * 	@public
		 */
		override public function dispose():void {
			
			closeButton.removeEventListener(MouseEvent.CLICK, handleMouse);
			
			layer.removeEventListener(OnyxEvent.LAYER_LOAD,		handleLayer);
			layer.removeEventListener(OnyxEvent.LAYER_UNLOAD,	handleLayer);
			layer.removeEventListener(OnyxEvent.LAYER_MOVE,		handleLayer);
			
			// dispose
			super.dispose();
		}
	}
}