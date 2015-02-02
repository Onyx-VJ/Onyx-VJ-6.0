package onyx.blend.cpu {
	
	import flash.display.*;
	import flash.geom.*;
	
	import onyx.blend.*;
	import onyx.core.*;
	import onyx.display.*;
	import onyx.plugin.*;
	
	[PluginInfo(
		id			= 'Onyx.Display.Blend.Invert::CPU',
		name		= 'Invert',
		vendor		= 'Daniel Hai',
		version		= '1.0',
		depends		= 'Onyx.Core.Display'
	)]
	
	public final class CPUBlendInvert extends CPUBlendNative implements IPluginBlendCPU {
		
		/**
		 * 	@constructor
		 */
		public function CPUBlendInvert():void {
			super(BlendMode.INVERT);
		}
	}
}