package onyx.display {
	
	import flash.display3D.*;
	import flash.utils.*;
	
	import onyx.core.*;

	public final class DisplayProgram implements IDisplayProgramGPU {
		
		/**
		 * 	@private
		 */
		internal var vertexProgram:ByteArray;
		
		/**
		 * 	@internal
		 */
		internal var fragmentProgram:ByteArray;
		
		/**
		 * 	@internal
		 */
		internal var program:Program3D;
		
		/**
		 * 	@private
		 */
		private var info:String;
		
		/**
		 * 	@private
		 */
		private var context:DisplayContextGPU;
		
		/**
		 * 	@public
		 */
		public function DisplayProgram(context:DisplayContextGPU, vert:ByteArray, frag:ByteArray, info:String):void {
			this.vertexProgram		= vert;
			this.fragmentProgram	= frag;
			this.info				= info;
			this.context			= context;
		}
		
		/**
		 * 	@public
		 */
		public function get nativeProgram():Program3D {
			return program;
		}
		
		/**
		 * 	@public
		 */
		public function dispose():void {
			program.dispose();
		}
		
		/**
		 * 	@public
		 */
		public function toString():String {
			return '[Program: ' + info + ']';
		}
	}
}