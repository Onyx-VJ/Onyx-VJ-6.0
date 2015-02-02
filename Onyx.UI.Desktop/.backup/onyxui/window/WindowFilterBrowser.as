package onyxui.window {
	
	import flash.display.*;
	import flash.events.*;
	import flash.utils.*;
	
	import onyx.core.*;
	import onyx.plugin.*;
	import onyx.util.*;
	
	import onyxui.core.*;
	import onyxui.interaction.*;
	import onyxui.parameter.*;
	import onyxui.window.browser.*;
	import onyxui.window.filter.*;
	import onyxui.window.layer.*;

	public final class WindowFilterBrowser extends UIWindow {

		/**
		 * 	@private
		 */
		private const button:UIButton			= new UIButton('Files');
		
		/**
		 * 	@private
		 */
		private const hash:Dictionary			= new Dictionary(true);
		
		/**
		 * 	@private
		 */
		private var filterPane:UIScrollPane;

		/**
		 * 	@public
		 */
		override public function initialize():void {
			
			// init
			filterPane	= getChild('filterPane');
			filterPane.setGridSize(120, 50);
			
			var plugins:Vector.<IPluginDefinition> = Onyx.EnumeratePlugins(Plugin.FILTER);
			for each (var plugin:IPluginDefinition in plugins) {
				var control:UIFilterControl = new UIFilterControl(plugin);
				control.addEventListener(MouseEvent.MOUSE_DOWN, handleMouse);
				filterPane.addChild(control);
			}
		}
		
		
		/**
		 * 	@private
		 */
		private function handleMouse(e:MouseEvent):void {
			
			const control:UIFilterControl = e.currentTarget as UIFilterControl;
			switch (e.type) {
				case MouseEvent.MOUSE_DOWN:
					
					const window:WindowLayer = OnyxUI.GetWindow('WindowLayer') as WindowLayer;
					if (window) {
						DragManager.start(e.currentTarget as UIObject, e, window.getControls(), new Callback(handleDrag, [control]));
					}
					
					break;
			}
		}
		
		/**
		 * 	@private
		 */
		private function removeListeners():void {
			const children:Array = filterPane.getChildren();
			for each (var control:UIFilterControl in children) {
				control.removeEventListener(MouseEvent.CLICK,		handleMouse);
				control.removeEventListener(MouseEvent.MOUSE_DOWN,	handleMouse);
			}
		}
		
		/**
		 * 	@private
		 */
		private function handleDrag(control:UIFilterControl, layer:UILayer):void {
			layer.layer.addFilter(control.plugin.createInstance() as IPluginFilter);
		}
	}
}