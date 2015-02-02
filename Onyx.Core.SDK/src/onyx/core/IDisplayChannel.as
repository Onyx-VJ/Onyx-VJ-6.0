package onyx.core {
	
	import flash.events.*;
	
	import onyx.core.*;
	import onyx.parameter.*;
	import onyx.plugin.*;
	
	public interface IDisplayChannel extends IPlugin {
		
		/**
		 * 	@public
		 */
		function getChannels():Vector.<IChannel>;

	}
}