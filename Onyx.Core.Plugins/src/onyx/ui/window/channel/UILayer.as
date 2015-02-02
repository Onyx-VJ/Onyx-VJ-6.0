package onyx.ui.window.channel {
	
	import flash.display.*;
	import flash.events.*;
	import flash.filters.*;
	import flash.text.*;
	
	import onyx.core.*;
	import onyx.display.*;
	import onyx.event.*;
	import onyx.plugin.*;
	import onyx.ui.component.*;
	import onyx.ui.core.*;
	import onyx.ui.event.*;
	import onyx.ui.factory.*;
	import onyx.ui.interaction.*;
	import onyx.ui.parameter.*;
	import onyx.ui.window.channel.*;
	import onyx.ui.window.layer.*;
	import onyx.util.Callback;
	
	use namespace skinPart;
	
	[UIComponent(id='Onyx.UI.Desktop.Layers::Layer')]
	
	[UISkinPart(id='background',		type='skin', transform='theme::default', skinClass='LayerBackground')]
	[UISkinPart(id='preview',			type='layerPreview')]
	[UISkinPart(id='pathLabel',			type='text')]
	[UISkinPart(id='filterList',		type='filterList')]
	[UISkinPart(id='parameterList',		type='parameterList')]
	[UISkinPart(id='visibleButton',		type='skin', skinClass='EyeIcon')]
	[UISkinPart(id='duplicateButton',	type='skin', skinClass='LayerDuplicate')]
	[UISkinPart(id='closeButton',		type='skin', skinClass='FilterClose')]
	[UISkinPart(id='transport',			type='layerTransport')]
	[UISkinPart(id='scrub',				type='layerScrub')]
	[UISkinPart(id='blendDrop',			type='parameter')]
	[UISkinPart(id='color',				type='parameter')]

	final public class UILayer extends UIChannel {
		
		/**
		 * 	@private
		 */
		skinPart var visibleButton:UISkin;
		
		/**
		 * 	@private
		 */
		skinPart var closeButton:UISkin;
		
		/**
		 * 	@private
		 */
		skinPart var duplicateButton:UISkin;
		
		/**
		 * 	@private
		 */
		skinPart var blendDrop:UIParameter;

		/**
		 * 	@private
		 */
		skinPart var pathLabel:UITextField;
		
		/**
		 * 	@private
		 */
		skinPart var transport:UILayerTransport;
		
		/**
		 * 	@private
		 */
		skinPart var color:UIParameter;
		
		/**
		 * 	@private
		 */
		skinPart var scrub:UILayerScrub;
		
		/**
		 * 	@public
		 */
		override public function initialize(data:Object):void {
			
			// initialize
			super.initialize(data);
			
			// register as a target
			DragManager.registerTarget(this, DragManager.GENERATOR);
			
			pathLabel.cacheAsBitmap	= true;
			pathLabel.filters		= [new DropShadowFilter(2,45,0,1,0,0,1,1)];
			
			// set close
			closeButton.addEventListener(MouseEvent.CLICK,		handleMouse);
			duplicateButton.addEventListener(MouseEvent.CLICK,	handleMouse);
			visibleButton.addEventListener(MouseEvent.CLICK,	handleMouse);
			
			// handle layer state
			handleLayerState(false);
			
		}

		/**
		 * 	@public
		 */
		override public function attach(owner:IDisplayChannel):void {
			
			// attach
			super.attach(owner);
			
			// blenddrop
			transport.attach(owner as IDisplayLayer);
			scrub.attach(owner as IDisplayLayer);
			color.attach(owner.getParameter('colorTransform'));
			
			owner.addEventListener(OnyxEvent.LAYER_LOAD,		handleLayer);
			owner.addEventListener(OnyxEvent.LAYER_UNLOAD,		handleLayer);
			
			// listen for visibility changes
			owner.getParameter('visible').addEventListener(ParameterEvent.VALUE_CHANGE, handleVisible);
			
			// listen?
			filterList.addEventListener(SelectionEvent.SELECT, handleSelection);
			
		}
		
		/**
		 * 	@private
		 */
		private function handleVisible(... args:Array):void {

			visibleButton.setCurrentFrame(owner.getParameterValue('visible') ? 1 : 2);

		}

		/**
		 * 	@private
		 */
		private function handleSelection(e:SelectionEvent):void {
			
			var target:IPlugin = e.data;
			parameterList.attach(target ? target.getParameters() : null);

		}
		
		/**
		 * 	@public
		 */
		public function getLayer():IDisplayLayer {
			return owner as IDisplayLayer;
		}
		
		/**
		 * 	@public
		 */
		override public function arrange(rect:UIRect):void {
			
			// arrange
			super.arrange(rect);
			
			// identity!
			rect = rect.identity();

			// arrange
			preview.measure(rect);
			pathLabel.measure(rect);
			closeButton.measure(rect);
			visibleButton.measure(rect);
			
			// draws
			transport.measure(rect);
			blendDrop.measure(rect);
			scrub.measure(rect);
			duplicateButton.measure(rect);
			filterList.measure(rect);
			parameterList.measure(rect);
			color.measure(rect);

		}
		
		/**
		 * 	@private
		 */
		private function handleMouse(e:MouseEvent):void {
			
			var layer:IDisplayLayer	= owner as IDisplayLayer;
			
			switch (e.currentTarget) {
				case visibleButton:
					
					owner.setParameterValue('visible', !owner.getParameterValue('visible'));
					
					break;
				case duplicateButton:
					
					if (!layer.getGenerator()) {
						return;
					}
					
					var index:int	= layer.index;
					var nextLayer:IDisplayLayer = layer.parent.getLayer(index + 1);
					if (nextLayer) {
						
						var file:IFileReference = FileSystem.GetFileReference(layer.path);
						
						FileSystem.Load(file, new Callback(function(file:IFileReference, content:Object, generator:IPluginGenerator):void {
							nextLayer.setGenerator(generator, file, content);
							nextLayer.unserialize(layer.serialize(Plugin.SERIALIZE_PARAMETERS));
						}));
					}
					
					break;
				case closeButton:
					
					if (e.ctrlKey) {
						
						var display:IDisplay = layer.parent;
						for each (var close:IDisplayLayer in display.getLayers()) {
							close.unload();
						}
						
					} else {
						layer.unload();
					}
					
					break;
			}
		}

		/**
		 * 	@private
		 */
		private function handleLayer(e:OnyxEvent):void {
			
			var layer:IDisplayLayer = owner as IDisplayLayer;
			
			switch (e.type) {
				// something is loaded
				case OnyxEvent.LAYER_LOAD:
					
					var item:UIFilterListItem;
					
					// attach the blend!
					blendDrop.attach(owner.getParameter('blendMode'));

					// set the text
					pathLabel.text			= layer.path;
					
					// add generator
					item = filterList.add(FACTORY_BASE, layer.getGenerator(), 0);
					
					// selected?
					if (!filterList.selected) {
						filterList.setSelected(item);
					}
					
					handleLayerState(true);
					
					return;
				case OnyxEvent.LAYER_UNLOAD:
					
					// remove
					filterList.remove(layer.getGenerator());
					
					// set to none
					filterList.setSelected(null);
					
					handleLayerState(false);
					pathLabel.text		= '';
					
					// attach the blend!
					blendDrop.attach(null);
					
					
					return;
			}
		}
		
		private function handleLayerState(value:Boolean):void {
			
			closeButton.visible		= value;
			duplicateButton.visible	= value;
			scrub.visible			= value;
			visibleButton.visible	= value;

		}
		
		/**
		 * 	@public
		 */
		override public function dispose():void {
			
			owner.getParameter('visible').removeEventListener(ParameterEvent.VALUE_CHANGE, handleVisible);
			
			removeEventListener(DragEvent.DRAG_OVER,	handleDrag);
			removeEventListener(DragEvent.DRAG_OUT,		handleDrag);
			removeEventListener(DragEvent.DRAG_DROP,	handleDrag);
			
			closeButton.removeEventListener(MouseEvent.CLICK, handleMouse);
			
			owner.removeEventListener(OnyxEvent.LAYER_LOAD,		handleLayer);
			owner.removeEventListener(OnyxEvent.LAYER_UNLOAD,	handleLayer);
			owner.removeEventListener(OnyxEvent.LAYER_MOVE,		handleLayer);

			filterList.removeEventListener(SelectionEvent.SELECT, handleSelection);

			// dispose
			super.dispose();
		}
	}
}