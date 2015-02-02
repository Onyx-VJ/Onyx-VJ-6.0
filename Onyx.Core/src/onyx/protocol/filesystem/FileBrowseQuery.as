package onyx.protocol.filesystem {
	
	import flash.events.*;
	import flash.filesystem.*;
	import flash.net.*;
	
	import onyx.core.*;
	import onyx.util.*;
	
	public final class FileBrowseQuery {
		
		/**
		 * 	@private
		 */
		private var file:FileSystemReference;
		
		/**
		 * 	@private
		 */
		private var callback:Callback;
		
		/**
		 * 	@private
		 */
		private var protocol:FileSystemProtocol;
		
		/**
		 * 	@public
		 */
		public function FileBrowseQuery(protocol:FileSystemProtocol):void {
			
			this.protocol	= protocol;
			this.file		= new FileSystemReference(protocol, '');
			
			CONFIG::DEBUG { GC.watch(this); }

		}

		/**
		 * 	@private
		 */
		public function initialize(directory:IFileReference, callback:Callback):void {
			
			this.callback	= callback;
			
			// copy path
			file.nativePath	= (directory as FileSystemReference).nativePath;
			
			// save?
			file.addEventListener(Event.SELECT, 	handler);
			file.addEventListener(Event.CANCEL,		handler);
			file.browseForSave('Select save location');

		}
		
		/**
		 * 	@private
		 */
		private function handler(event:Event):void {
			
			file.removeEventListener(Event.SELECT,	handler);
			file.removeEventListener(Event.CANCEL,	handler);
			
			// exec
			callback.exec(file);
			callback	= null;
			file		= null;

		}
	}
}