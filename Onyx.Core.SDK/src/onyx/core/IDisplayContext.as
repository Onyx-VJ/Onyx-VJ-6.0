package onyx.core {
	
	import flash.events.*;
	
	import onyx.core.*;
	import onyx.parameter.*;
	import onyx.plugin.*;
	
	/**
	 * 	@public
	 */
	public interface IDisplayContext extends IEventDispatcher {
		
		/**
		 * 	@public
		 */
		function get width():int;
		
		/**
		 * 	@public
		 */
		function get height():int;
		
		/**
		 * 	@public
		 */
		function get frameRate():Number;

	}
}