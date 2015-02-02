package onyx.plugin {
	
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	
	import onyx.core.*;
	import onyx.display.*;
	import onyx.event.*;
	import onyx.parameter.*;
	
	use namespace onyx_ns;
	use namespace parameter;
	
	public class PluginPatchGPU extends PluginPatchBase implements IPluginGeneratorGPU {
		
		/**
		 * 	@protected
		 */
		protected var channel:IChannelGPU;
		
		/**
		 * 	@protected
		 */
		protected var context:IDisplayContextGPU;

		/**
		 * 	@public
		 */
		public function initialize(context:IDisplayContextGPU, channel:IChannelGPU, file:IFileReference, content:Object):PluginStatus {
			
			this.context			= context;
			this.file				= file;
			this.content			= this;
			
			setupParameters();

			// success
			return PluginStatus.OK;
		}
		
		/**
		 * 	@public
		 */
		public function render(context:IDisplayContextGPU):Boolean {
			return false;
		}
		
		/**
		 * 	@public
		 */
		final public function getChannel():IChannel {
			return channel;
		}
	}
}