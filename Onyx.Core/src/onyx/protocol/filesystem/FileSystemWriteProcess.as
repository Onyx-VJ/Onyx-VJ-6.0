package onyx.protocol.filesystem {
	
	import flash.events.*;
	import flash.filesystem.*;
	import flash.net.*;
	import flash.utils.*;
	
	import onyx.core.*;
	import onyx.util.*;
	
	public final class FileSystemWriteProcess {
		
		/**
		 * 	@private
		 */
		private var file:FileSystemReference;
		private var callback:Callback;
		private var stream:FileStream;

		/**
		 * 	@private
		 */
		public function initialize(ref:IFileReference, bytes:ByteArray, callback:Callback):void {
			
			this.callback	= callback;
			this.file		= ref as FileSystemReference;
			
			stream			= new FileStream();
			stream.addEventListener(Event.CLOSE,			handler);
			stream.addEventListener(IOErrorEvent.IO_ERROR,	handler);
			stream.openAsync(file, FileMode.WRITE);
			stream.writeBytes(bytes);
			stream.close();

		}
		
		/**
		 * 	@private
		 */
		private function handler(event:Event):void {
			
			stream.removeEventListener(Event.CLOSE,				handler);
			stream.removeEventListener(IOErrorEvent.IO_ERROR,	handler);
			stream.close();
			
			switch (event.type) {
				case IOErrorEvent.IO_ERROR:
					
					callback.exec(new Error((event as IOErrorEvent).text));
					
					break;
				case Event.CLOSE:
					
					callback.exec();
					
					break;
			}

			stream		= null;
			file		= null;

		}
	}
}