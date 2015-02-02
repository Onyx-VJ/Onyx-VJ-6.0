package onyx.display {
	
	import flash.geom.*;
	
	import onyx.core.*;
	import onyx.event.*;
	import onyx.plugin.*;
	
	[PluginInfo(
		id			= 'Onyx.Display.Channel::GPU',
		name		= 'Channel',
		vendor		= 'Daniel Hai',
		version		= '1.0'
	)]
	
	public class ChannelGPU extends PluginBase implements IChannelGPU {
		
		/**
		 * 	@public
		 */
		internal const filters:Vector.<IPluginFilterGPU>	= new Vector.<IPluginFilterGPU>();
		
		/**
		 * 	@private
		 */
		internal var internalTexture:DisplayTexture;
		
		/**
		 * 	@private
		 */
		internal var context:DisplayContextGPU;
		
		/**
		 * 	@internal
		 */
		internal var _name:String;
		
		/**
		 * 	@public
		 */
		public function initialize(context:IDisplayContextGPU):PluginStatus {
			
			this.context			= context as DisplayContextGPU;
			
			if (!this.context) {
				return new PluginStatus('Error with context: content is not ContextGPU!');
			}
			
			// create a texture
			this.internalTexture	= context.requestTexture(this.context.txWidth, this.context.txHeight, true);

			// return ok
			return PluginStatus.OK;
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
		override public function get name():String {
			return _name;
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
		public function get frameRate():Number {
			return 0;
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
			var instance:IPluginFilterGPU	= input as IPluginFilterGPU; 
			
			// nothing?
			if (!instance) {
				return false;
			}
			
			// initialize
			var status:PluginStatus = instance.initialize(this, context);
			if (status !== PluginStatus.OK) {
				
				Console.LogError(status);
				
				// kill the instance
				instance.dispose();
				
				// return false;
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
			
			var instance:IPluginFilterGPU	= input as IPluginFilterGPU;
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
			
			var instanceA:IPluginFilterGPU	= a as IPluginFilterGPU;
			var instanceB:IPluginFilterGPU	= b as IPluginFilterGPU;
			
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
		override public function toString():String {
			return this.name;
		}
	}
}