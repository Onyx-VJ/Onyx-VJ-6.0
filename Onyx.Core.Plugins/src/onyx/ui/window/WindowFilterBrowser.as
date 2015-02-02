package onyx.ui.window {
	
	import flash.display.*;
	import flash.events.*;
	import flash.utils.*;
	
	import onyx.core.*;
	import onyx.display.*;
	import onyx.plugin.*;
	import onyx.ui.component.*;
	import onyx.ui.core.*;
	import onyx.ui.factory.*;
	import onyx.ui.interaction.*;
	import onyx.ui.window.browser.*;
	import onyx.ui.window.layer.*;
	import onyx.util.*;
	
	use namespace skinPart;
	
	
	[UIComponent(
		id		= 'Onyx.UI.Desktop.FilterBrowser',
		title	= 'FILTER BROWSER'
	)]
	
	[UISkinPart(id='filterPane',	type='scrollPane')]
	
	public final class WindowFilterBrowser extends UIContainer {
		
		/**
		 * 	@private
		 */
		private var factory:UIFactory	= new UIFactory(UIFilterProxy);
		
		/**
		 * 	filterPane
		 */
		skinPart var filterPane:UIScrollPane;
		
		/**
		 * 	@public
		 */
		override public function initialize(data:Object):void {
			
			super.initialize(data);
			
			// set grid size
			filterPane.setGridSize(135, 20);
			
			for each (var plugin:IPluginDefinition in Onyx.EnumeratePlugins(Plugin.FILTER)) {
				var proxy:UIFilterProxy = factory.createInstance();
				filterPane.addChild(proxy);
				
				proxy.attach(plugin);
				proxy.addEventListener(MouseEvent.MOUSE_DOWN, handleMouse);
			};
			
			for each (plugin in Onyx.EnumeratePlugins(0x10 | Plugin.FILTER)) {
				proxy = factory.createInstance();
				filterPane.addChild(proxy);
				
				proxy.attach(plugin);
				proxy.addEventListener(MouseEvent.MOUSE_DOWN, handleMouse);
			};
		}
		
		/**
		 *	@private 
		 */
		private function handleMouse(e:MouseEvent):void {
			
			const control:UIFilterProxy = e.currentTarget as UIFilterProxy;
			switch (e.type) {
				case MouseEvent.MOUSE_DOWN:
					
					if ((control.target.type & 0x10) > 0) {
						
						// start drag for gpu filter
						DragManager.startDrag(DragManager.FILTER_GPU, control.target, e);
						
					} else { 
	
						// start drag
						DragManager.startDrag(DragManager.FILTER_CPU, control.target, e);
					}

					break;
			}
		}
	}
}