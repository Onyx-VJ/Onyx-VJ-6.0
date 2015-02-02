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
		id			= 'Onyx.Display.Channel::CPU',
		name		= 'Channel',
		vendor		= 'Daniel Hai',
		version		= '1.0'
	)]
	
	[Event(name='Onyx.Filter.Create', type='onyx.event.OnyxEvent')]
	
	public class ChannelCPU extends PluginBase implements IChannelCPU {
		
		/**
		 * 	@public
		 */
		internal const filters:Vector.<IPluginFilterCPU>	= new Vector.<IPluginFilterCPU>();
		
		/**
		 * 	@private
		 */
		internal var internalSurface:DisplaySurface;
		
		/**
		 * 	@internal
		 */
		internal var rectangle:Rect;
		
		/**
		 * 	@internal
		 */
		internal var context:IDisplayContextCPU;
		
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
		public function initializeCPU(owner:IDisplayChannel, context:IDisplayContextCPU, transparent:Boolean, color:uint):void {
			this.owner			= owner;
			this.context		= context;
			rectangle			= context.rect;
			internalSurface		= new DisplaySurface(context.width, context.height, transparent, color);
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
				
				CONFIG::DEBUG {
					throw new Error('Index === -1!');
				}
				
				return -1;
			}
			return filters.indexOf(instance);
		}

		/**
		 * 	@public
		 */
		public function addFilter(input:IPluginFilter):Boolean {
			
			// return instance
			var instance:IPluginFilterCPU	= input as IPluginFilterCPU; 
				
			// nothing?
			if (!instance) {
				return false;
			}
			
			// initialize
			if (instance.initialize(this, context) !== PluginStatus.OK) {
				
				// kill the instance
				instance.dispose();
				
				return false;
			}
			
			// add the filter
			filters.push(instance);
			
			// dispatch
			return dispatchEvent(new OnyxEvent(OnyxEvent.FILTER_CREATE, instance));
		}
		
		/**
		 * 	@public
		 */
		public function removeFilter(input:IPluginFilter):Boolean {
			
			var instance:IPluginFilterCPU	= input as IPluginFilterCPU;
			if (!instance) {
				return false;
			}
			
			const index:int = filters.indexOf(instance);
			if (index === -1) {
				throw new Error('FILTER NOT PART OF CHANNEL!');
				return false;
			}
			
			// remove filters
			filters.splice(index, 1);
			
			// dispatch an event
			dispatchEvent(new OnyxEvent(OnyxEvent.FILTER_DESTROY, instance));
			
			// destroy it
			instance.dispose();
			
			// return
			return true;
		}
		
		/**
		 * 	@public
		 */
		public function swapFilters(a:IPluginFilter, b:IPluginFilter):Boolean {
			
			var instanceA:IPluginFilterCPU	= a as IPluginFilterCPU;
			var instanceB:IPluginFilterCPU	= b as IPluginFilterCPU;
			
			if (!instanceA || !instanceB) {
				return false;
			}
			
			const ai:int = filters.indexOf(instanceA);
			const bi:int = filters.indexOf(instanceB);
			
			// DEBUG
			if (ai === -1 || bi === -1) {
				CONFIG::DEBUG { throw new Error('FILTERS DONT EXIST!'); }
				return false;
			} 
			
			filters[bi] = instanceA;
			filters[ai] = instanceB;
			
			dispatchEvent(new OnyxEvent(OnyxEvent.FILTER_MOVE, instanceA));
			dispatchEvent(new OnyxEvent(OnyxEvent.FILTER_MOVE, instanceB));
			
			return true;
		}
		
		/**
		 * 	@public
		 */
		public function clear(color:uint = 0x00):void {
			internalSurface.fillRect(rectangle, color);
		}

		/**
		 * 	@public
		 */
		public function clearFilters():void {
			while (filters.length) {
				removeFilter(filters[0]);
			}
		}
		
		/**
		 * 	@public
		 */
		public function getFilters():Vector.<IPluginFilter> {
			return Vector.<IPluginFilter>(filters);
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
			
			const data:Object	= super.serialize(options) || {};
			
			if (filters.length) {
				var serializedFilters:Array	= [];
				for each (var filter:IPluginFilterCPU in this.filters) {
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
	}
}