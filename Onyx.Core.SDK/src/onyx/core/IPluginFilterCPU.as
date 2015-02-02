package onyx.core {
	
	import flash.display.*;
	
	import onyx.core.*;
	import onyx.display.*;
	import onyx.plugin.*;
	
	[Compiler(Link)]
	
	public interface IPluginFilterCPU extends IPluginFilter, IDisplayCPURenderable {
		
		/**
		 * 	@public
		 */
		function initialize(owner:IChannelCPU, context:IDisplayContextCPU):PluginStatus;

	}
}