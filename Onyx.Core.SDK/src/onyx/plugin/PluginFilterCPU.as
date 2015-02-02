package onyx.plugin {
	
	import flash.events.*;
	
	import onyx.core.*;
	import onyx.display.*;
	import onyx.event.*;
	import onyx.parameter.*;
	
	use namespace parameter;
	
	[Parameter(id='muted',	target='muted', type='boolean', display='false')]
	public class PluginFilterCPU extends PluginFilterBase {
		
		/**
		 * 	@protected
		 */
		protected var context:IDisplayContextCPU;
		
		/**
		 * 	@protected
		 */
		protected var owner:IChannelCPU;
		
		/**
		 * 	@public
		 */
		public function get type():uint {
			return Plugin.CPU;
		}
		
		/**
		 * 	@public
		 */
		final public function getOwner():IChannel {
			return owner;
		}
	}
}