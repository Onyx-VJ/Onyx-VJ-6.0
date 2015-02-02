package onyx.host.gl {
	
	import flash.display3D.*;
	import flash.events.Event;
	import flash.geom.*;
	
	import onyx.core.*;
	import onyx.display.*;
	import onyx.plugin.*;
	
	use namespace onyx_ns;

	public final class PluginGLBlend extends PluginGLBase implements IPluginBlendGPU {
		
		/**
		 * 	@private
		 */
		private var program:IDisplayProgramGPU;
		
		/**
		 * 	@public
		 */
		public function initialize(context:IDisplayContextGPU):PluginStatus {
			
			// set program
			this.context		= context;
			this.program		= (definition as PluginGL).createProgram(context);
			
			// return
			return PluginStatus.OK;
		}
		
		/**
		 * 	@public
		 */
		public function render(base:DisplayTexture, blend:DisplayTexture, transform:ColorTransform = null):Boolean {
			
			if (transform && transform.alphaMultiplier === 0) {
				return false;
			}
			
			if (transform) {
				
				// set values
				setParameterValue('colorTransform', Vector.<Number>([transform.redMultiplier, transform.greenMultiplier, transform.blueMultiplier, transform.alphaMultiplier]));
				
			} else {
				
				// set values
				setParameterValue('colorTransform', Vector.<Number>([1, 1, 1, 1]));
				
			}
			
			// program
			context.bindProgram(program);
			
			if (dataFrag) {
				context.uniform(Context3DProgramType.FRAGMENT, dataFrag);
			}
			
			if (dataVert) {
				context.uniform(Context3DProgramType.VERTEX, dataVert);
			}
			
			// set textures
			context.setTextureAt(0, base);
			context.setTextureAt(1, blend);
			
			// draw the program
			context.drawProgram();
			
			return true;
		}
		
		/**
		 * 	@public
		 */
		override public function dispose():void {
			
			(definition as PluginGL).release(context);
			
			super.dispose();
		}
	}
}