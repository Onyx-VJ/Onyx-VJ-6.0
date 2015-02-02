package onyx.blend.cpu {
	
	import flash.display.*;
	import flash.geom.*;
	
	import onyx.blend.*;
	import onyx.core.*;
	import onyx.display.*;
	import onyx.plugin.*;
	
	[PluginInfo(
		id			= 'Onyx.Display.Blend.Normal::CPU',
		name		= 'Normal',
		vendor		= 'Daniel Hai',
		version		= '1.0',
		depends		= 'Onyx.Core.Display'
	)]
	
	public final class CPUBlendNormal extends PluginBase implements IPluginBlendCPU {
		
		/**
		 * 	@public
		 */
		public function initialize(context:IDisplayContextCPU):PluginStatus {
			return PluginStatus.OK;
		}
		
		/**
		 * 	@public
		 */
		final public function render(target:DisplaySurface, base:DisplaySurface, blend:DisplaySurface, transform:ColorTransform = null, matrix:Matrix = null, clip:Rectangle = null):Boolean {
			
			if (transform) {
				
				// 0, don't do anything
				if (transform.alphaMultiplier === 0) {
					return false;
					
				} else if (transform.alphaMultiplier !== 1 || transform.redMultiplier !== 1 || transform.greenMultiplier !== 1 || transform.blueMultiplier !== 1) {
					
					if (target !== base) {
						target.copyPixels(base, base.rect, CONST_IDENTITY);
					}
					
					target.draw(blend, matrix, transform, null, clip);
					
					return true;
				} else {
					
					if (target !== base) {
						target.copyPixels(base, null, null);
					}
					
					target.copyPixels(blend, null, null, null, null, true);
					
					return true;
				}
				
			} else {
				
				if (target !== base) {
					target.copyPixels(base, base.rect, CONST_IDENTITY);
				}
				
				
				target.copyPixels(blend, null, null, null, null, true);
				
				return true;
			}
		}
	}
}