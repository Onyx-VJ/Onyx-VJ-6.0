package onyx.host.gl {
	
	import flash.display3D.*;
	import flash.events.Event;
	import flash.geom.*;
	
	import onyx.core.*;
	import onyx.display.*;
	import onyx.plugin.*;
	
	use namespace onyx_ns;

	public final class PluginGLFilter extends PluginGLBase implements IPluginFilterGPU {
		
		/**
		 * 	@private
		 */
		internal var program:IDisplayProgramGPU;
		
		/**
		 * 	@internal
		 */
		internal var owner:IChannelGPU;
		
		/**
		 * 	@public
		 */
		public function initialize(owner:IChannelGPU, context:IDisplayContextGPU):PluginStatus {
			
			const plugin:PluginGL = definition as PluginGL;
			if (!plugin || !context) {
				return new PluginStatus('No Context or Plugin!');
			}
			
			// set program
			this.context		= context;
			this.program		= plugin.createProgram(context);
			
			// success!
			return PluginStatus.OK;
		}
		
		/**
		 * 	@public
		 */
		public function getContext():IDisplayContextGPU {
			return context;
		}

		/**
		 * 	@public
		 */
		public function getFlags():uint {
			return 0;
		}
		
		/**
		 * 	@public
		 */
		public function get type():uint {
			return Plugin.GPU;
		}
		
		/**
		 * 	@public
		 */
		public function toggleFlag(flag:uint):void {
		}
		
		/**
		 * 	@public
		 */
		public function render(context:IDisplayContextGPU):Boolean {
			
			// program
			context.bindProgram(program);
			
			if (dataFrag) {
				context.uniform(Context3DProgramType.FRAGMENT, dataFrag);
			}
			
			if (dataVert) {
				context.uniform(Context3DProgramType.VERTEX, dataVert);
			}

			// set textures
			context.setTextureAt(0, context.texture);
			context.setTextureAt(1, null);
			
			// draw the program
			context.drawProgram();
			
			// swap the buffer
			return true;
		}
		
		/**
		 * 	@public
		 */
		public function getOwner():IChannel {
			return owner;
		}
		
		/**
		 * 	@public
		 */
		override public function dispose():void {
			
			(this.plugin as PluginGL).release(context);
			
			super.dispose();
			
		}
	}
}