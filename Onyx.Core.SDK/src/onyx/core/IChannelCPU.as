package onyx.core {

	import flash.display.*;
	import flash.geom.*;
	
	import onyx.display.*;
	
	public interface IChannelCPU extends IChannel {
		
		/**
		 * 	@public
		 * 	Swap the surface's channel with this one
		 */
		function swapSurface(surface:DisplaySurface):void;
		
		/**
		 *	@public
		 */
		function get surface():DisplaySurface;

	}
}