package onyx.ui.core {
	
	import flash.events.*;
	
	import onyx.core.IDisposable;

	public interface IUIObject extends IDisposable, IEventDispatcher {
		
		/**
		 * 	@public
		 */
		function arrange(rect:UIRect):void;
		
		/**
		 * 	@public
		 */
		function measure(bounds:UIRect):UIRect;

	}
}