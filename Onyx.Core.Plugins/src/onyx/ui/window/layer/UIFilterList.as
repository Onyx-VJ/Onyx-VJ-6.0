package onyx.ui.window.layer {
	
	import flash.display.*;
	import flash.events.*;
	import flash.utils.*;
	
	import onyx.core.*;
	import onyx.display.*;
	import onyx.event.*;
	import onyx.parameter.*;
	import onyx.plugin.*;
	import onyx.ui.core.*;
	import onyx.ui.event.*;
	import onyx.ui.factory.*;
	import onyx.ui.interaction.*;
	import onyx.ui.parameter.*;
	import onyx.ui.window.browser.*;
	import onyx.util.Callback;
	
	use namespace skinPart;
	
	[UIComponent(id='filterList')]
	
	final public class UIFilterList extends UIObject {
		
		/**
		 * 	@private
		 */
		public var selected:UIFilterListItem;
		
		/**
		 * 	@private
		 */
		private const children:Array	= [];
		
		/**
		 * 	@private
		 */
		private const hash:Dictionary	= new Dictionary(true);
	
		/**
		 * 	@private
		 */
		private function arrangeFilters():void {
			
			// sort!
			children.sortOn('index', Array.NUMERIC);
			
			var count:int = 0;
			var bounds:UIRect	= new UIRect(0,0,91,18);
			for each (var child:UIFilterListItem in children) {
				child.arrange(bounds);
				bounds.y += child.height + 1;
			}
		}
		
		/**
		 * 	@public
		 */
		public function updateIndex(plugin:IPlugin, index:int):void {
			
		}
		
		/**
		 * 	@public
		 */
		public function getPlugin(plugin:IPlugin):UIFilterListItem {
			return hash[plugin];
		}
		
		/**
		 * 	@public
		 */
		public function remove(plugin:IPlugin):UIFilterListItem {
			
			var item:UIFilterListItem = hash[plugin];
			item.dispose();
			removeChild(item);
			
			children.splice(children.indexOf(item), 1);
			
			delete hash[plugin];
			
			// invalidate these filters
			application.invalidate(new Callback(arrangeFilters));
			
			return item;
		}
		
		/**
		 * 	@public
		 */
		public function sort():void {
			
			// invalidate these filters
			application.invalidate(new Callback(arrangeFilters));
			
		}

		/**
		 * 	@private
		 */
		public function add(factory:IFactory, plugin:IPlugin, index:int):UIFilterListItem {
			
			const proxy:UIFilterListItem	= factory.createInstance();
			proxy.attach(plugin, index);
			
			// store a reference to the target
			hash[plugin]	= proxy;
			
			// listen now
			children.push(addChild(proxy));
			
			// listen?
			proxy.addEventListener(SelectionEvent.SELECT, handleSelection);
			
			// invalidate these filters
			application.invalidate(new Callback(arrangeFilters));
			
			// return
			return proxy;
		}
		
		/**
		 * 	@private
		 */
		private function handleSelection(e:SelectionEvent):void {
			setSelected(hash[e.data]);
		}
		
		/**
		 * 	@private
		 */
		private function destroy(instance:IPlugin):void {

			const filter:UIFilterListItem = hash[instance];
			
			// unbind
			Interaction.Unbind(filter);
			
			// remove
			removeChild(filter);
			
			if (selected === filter) {
				setSelected(null);
			}

			// dispose
			filter.dispose();

			delete hash[instance];
			
			sort();
		}
//
//		/**
//		 * 	@private
//		 */
//		private function handleFilter(interaction:IInteraction, event:Event):void {
//			
//			var filter:UIFilter = event.currentTarget as UIFilter;
//			switch (event.type) {
//				case MouseEvent.MOUSE_DOWN:
//					
//					// listen for drag
//					listenFilterDrag(true);
//					
//					// listen
//					AppStage.addEventListener(MouseEvent.MOUSE_UP, handleMouse);
//					
//					break;
//				case MouseEvent.CLICK:
//					
//					// shift key will mute
//					if ((event as MouseEvent).shiftKey) {
//						
//						var instance:IPlugin = filter.target;
//						if (instance && instance.hasParameter('muted')) {
//							instance.setParameterValue('muted', !instance.getParameterValue('muted'));
//						}
//						
//					} else {
//						
//						if (filter !== selected) {
//							setCurrent(filter);
//						}
//						
//					}
//
//					break;
//				case MouseEvent.RIGHT_CLICK:
//					
//					// resets all parameters
//					instance = filter.target;
//					if (instance) {
//						instance.getParameters().reset();
//					}
//					
//					break;
//			}
//		}
//		
//		/**
//		 * 	@private
//		 */
//		private function handleMouse(event:Event):void {
//			
////			switch (event.type) {
////				case MouseEvent.ROLL_OVER:
////					
////					var filter:UIFilter = event.currentTarget as UIFilter;
////					channel.swapFilters(selected.target as IPluginFilterCPU, filter.target as IPluginFilterCPU);
////					
////					break;
////				case MouseEvent.MOUSE_UP:
////				
////					AppStage.removeEventListener(MouseEvent.MOUSE_UP, handleFilter);
////					listenFilterDrag(false);
////				
////				break;
////			}
//		}
////		
////		/**
////		 * 	@private
////		 */
////		private function listenFilterDrag(listen:Boolean):void {
////			
////			if (listen) {
////				for each (var filter:UIFilter in hash){
////					if (selected !== filter && !(filter.target is IPluginGenerator)) {
////						filter.addEventListener(MouseEvent.ROLL_OVER, handleMouse); 	
////					}
////				}
////			} else {
////				for each (filter in hash){
////					filter.removeEventListener(MouseEvent.ROLL_OVER, handleMouse); 	
////				}
////			}
////		}
		
		/**
		 * 	@public
		 */
		public function setSelected(instance:UIFilterListItem):void {
			
			if (selected) {
				selected.setSelected(false);
			}
			selected = instance;
			if (selected) {
				selected.setSelected(true);
			}
			
			dispatchEvent(new SelectionEvent(SelectionEvent.SELECT, selected ? selected.plugin : null));

		}
//		
//		/**
//		 * 	@public
//		 */
//		public function remove(item:UIFilterListItem):void {
//			item.removeEventListener(MouseEvent.RIGHT_CLICK,	handleMouse);
//			item.removeEventListener(MouseEvent.ROLL_OVER,		handleMouse);
//			item.removeEventListener(MouseEvent.CLICK,			handleMouse);
//			removeChild(item);
//			item.dispose();
//		}
//		
//		/**
//		 * 	@public
//		 */
//		public function setSelected(instance:IPlugin):void {
//			setCurrent(hash[instance]);
//		}
//		
//		/**
//		 * 	@public
//		 */
//		override public function dispose():void {
//			
//			for each (var item:UIFilterListItem in hash) {
//				remove(item);
//			}
//			
//			AppStage.removeEventListener(MouseEvent.MOUSE_UP, handleMouse);
//			
//			super.dispose();
//		}
	}
}