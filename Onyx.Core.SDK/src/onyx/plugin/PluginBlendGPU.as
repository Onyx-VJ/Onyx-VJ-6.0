package onyx.plugin {
	
	import onyx.core.*;
	import onyx.display.*;

	public class PluginBlendGPU extends PluginBase {
		
		/**
		 * 	@protected
		 */
		protected var context:IDisplayContextGPU;
		
		/**
		 * 	@public
		 */
		public function initialize(context:IDisplayContextGPU):PluginStatus {
			
			// store
			this.context = context;
			
			// return
			return PluginStatus.OK;
		}
	}
}