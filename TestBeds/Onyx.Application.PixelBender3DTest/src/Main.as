package {

	import com.adobe.pixelBender3D.*;
	
	import flash.display.*;
	import flash.filesystem.*;

	final public class Main extends Sprite {

		/**
		 *	@constructor
		 */
		public function Main():void {

			stage.nativeWindow.activate();
			
			var pbmk:String				= readFile(File.applicationDirectory.resolvePath('Test.pbmk'));
			var pbvk:String				= readFile(File.applicationDirectory.resolvePath('Test.pbvk'));
			var pair:AGALProgramPair	= PBASMCompiler.compile(new PBASMProgram(pbvk), new PBASMProgram(pbmk), null);
			trace(pair.fragmentProgram);
			
		}
		
		/**
		 * 	@private
		 */
		private function readFile(file:File):String {
			
			const stream:FileStream	= new FileStream();
			stream.open(file, FileMode.READ);
			const data:String		= stream.readUTFBytes(stream.bytesAvailable);
			stream.close();
			
			return data;
		}
	}
}