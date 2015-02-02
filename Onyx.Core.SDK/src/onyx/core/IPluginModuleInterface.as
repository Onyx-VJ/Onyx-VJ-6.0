package onyx.core {
	
	import flash.events.*;
	
	import onyx.core.*;
	import onyx.parameter.*;
	
	public interface IPluginModuleInterface extends IPluginModule {
		
		/**
		 * 	@public
		 */
		function addDispatcher(i:IEventDispatcher):void;

		/**
		 * 	@public
		 */
		function bind(key:uint, data:*):void;
		
		/**
		 * 	@public
		 */
		function unbind(key:uint):void;
		
		/**
		 * 	@public
		 */
		function formatMessage(key:uint):String;
		
		/**
		 * 	@public
		 * 	Can this interface bind this parameter
		 */
		function canBind(data:*):Boolean;

	}
}