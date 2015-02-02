package onyx.display {
	
	import flash.display.*;
	import flash.events.*;
	import flash.filters.*;
	import flash.geom.*;
	
	import onyx.core.*;
	import onyx.display.*;
	import onyx.event.*;
	import onyx.geom.Rect;
	import onyx.plugin.*;
	
	use namespace parameter;
	
	[PluginInfo(
		id			= 'Onyx.Display.Channel::MIX',
		name		= 'Channel',
		vendor		= 'Daniel Hai',
		version		= '1.0'
	)]
	
	[Event(name='Onyx.Filter.Create', type='onyx.event.OnyxEvent')]
	
	// can it be both?
	
	final public class ChannelMixed extends PluginBase implements IChannelCPU, IChannelGPU {
		
		/**
		 * 	@internal
		 */
		internal const filtersCPU:Vector.<IPluginFilterCPU>	= new Vector.<IPluginFilterCPU>();
		
		/**
		 * 	@internal
		 */
		internal const filtersGPU:Vector.<IPluginFilterGPU>	= new Vector.<IPluginFilterGPU>();
		
		/**
		 * 	@private
		 */
		internal var internalSurface:DisplaySurface;
		
		/**
		 * 	@private
		 */
		internal var internalTexture:DisplayTexture;
		
		/**
		 * 	@internal
		 */
		internal var rectangle:Rect;
		
		/**
		 * 	@internal
		 */
		internal var contextCPU:DisplayContextCPU;
		
		/**
		 * 	@internal
		 */
		internal var contextGPU:DisplayContextGPU;
		
		/**
		 * 	@internal
		 */
		internal var _name:String;
		
		/**
		 * 	@internal
		 */
		internal var owner:IDisplayChannel;
		
		/**
		 * 	@public
		 */
		public function initialize(owner:IDisplayChannel,
								   contextCPU:DisplayContextCPU, 
								   contextGPU:DisplayContextGPU,
								   transparent:Boolean):PluginStatus {
			
			this.owner				= owner;
			this.contextCPU			= contextCPU;
			this.contextGPU			= contextGPU;

			rectangle				= contextCPU.rect;
			
			// create the texture automatically, surface will get created if there's a generator that requests it
			internalSurface	= contextCPU.requestSurface(transparent);
			internalTexture	= contextGPU.requestTexture(contextGPU.txWidth, contextGPU.txHeight, true);
			
			return PluginStatus.OK;
		}
		
		/**
		 * 	@public
		 * 	Swap the surface's channel with this one
		 */
		public function swapSurface(surface:DisplaySurface):void {
			internalSurface = surface;
		}
		
		/**
		 * 	@public
		 * 	Returns the surface instance
		 */
		public function swapTexture(texture:DisplayTexture):void {
			internalTexture = texture;
		}
		
		/**
		 * 	@public
		 */
		public function get frameRate():Number {
			return 0;
		}
		
		/**
		 * 	@public
		 */
		override public function get name():String {
			return _name;
		}
		
		/**
		 * 	@public
		 */
		public function get rect():Rectangle {
			return rectangle;
		}
		
		/**
		 * 	@public
		 */
		public function get width():int {
			return rectangle.width;
		}
		
		/**
		 * 	@public
		 */
		public function get height():int {
			return rectangle.height;
		}
		
		/**
		 * 	@public
		 */
		public function getFilterIndex(instance:IPluginFilter):int {
			
			if (!instance) {
				return -1;
			}
			
			if (instance is IPluginFilterCPU) {
				
			}
			
			return filtersCPU.indexOf(instance);
		}
		
		/**
		 * 	@public
		 */
		public function addFilter(instance:IPluginFilter):Boolean {
			
			if (!instance) {
				return false;
			}
			
			switch (instance.type) {
				case Plugin.CPU:
					
					var cpu:IPluginFilterCPU	= instance as IPluginFilterCPU;
					if (!cpu) {
						instance.dispose();
						return false;
					}
					
					if (cpu.initialize(this, contextCPU) !== PluginStatus.OK) {
						instance.dispose();
						return false;
					};
					
					// add the filter
					filtersCPU.push(cpu);
					
					// dispatch
					return dispatchEvent(new OnyxEvent(OnyxEvent.FILTER_CREATE, instance));
					
				case Plugin.GPU:
					
					var gpu:IPluginFilterGPU	= instance as IPluginFilterGPU;
					if (!gpu) {
						instance.dispose();
						return false;
					}
					
					if (gpu.initialize(this, contextGPU) !== PluginStatus.OK) {
						instance.dispose();
						return false;
					};
					
					// add the filter
					filtersGPU.push(gpu);
					
					// dispatch
					return dispatchEvent(new OnyxEvent(OnyxEvent.FILTER_CREATE, instance));
			}
			
			return false;
		}
		
		/**
		 * 	@public
		 */
		public function removeFilter(instance:IPluginFilter):Boolean {
			
			if (!instance) {
				return false;
			}
			
			var index:int;
			switch (instance.type) {
				case Plugin.CPU:
					
					var cpu:IPluginFilterCPU	= instance as IPluginFilterCPU;
					if (!cpu) {
						instance.dispose();
						return false;
					}
					
					index = filtersCPU.indexOf(instance);
					if (index === -1) {
						instance.dispose();
						return false;
					}
					
					// remove filters
					filtersCPU.splice(index, 1);
					
					// dispatch an event
					dispatchEvent(new OnyxEvent(OnyxEvent.FILTER_DESTROY, instance));
					
					// destroy it
					instance.dispose();
					
					return true;
				case Plugin.GPU:
					
					var gpu:IPluginFilterGPU	= instance as IPluginFilterGPU;
					if (!gpu) {
						instance.dispose();
						return false;
					}
					
					index = filtersGPU.indexOf(instance);
					if (index === -1) {
						instance.dispose();
						return false;
					}
					
					// remove filters
					filtersGPU.splice(index, 1);
					
					// dispatch an event
					dispatchEvent(new OnyxEvent(OnyxEvent.FILTER_DESTROY, instance));
					
					// destroy it
					instance.dispose();
					
					// return true;
					return true;
			}
			
			return false;
		}
		
		/**
		 * 	@public
		 */
		public function swapFilters(a:IPluginFilter, b:IPluginFilter):Boolean {
			
			switch (a.type) {
				case Plugin.CPU:
					
					var cpuA:IPluginFilterCPU	= a as IPluginFilterCPU;
					var cpuB:IPluginFilterCPU	= b as IPluginFilterCPU;
					
					if (!cpuA || !cpuB) {
						return false;
					}
					
					var ai:int = filtersCPU.indexOf(cpuA);
					var bi:int = filtersCPU.indexOf(cpuB);
					
					// DEBUG
					if (ai === -1 || bi === -1) {
						CONFIG::DEBUG { throw new Error('FILTERS DONT EXIST!'); }
						return false;
					} 
					
					filtersCPU[bi] = cpuA;
					filtersCPU[ai] = cpuB;
					
					dispatchEvent(new OnyxEvent(OnyxEvent.FILTER_MOVE, cpuA));
					dispatchEvent(new OnyxEvent(OnyxEvent.FILTER_MOVE, cpuB));
					
					return true;
					
					return true;
				case Plugin.GPU:
					return true;
			}
			
			return false;
		}
		
		/**
		 * 	@public
		 */
		public function clearFilters():void {
			
			while (filtersGPU.length) {
				removeFilter(filtersGPU[0]);
			}
			
			while (filtersCPU.length) {
				removeFilter(filtersCPU[0]);
			}
		}
		
		/**
		 * 	@public
		 */
		public function getFilters():Vector.<IPluginFilter> {
			const v:Vector.<IPluginFilter>	= new Vector.<IPluginFilter>(filtersCPU.length + filtersGPU.length, true);
			var index:int					= 0;
			var filter:IPluginFilter;
			for each (filter in filtersCPU) { 
				v[index++] = filter;
			}
			for each (filter in filtersGPU) { 
				v[index++] = filter;
			}
			return v;
		}
		
		/**
		 * 	@public
		 */
		public function get surface():DisplaySurface {
			return internalSurface;
		}
		
		/**
		 * 	@public
		 */
		override public function unserialize(token:*):void {
			
			if (token.filters) {
				for each (var obj:Object in token.filters) {
					addFilter(Onyx.CreateInstance(obj.id, obj) as IPluginFilter);
				}
			}
		}
		
		/**
		 * 	@public
		 */
		override public function serialize(options:uint = 0xFFFFFFFF):Object {
			
			const data:Object	= super.serialize() || {};
			
			if (filtersCPU.length || filtersGPU.length) {
				var serializedFilters:Array	= [];
				var filter:IPluginFilter;
				for each (filter in filtersCPU) {
					serializedFilters.push(filter.serialize(options));
				}
				for each (filter in filtersGPU) {
					serializedFilters.push(filter.serialize(options));
				}
				data.filters = serializedFilters;
			}
			
			return data;
		}
		
		/**
		 * 	@public
		 */
		override public function toString():String {
			return this.name;
		}
		
		/**
		 * 	@public
		 */
		public function get texture():DisplayTexture {
			return internalTexture;
		}
		
		/**
		 * 	@public
		 */
		public function render():void {
			contextCPU.bindChannel(this);
		}
	}
}