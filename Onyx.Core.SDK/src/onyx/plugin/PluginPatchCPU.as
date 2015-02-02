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
	
	// TODO
	// PUT THIS IN THE APPLICATION
	public class PluginPatchCPU extends PluginPatchBase implements IPluginGeneratorCPU {
		
		/**
		 * 	@public
		 */
		parameter const matrix:Matrix				= new Matrix();
		
		/**
		 * 	@protected
		 */
		protected var context:IDisplayContextCPU;
		
		/**
		 * 	@protected
		 */
		protected var channel:IChannelCPU;
		
		/**
		 * 	@public
		 */
		public function render(context:IDisplayContextCPU):Boolean {
			return false;
		}
		
		/**
		 * 	@public
		 */
		public function initialize(context:IDisplayContextCPU, channel:IChannelCPU, file:IFileReference, content:Object):PluginStatus {
			
			this.context			= context;
			this.file				= file;
			this.content			= this;
			this.channel			= channel;
			
			// set up
			setupParameters();

			// success
			return PluginStatus.OK;
		}
		
		/**
		 * 	@public
		 */
		public function getChannel():IChannel {
			return channel;
		}
	}
}