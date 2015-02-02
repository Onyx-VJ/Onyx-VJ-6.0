package onyx.core {

	import flash.display.*;
	import flash.geom.*;
	
	import onyx.display.*;
	import onyx.plugin.PluginStatus;
	
	public interface IChannelGPU extends IChannel {
		
		/**
		 * 	@public
		 * 	Returns the surface instance
		 */
		function swapTexture(texture:DisplayTexture):void;
		
		/**
		 * 	@public
		 * 	Returns the surface instance
		 */
		function get texture():DisplayTexture;

	}
}