package onyx.core {
	
	import flash.display.*;
	import flash.geom.*;
	
	import onyx.core.*;
	import onyx.display.*;
	import onyx.parameter.*;
	import onyx.plugin.*;
	
	public interface IPluginGeneratorGPU extends IPluginGenerator {
		
		/**
		 * 	@public
		 */
		function initialize(context:IDisplayContextGPU, channel:IChannelGPU, file:IFileReference, content:Object):PluginStatus;
	
		/**
		 * 	@public
		 */
		function render(context:IDisplayContextGPU):Boolean;

	}
}