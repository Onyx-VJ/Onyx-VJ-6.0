package onyx.core {
	
	import flash.display.*;
	import flash.geom.*;
	
	import onyx.core.*;
	import onyx.display.*;
	import onyx.parameter.*;
	import onyx.plugin.*;
	
	public interface IPluginGeneratorCPU extends IPluginGenerator {
		
		/**
		 * 	@public
		 */
		function initialize(context:IDisplayContextCPU, channel:IChannelCPU, file:IFileReference, content:Object):PluginStatus;
	
		/**
		 * 	@public
		 */
		function render(context:IDisplayContextCPU):Boolean;

	}
}