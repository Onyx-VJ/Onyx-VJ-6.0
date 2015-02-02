package onyxui.window.layer {
	
	import flash.display.*;
	import flash.events.*;
	import flash.utils.*;
	
	import onyx.core.*;
	import onyx.display.*;
	import onyx.event.*;
	import onyx.plugin.*;
	
	import onyxui.parameter.*;
	import onyxui.core.*;
	import onyxui.event.*;
	import onyxui.interaction.*;
	import onyxui.window.browser.*;
	import onyxui.window.filter.UIFilterControl;
	
	final public class UIFilterList extends UIObject {
		
		/**
		 * 	@private
		 */
		private var selected:UIFilter;
		
		/**
		 * 	@private
		 */
		private var layer:IDisplayLayer;
		
		/**
		 * 	@private
		 */
		private const hash:Dictionary			= new Dictionary(true);
		
		/**
		 * 	@private
		 */
		private const list:UIParameterList		= addChild(new UIParameterList()) as UIParameterList;
		
		/**
		 * 	@private
		 */
		private const proxy:Sprite				= new Sprite();

		/**
		 * 	@public
		 */
		public function UIFilterList():void {
			proxy.x	= 1;
			proxy.y	= 1;
			list.x	= 97;
			list.y	= 2;
			list.resize(125, 100);
			addChild(proxy);
		}
		
		/**
		 * 	@public
		 */
		public function attach(layer:IDisplayLayer):void {
			
			this.layer	= layer;
			
			layer.addEventListener(OnyxEvent.FILTER_CREATE,	handle);
			layer.addEventListener(OnyxEvent.FILTER_DESTROY, 	handle);
			layer.addEventListener(OnyxEvent.FILTER_MOVE, 	handle);
			layer.addEventListener(OnyxEvent.LAYER_LOAD,			handle);
			layer.addEventListener(OnyxEvent.LAYER_UNLOAD,		handle);
			
		}

		/**
		 * 	@private
		 */
		private function handle(event:OnyxEvent):void {

			switch (event.type) {
				case OnyxEvent.FILTER_DESTROY:
					return destroy(event.data);
				case OnyxEvent.FILTER_CREATE:
					return create(event.data);
				case OnyxEvent.FILTER_MOVE:
					return arrange();
				case OnyxEvent.LAYER_LOAD:
					return create(layer.generator, 0);
				case OnyxEvent.LAYER_UNLOAD:
					return destroy(layer.generator);
			}
			
		}
		
		/**
		 * 	@private
		 */
		private function killGen(... args:Array):void {
			layer.generator = null;
		}
		
		/**
		 * 	@private
		 */
		private function arrange():void {
			var filters:Vector.<IPluginFilter> = layer.getFilters();
			var index:int	= layer.generator === null ? 0 : 1;
			for (var count:int = 0; count < filters.length; ++count) {
				proxy.setChildIndex(hash[filters[count]], count + index);
			}
			sort();
		}
		
		/**
		 * 	@private
		 */
		private function create(instance:IPlugin, index:int = -1):void {
			
			// create
			const filter:UIFilter	= hash[instance] = new UIFilter(instance, index === 0 ? killGen : layer.removeFilter);
			// filter.target.addEventListener(FilterEvent.FILTER_CHANGE, handleChange);
			filter.resize(109,18);
			
			if (index === -1) {
				proxy.addChild(filter)
			} else {
				proxy.addChildAt(filter, index);	
			}
			
			Interaction.Bind(filter, handleFilter, Interaction.RIGHT_CLICK, Interaction.LEFT_CLICK);
			
			// bind
			sort();
		}
		
		/**
		 * 	@private
		 */
		private function handleChange(event:OnyxEvent):void {
			var instance:IPluginFilter = event.data as IPluginFilter;
			if (instance) {
//				
//				const flags:uint = instance.getFlags();
//				const ui:UIFilter = hash[instance];
//				ui.setMuted((flags & Plugin.FLAG_MUTED) !== 0);
			}
		}
		
		/**
		 * 	@private
		 */
		private function sort():void {
			var count:int = proxy.numChildren;
			while (--count > -1) {
				proxy.getChildAt(count).y = count * 20;
			}
		}
		
		/**
		 * 	@private
		 */
		private function destroy(instance:IPlugin):void {
						
			const filter:UIFilter = hash[instance];
			
			// unbind
			Interaction.Unbind(filter);
			
			// remove
			proxy.removeChild(filter);
			
			
			// filter.target.removeEventListener(FilterEvent.FILTER_CHANGE, handleChange);
			if (selected === filter) {
				setCurrent(null);
			}
			
			// dispose
			filter.dispose();
			
			delete hash[instance];
			
			sort();
		}

		/**
		 * 	@private
		 */
		private function handleFilter(interaction:IInteraction, event:Event):void {
			var filter:UIFilter = event.currentTarget as UIFilter;
			switch (event.type) {
				case MouseEvent.CLICK:
					
					if (filter !== selected) {
						setCurrent(filter);
					}
					
					listenFilterDrag(true);
					
					// listen
					AppStage.addEventListener(MouseEvent.MOUSE_UP, handleMouse);
					
					break;
				
				case InteractionEvent.RIGHT_CLICK:
					
					var instance:IPluginFilterCPU = filter.target as IPluginFilterCPU;
					if (instance && instance.hasParameter('muted')) {
						instance.setParameterValue('muted', !instance.getParameterValue('muted'));
					}
					
					break;
			}
		}
		
		/**
		 * 	@private
		 */
		private function handleMouse(event:Event):void {
			switch (event.type) {
				case MouseEvent.ROLL_OVER:
					
					var filter:UIFilter = event.currentTarget as UIFilter;
					layer.swapFilters(selected.target as IPluginFilterCPU, filter.target as IPluginFilterCPU);
					
					break;
				case MouseEvent.MOUSE_UP:
				
					AppStage.removeEventListener(MouseEvent.MOUSE_UP, handleFilter);
					listenFilterDrag(false);
				
				break;
			}
		}
		
		/**
		 * 	@private
		 */
		private function listenFilterDrag(listen:Boolean):void {
			
			if (listen) {
				for each (var filter:UIFilter in hash){
					if (selected !== filter && !(filter.target is IPluginGenerator)) {
						filter.addEventListener(MouseEvent.ROLL_OVER, handleMouse); 	
					}
				}
			} else {
				for each (filter in hash){
					filter.removeEventListener(MouseEvent.ROLL_OVER, handleMouse); 	
				}
			}
		}
		
		/**
		 * 	@public
		 */
		public function setCurrent(instance:UIFilter):void {
			if (selected) {
				selected.setSelected(false);
				list.remChildren();
			}
			selected = instance;
			if (selected) {
				selected.setSelected(true);
				list.attach(selected.target.getParameters());
			}
		}
		
		/**
		 * 	@public
		 */
		override public function dispose():void {
			
			layer.removeEventListener(OnyxEvent.FILTER_CREATE,	handle);
			layer.removeEventListener(OnyxEvent.FILTER_DESTROY, 	handle);
			layer.removeEventListener(OnyxEvent.LAYER_LOAD,			handle);
			layer.removeEventListener(OnyxEvent.LAYER_UNLOAD,		handle);
			
			for each (var filter:UIFilter in hash){
				filter.removeEventListener(MouseEvent.ROLL_OVER, handleMouse);
				destroy(filter.target);
			}
			
			AppStage.removeEventListener(MouseEvent.MOUSE_UP, handleMouse);
			
			super.dispose();
		}
	}
}