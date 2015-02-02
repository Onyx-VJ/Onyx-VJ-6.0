package onyx.plugin {
	
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.media.*;
	
	import onyx.core.*;
	import onyx.display.*;
	import onyx.event.*;
	import onyx.plugin.*;
	import onyx.util.*;
	
	use namespace parameter;

	public class PluginGeneratorCPU extends PluginGenerator {
		
		/**
		 * 	@protected
		 */
		protected var channel:IChannelCPU;
		
		/**
		 * 	@protected
		 */
		protected var context:IDisplayContextCPU;
		
		/**
		 * 	@public
		 */
		public function initialize(context:IDisplayContextCPU, channel:IChannelCPU, file:IFileReference, content:Object):PluginStatus {
			
			this.context	= context;
			this.channel	= channel;
			this.file		= file;
			
			// success
			return PluginStatus.OK;
		}
		
		/**
		 * 	@final
		 */
		final public function getChannel():IChannel {
			return channel;
		}
	}
}