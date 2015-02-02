package onyx.core {
	
	import flash.geom.*;
	
	import onyx.display.*;
	import onyx.plugin.*;
	
	[Compiler(Link)]
	
	public interface IPluginBlendGPU extends IPluginBlend {
		
		/**
		 * 	@public
		 */
		function initialize(context:IDisplayContextGPU):PluginStatus;
		
		/**
		 * 	@public
		 */
		function render(base:DisplayTexture, blend:DisplayTexture, transform:ColorTransform = null):Boolean;

	}
}