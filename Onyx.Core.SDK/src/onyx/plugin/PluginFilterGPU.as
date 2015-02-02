package onyx.plugin {
	
	import com.adobe.utils.*;
	
	import flash.display.*;
	import flash.display3D.*;
	import flash.events.*;
	
	import onyx.core.*;
	import onyx.display.*;
	import onyx.event.*;
	import onyx.parameter.*;
	
	use namespace parameter;
	
	[ExportToOnyxSDK]

	public class PluginFilterGPU extends PluginFilterBase {
		
		/**
		 * 	@protected
		 */
		protected var context:IDisplayContextGPU;
		
		/**
		 * 	@protected
		 */
		protected var owner:IChannelGPU;
		
		/**
		 * 	@protected
		 */
		protected var program:IDisplayProgramGPU;
		
		/**
		 * 	@public
		 */
		public function initialize(owner:IChannelGPU, context:IDisplayContextGPU):PluginStatus {
			this.context	= context;
			this.owner		= owner;
			return PluginStatus.OK;
		}
		
		/**
		 * 	@protected
		 */
		final protected function compile(context:IDisplayContextGPU, vertexProgram:String, fragmentProgram:String):PluginStatus {
			
			try {
				
				// assemble
				const assembler:AGALMiniAssembler 	= new AGALMiniAssembler();
				program = context.requestProgram(
					assembler.assemble(Context3DProgramType.VERTEX,		vertexProgram),
					assembler.assemble(Context3DProgramType.FRAGMENT,	fragmentProgram)
				)
				
			} catch (e:Error) {
				return new PluginStatus('Error Compiling Plugin:' + e.message);
			}
			
			// return null;
			return null;
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
		final public function getOwner():IChannel {
			return owner;
		}
		
		/**
		 * 	@public
		 */
		override public function dispose():void {
			
			if (program) {
				context.releaseProgram(program);
			}
		}
	}
}