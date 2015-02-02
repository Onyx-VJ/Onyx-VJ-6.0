package onyx.core {
	
	import onyx.display.*;
	import onyx.plugin.*;

	public interface IPluginRenderGPU extends IPluginGPU {
		
		/**
		 * 	@public
		 */
		function initialize(owner:IChannelGPU, context:IDisplayContextGPU):PluginStatus;
		
		/**
		 * 	Public
		 */
		function render(context:IDisplayContextGPU, texture:DisplayTexture):Boolean;

	}
	
}