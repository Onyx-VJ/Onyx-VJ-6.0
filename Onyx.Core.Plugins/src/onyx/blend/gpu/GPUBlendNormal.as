package onyx.blend.gpu {
	
	import flash.display3D.*;
	import flash.geom.*;
	
	import onyx.core.*;
	import onyx.display.*;
	import onyx.plugin.*;
	
	[PluginInfo(
		id			= 'Onyx.Display.Blend.Normal::GPU',
		name		= 'Normal',
		vendor		= 'Daniel Hai',
		version		= '1.0'
	)]
	
	public final class GPUBlendNormal extends PluginBase implements IPluginBlendGPU {
		
		/**
		 * 	@private
		 */
		private var context:IDisplayContextGPU;
		
		/**
		 * 	@public
		 */
		public function initialize(context:IDisplayContextGPU):PluginStatus {
			
			// return
			this.context	= context;
			
			// return
			return PluginStatus.OK;
		}
		
		/**
		 * 	@public
		 */
		public function render(base:DisplayTexture, blend:DisplayTexture, transform:ColorTransform = null):Boolean {
			
			// don't draw it
			if (transform && transform.alphaMultiplier === 0) {
				return false;
			}

			// draw the base
			context.blit(base);
			context.blitColorTransform(blend, transform);
			
			// return
			return true;
		}
	}
}