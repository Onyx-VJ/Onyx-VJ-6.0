package onyx.blend {
	
	import flash.display.*;
	import flash.geom.*;
	
	import onyx.core.*;
	import onyx.display.*;
	import onyx.plugin.*;
	
	public class CPUBlendNative extends PluginBase implements IPluginBlendCPU {
		
		/**
		 * 	@protected
		 */
		protected var blendMode:String;
		
		/**
		 * 	@public
		 */
		public function CPUBlendNative(blendMode:String):void {
			this.blendMode	= blendMode;
		}
		
		/**
		 * 	@public
		 */
		public function initialize(context:IDisplayContextCPU):PluginStatus {
			return PluginStatus.OK;
		}
		
		/**
		 * 	@public
		 * 	Returns true if anything happened.  If nothing happens, the buffer is not swapped
		 */
		final public function render(target:DisplaySurface, base:DisplaySurface, blend:DisplaySurface, transform:ColorTransform = null, matrix:Matrix = null, clip:Rectangle = null):Boolean {
			
			// nothing to draw, so don't
			if (transform && transform.alphaMultiplier <= 0) {
				return false;
			}
			
			base.draw(blend, matrix, transform, blendMode, clip);
			
			// return true to swap context
			return false;
		}
	}
}