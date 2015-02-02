package onyx.core {
	
	import flash.display.*;
	import flash.geom.*;
	
	import onyx.core.*;
	import onyx.display.*;
	import onyx.plugin.*;
	
	[Compiler(Link)]
	
	public interface IPluginBlendCPU extends IPluginBlend {
		
		/**
		 * 	@public
		 */
		function initialize(context:IDisplayContextCPU):PluginStatus;
		
		/**
		 * 	Public
		 */
		function render(target:DisplaySurface, base:DisplaySurface, blend:DisplaySurface, transform:ColorTransform = null, matrix:Matrix = null, clip:Rectangle = null):Boolean;
		
	}
}