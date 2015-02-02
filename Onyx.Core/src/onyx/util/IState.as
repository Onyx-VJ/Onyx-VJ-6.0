package onyx.util {
	
	import flash.events.*;
	
	import onyx.core.*;

	public interface IState extends IDisposable {
		
		/**
		 * 	@public
		 */
		function initialize(callback:Callback, data:Object):void;

	}
}