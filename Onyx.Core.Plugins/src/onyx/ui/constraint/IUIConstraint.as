package onyx.ui.constraint {
	
	import flash.geom.*;
	
	import onyx.ui.core.*;
	
	// TODO, make everything even smaller memory-wise
	
	public interface IUIConstraint {

		/**
		 * 	@public
		 */
		function unserialize(token:Object):void;
		
		/**
		 * 	@public
		 */
		function measure(parent:UIRect):UIRect;
		
	}
}