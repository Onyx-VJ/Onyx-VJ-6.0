package onyx.protocol.filesystem {
	
	import flash.events.*;
	import flash.filesystem.*;
	
	import onyx.core.*;
	
	public final class FileSystemStream extends FileStream implements IFileStream {
		
		/**
		 * 	@private
		 */
		private var reference:FileSystemReference;
		
		/**
		 * 	@public
		 */
		public function get file():IFileReference {
			return reference;
		}
		
		/**
		 * 	@public
		 */
		override public function open(file:File, fileMode:String):void {
			super.open(reference = file as FileSystemReference, fileMode);
		}
		
		/**
		 * 	@public
		 */
		override public function openAsync(file:File, fileMode:String):void {
			super.openAsync(reference = file as FileSystemReference, fileMode);
		}
	}
}