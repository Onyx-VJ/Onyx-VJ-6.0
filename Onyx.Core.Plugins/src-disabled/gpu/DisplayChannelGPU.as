package onyx.display.gpu {
	
	import onyx.core.*;
	import onyx.display.Color;
	import onyx.plugin.*;
	
	final public class ChannelGPU {
		
		/**
		 * 	@public
		 */
		internal const filters:Vector.<IPluginFilterGPU>	= new Vector.<IPluginFilterGPU>();
		
		/**
		 * 	@private
		 */
		internal var context:DisplayContextGPU;
		
		/**
		 * 	@public
		 */
		public function getFilterIndex(instance:IPluginFilterGPU):int {
			if (!instance) {
				return -1;
			}
			return filters.indexOf(instance);
		}
		
		/**
		 * 	@public
		 */
		public function clearFilters():void {
			filters.length = 0;
		}
		
		/**
		 * 	@public
		 * 	Pass in the surface texture
		 */
		internal function renderFilters(context:DisplayContextGPU, texture:DisplayTexture):void {
//			
//			context.bindBuffer();
//			context.draw(generator);
//			
//			context.swapBuffer();
//			
//			// loop through the filters
//			for each (var filter:IPluginFilterGPU in filters) {
//
//				// pass in the previous buffer to the filter
//				filter.render(context.getBuffer());
//				
//				// swap the buffer
//				context.swapBuffer();
//
//			}
//			
//			// draw onto our buffer
//			context.bindTexture(texture);
//			context.clear(Color.CLEAR);
//			context.draw(context.getBuffer());
			
		}
		
		/**
		 * 	@public
		 */
		public function addFilter(instance:IPluginFilterGPU):Boolean {
			
			// nothing?
			if (!instance) {
				return false;
			}
			
			// initialize
			if (instance.initialize(context) !== PluginStatus.OK) {
				
				// kill the instance
				instance.dispose();
				
				return false;
			}
			
			// add the filter
			filters.push(instance);
			
			// blah poo
			return true;
		}
		
		/**
		 * 	@public
		 */
		public function removeFilter(instance:IPluginFilterGPU):Boolean {
			
			if (!instance) {
				return false;
			}
			
			const index:int = filters.indexOf(instance);
			if (index === -1) {
				return false;
			}
			
			// remove filters
			filters.splice(index, 1);
			
			// return
			return true;
		}
		
		/**
		 * 	@public
		 */
		public function swapFilters(a:IPluginFilterGPU, b:IPluginFilterGPU):Boolean {
			
			if (!a || !b) {
				return false;
			}
			
			const ai:int = filters.indexOf(a);
			const bi:int = filters.indexOf(b);
			
			CONFIG::DEBUG {
				if (ai === -1 || bi === -1) {
					CONFIG::DEBUG { throw new Error('FILTERS DONT EXIST!'); }
					return false;
				} 
			}
			
			filters[bi] = a;
			filters[ai] = b;
			
			return true;
		}
	}
}