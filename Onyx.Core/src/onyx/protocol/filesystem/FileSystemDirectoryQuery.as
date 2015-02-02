package onyx.protocol.filesystem {
	
	import flash.display.*;
	import flash.events.*;
	import flash.filesystem.*;
	import flash.net.*;
	
	import onyx.core.*;
	import onyx.util.*;
	
	final internal class FileSystemDirectoryQuery {
		
		/**
		 * 	@private
		 */
		private const callbacks:Vector.<Callback> = new Vector.<Callback>();
		
		/**
		 * 	@private
		 */
		private var callback:Function;
		
		/**
		 * 	@private
		 */
		private var filter:Callback;
		
		/**
		 * 	@private
		 */
		private var file:File;
		
		/**
		 * 	@private
		 */
		private var path:String;
		
		/**
		 * 	@private
		 */
		private var protocol:FileSystemProtocol;
		
		/**
		 * 	@public
		 */
		public function FileSystemDirectoryQuery(protocol:FileSystemProtocol, path:String, filter:Callback):void {
			
			this.protocol	= protocol;
			this.file		= protocol.getFileReference(path) as File;
			this.path		= path;
			this.filter		= filter;
			
			// CONFIG::DEBUG  { GC.watch(this); }

		}
		
		/**
		 * 	@public
		 */
		public function add(callback:Callback):void {
			callbacks.push(callback);
		}
		
		/**
		 * 	@public
		 */
		public function load(callback:Function):void {
			this.callback = callback;
			this.file.addEventListener(FileListEvent.DIRECTORY_LISTING, handleQuery);
			this.file.getDirectoryListingAsync();
		}
		
		/**
		 * 	@private
		 */
		private function handleQuery(event:FileListEvent):void {
			
			this.file.removeEventListener(FileListEvent.DIRECTORY_LISTING, handleQuery);
			const arr:Array = event.files;

			const files:Vector.<IFileReference>	= new Vector.<IFileReference>();
			for each (var file:File in arr) {

				var ref:IFileReference = new FileSystemReference(protocol, protocol.getRelativePath(file.nativePath));
				files.push(ref);

			}
			
			callback(path, files, callbacks);
		}
		
	}
}