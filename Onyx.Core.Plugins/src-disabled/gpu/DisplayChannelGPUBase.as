package onyx.display.gpu {
	
	import flash.events.*;
	
	import onyx.core.*;
	import onyx.event.*;
	import onyx.plugin.*;
	
	public class ChannelGPUBase extends PluginBase implements IChannelGPU {
		
		/**
		 * 	@protected
		 */
		CONFIG::DEBUG public const channel:ChannelGPU	= new ChannelGPU();
		
		/**
		 * 	@protected
		 */
		protected var context:DisplayContextGPU;
		
		/**
		 * 	@protected
		 */
		internal var texture:DisplayTexture;
		
		/**
		 * 	@protected
		 */
		protected function initializeChannel(context:IDisplayContextGPU, width:int, height:int):PluginStatus {
			
			this.context = context as DisplayContextGPU;
			if (!this.context) {
				return new PluginStatus('Error initializing context');
			}
			
			texture	= context.requestTexture(width, height, true);
			
			// ok!
			return PluginStatus.OK;
		}
		
		/**
		 * 	@public
		 */
		public function get channelName():String {
			return 'x';
		}
		
		/**
		 * 	@public
		 */
		public function getContext():IDisplayContext {
			return context;
		}
		
		/**
		 * 	@public
		 */
		final public function addFilter(instance:IPluginFilter):Boolean {
			return channel.addFilter(instance as IPluginFilterGPU);
		}
		
		/**
		 * 	@public
		 */
		public function getTexture():DisplayTexture {
			return texture;
		}
		
		/**
		 * 	@public
		 */
		final public function removeFilter(instance:IPluginFilter):Boolean {
			return channel.removeFilter(instance as IPluginFilterGPU);
		}
		
		/**
		 * 	@public
		 */
		final public function swapFilters(instanceA:IPluginFilter, instanceB:IPluginFilter):Boolean {
			return channel.swapFilters(instanceA as IPluginFilterGPU, instanceB as IPluginFilterGPU);
		}
		
		/**
		 * 	@public
		 */
		public function getFilterIndex(filter:IPluginFilter):int {
			return channel.getFilterIndex(filter as IPluginFilterGPU);
		}
		
		/**
		 * 	@public
		 */
		public function clearFilters():void {
			channel.clearFilters();
		}
		
		/**
		 * 	@public
		 */
		public function getFilters():Vector.<IPluginFilter> {
			return Vector.<IPluginFilter>(channel.filters);
		}
	}
}