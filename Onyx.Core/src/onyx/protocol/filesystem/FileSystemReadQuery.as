package onyx.protocol.filesystem {
	
	import flash.display.*;
	import flash.events.*;
	import flash.filesystem.*;
	import flash.net.*;
	import flash.system.*;
	import flash.utils.*;
	
	import onyx.core.*;
	import onyx.media.*;
	import onyx.plugin.*;
	import onyx.util.*;
	import onyx.util.encoding.*;
	
	final internal class FileSystemReadQuery {
		
		private const callbacks:Vector.<Callback>			= new Vector.<Callback>();
		
		private var loading:Boolean;
		private var callback:Function;
		public var file:FileSystemReference;
		private var media:MediaStream;
		private var domain:ApplicationDomain;
		private var loader:Loader;
		
		/**
		 * 	@public
		 */
		public function FileSystemReadQuery(protocol:FileSystemProtocol, file:FileSystemReference, domain:ApplicationDomain):void {
			
			this.file		= file as FileSystemReference;
			this.domain		= domain || protocol.domain;
			
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
		public function load(callback:Callback, complete:Function):void {
			
			callbacks.push(callback);
			
			this.callback = complete;
			
			if (loading) {
				return;
			}
			
			switch (file.extension) {
				
				case 'flv':
				case 'f4v':
					
					media = new MediaStream();
					media.addEventListener(NetStatusEvent.NET_STATUS, handleMedia);
					media.load(file.nativePath);
					media.pause();
					
					break;
				
				case 'png':
				case 'jpg':
				case 'jpeg':
				case 'gif':
					
					var context:LoaderContext	= new LoaderContext();
					context.allowCodeImport		= true;
					context.applicationDomain	= new ApplicationDomain(ApplicationDomain.currentDomain);
					
					loader 	= new Loader();
					loader.contentLoaderInfo.addEventListener(Event.COMPLETE,											handleQuerySWF);
					loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,									handleQuerySWF);
					loader.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR,											handleErrorSWF);
					loader.load(new URLRequest(file.nativePath), context);
					
					break;
				
				// swfs should use loadbytes
				default:

					const stream:FileStream	= new FileStream();
					stream.addEventListener(Event.COMPLETE,			handleQuery);
					stream.addEventListener(IOErrorEvent.IO_ERROR,	handleQuery);
					stream.openAsync(file, FileMode.READ);

					break;
			}
			
			loading	= true;
			
		}
		
		/**
		 * 	@private
		 */
		private function handleMedia(event:NetStatusEvent):void {
			
			const media:MediaStream	= event.currentTarget as MediaStream;
			
			switch (event.info.code) {
				
				// success
				case 'NetStream.Play.Metadata':
					
					media.removeEventListener(NetStatusEvent.NET_STATUS, handleMedia);
					callback(file, media, callbacks);
					
					break;
				case 'NetStream.Play.StreamNotFound':
					
					media.removeEventListener(NetStatusEvent.NET_STATUS, handleMedia);
					
					callback(file, null, callbacks);
					
					break;
			}
			
		}
		
		/**
		 * 	@private
		 */
		private function handleQuerySWF(event:Event):void {
			
			const info:LoaderInfo	= event.currentTarget as LoaderInfo;
			info.removeEventListener(Event.COMPLETE,		handleQuerySWF);
			info.removeEventListener(IOErrorEvent.IO_ERROR,	handleQuerySWF);
			loader.uncaughtErrorEvents.removeEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, handleErrorSWF);
			
			this.callback(file);

			for each (var callback:Callback in callbacks) {
				callback.exec(info, file);
			}
			
			// test me
			loader = null;
			
		}
		
		/**
		 * 	@private
		 */
		private function handleErrorSWF(e:UncaughtErrorEvent):void {
			
			const info:LoaderInfo		= loader.contentLoaderInfo;
			info.removeEventListener(Event.COMPLETE,		handleQuerySWF);
			info.removeEventListener(IOErrorEvent.IO_ERROR,	handleQuerySWF);
			loader.uncaughtErrorEvents.removeEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, handleErrorSWF);
			
			Console.Log(CONSOLE::ERROR, e.text);
			
			// set loader to null
			loader		= null;
			callback	= null;
			
		}
		
		/**
		 * 	@private
		 */
		private function handleQuery(event:Event):void {
			
			const stream:FileStream	= event.currentTarget as FileStream;
			stream.removeEventListener(Event.COMPLETE,			handleQuery);
			stream.removeEventListener(IOErrorEvent.IO_ERROR,	handleQuery);
			
			if (event is ErrorEvent) {
				return Console.LogError('Error loading', file.name, (event as ErrorEvent).text);
				
			} else {
				
				switch (file.extension) {
					case 'swf':
						
						var bytes:ByteArray = new ByteArray();
						stream.readBytes(bytes);
						
						loader						= new Loader();
						const info:LoaderInfo		= loader.contentLoaderInfo;
						const context:LoaderContext	= new LoaderContext();
						context.applicationDomain	= domain;
						context.allowCodeImport		= true;
						
						info.addEventListener(Event.COMPLETE,			handleQuerySWF);
						info.addEventListener(IOErrorEvent.IO_ERROR,	handleQuerySWF);
						
						// load bytes?
						loader.loadBytes(bytes, context);
						
						break;
					
					// read pixel bender file
					case 'pbj':
						
						bytes = new ByteArray();
						stream.readBytes(bytes);
						
						// pass the shader
						callback(file, new Shader(bytes), callbacks);

						break;
					// read text
					default:
						
						var str:String	= stream.readUTFBytes(stream.bytesAvailable);
						var data:Object;
						
						// by default we're reading as string -- replace comments in json files
						// remove multi-line breaks
						switch (file.extension) {
							case 'conf':
								try {
									data = Serialize.fromJSON(str);
								} catch (e:Error) {
									
									Console.LogError('Error reading: ', file.path, e.message, Serialize.replaceComments(str));

								}
								break;
							default:
								data = str.replace(/\r\n/g, '\n');
								break;
						}
						
						// execute the callback
						this.callback(file);
						
						for each (var callback:Callback in callbacks) {
							callback.exec(data, file);
						}
						
						break;
				}
			}
			
			stream.close();
		}
		
	}
}