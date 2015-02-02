package onyx.core {
	
	import flash.display3D.*;
	
	public interface IDisplayProgramGPU extends IDisposable {
		
		/**
		 * 	@public
		 */
		function get nativeProgram():Program3D;
		
	}
}