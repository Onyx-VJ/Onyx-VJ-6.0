package onyx.display.gpu {
	
	import flash.display3D.Program3D;
	import flash.utils.ByteArray;
	
	import onyx.core.*;

	public final class DisplayProgram implements IDisplayProgram {
		
		/**
		 * 	@private
		 */
		internal var vertexProgram:ByteArray;
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
		 * 	@public
		 */
		public function DisplayProgram(vert:ByteArray, frag:ByteArray, info:String):void {
			this.vertexProgram		= vert;
			this.fragmentProgram	= frag;
			this.info				= info;
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