package onyx.core {
	
	import flash.display.*;
	
	import onyx.core.*;
	import onyx.display.*;
	import onyx.plugin.*;
	
	[Compiler(Link)]

	public interface IPluginFilterGPU extends IPluginFilter, IPluginGPU {

		/**
		 * 	@public
		 */
		function initialize(owner:IChannelGPU, context:IDisplayContextGPU):PluginStatus;

		/**
		 * 	Public
		 */
		function render(context:IDisplayContextGPU):Boolean;

	}
}