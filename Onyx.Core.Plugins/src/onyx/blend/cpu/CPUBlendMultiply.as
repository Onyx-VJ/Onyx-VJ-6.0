package onyx.blend.cpu {
	
	import flash.display.*;
	import flash.geom.*;
	
	import onyx.blend.*;
	import onyx.core.*;
	import onyx.display.*;
	import onyx.plugin.*;
	
	[PluginInfo(
		id			= 'Onyx.Display.Blend.Multiply::CPU',
		name		= 'Multiply',
		vendor		= 'Daniel Hai',
		version		= '1.0',
		depends		= 'Onyx.Core.Display'
	)]
	
	public final class CPUBlendMultiply extends CPUBlendNative implements IPluginBlendCPU {
		
		/**
		 * 	@constructor
		 */
		public function CPUBlendMultiply():void {
			super(BlendMode.MULTIPLY);
		}
	}
}