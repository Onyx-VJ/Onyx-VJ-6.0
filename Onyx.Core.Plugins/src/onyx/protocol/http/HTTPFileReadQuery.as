package onyx.protocol.http {
	
	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	import flash.system.*;
	
	import onyx.*;
	import onyx.core.*;
	import onyx.media.*;
	import onyx.util.*;
	import onyx.util.encoding.*;
	
	use namespace parameter;
	
	final internal class HTTPFileReadQuery {
		
		private const callbacks:Vector.<Callback> = new Vector.<Callback>();
		
		private var loading:Boolean;
		private var callback:Function;
		public var file:HTTPFileReference;
		private var media:MediaStream;
		private var protocol:HTTPProtocol;
		private var domain:ApplicationDomain;
		
		/**
		 * 	@public
		 */
		public function HTTPFileReadQuery(protocol:HTTPProtocol, file:HTTPFileReference, domain:ApplicationDomain):void {
			this.protocol	= protocol;
			this.domain		= domain;
			this.file		= file;
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
			
			if (loading) {
				return;
			}
			
			switch (file.extension) {
				case 'flv':
				case 'f4v':
					
					media = new MediaStream();
					media.addEventListener(NetStatusEvent.NET_STATUS, handleMedia);
					media.bufferTime = 3;
					media.load(file.path);
					media.pause();

					break;
				case 'swf':
				case 'png':
				case 'jpg':
				case 'jpeg':
				case 'gif':
					
					const loader:Loader		= new Loader();
					const info:LoaderInfo	= loader.contentLoaderInfo;
					info.addEventListener(Event.COMPLETE,			handleQuerySWF);
					info.addEventListener(IOErrorEvent.IO_ERROR,	handleQuerySWF);
					loader.load(new URLRequest(protocol.rootPath + file.path), new LoaderContext(false, domain));
					
					break;
				default:
					
					const uloader:URLLoader = new URLLoader();
					uloader.addEventListener(Event.COMPLETE,		handleQuery);
					uloader.addEventListener(IOErrorEvent.IO_ERROR,	handleQuery);
					uloader.dataFormat = URLLoaderDataFormat.TEXT;
					uloader.load(new URLRequest(protocol.rootPath + file.path));
					
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
			
			const info:LoaderInfo		= event.currentTarget as LoaderInfo;
			info.removeEventListener(Event.COMPLETE,		handleQuerySWF);
			info.removeEventListener(IOErrorEvent.IO_ERROR,	handleQuerySWF);
			
			if (event is ErrorEvent) {
				return Console.LogError(protocol.rootPath + file.path, 'does not exist');
			}
			
			callback(file, info, callbacks);

		}
		
		/**
		 * 	@private
		 */
		private function handleQuery(event:Event):void {

			const loader:URLLoader = event.currentTarget as URLLoader;
			loader.removeEventListener(Event.COMPLETE, handleQuery);
			loader.removeEventListener(IOErrorEvent.IO_ERROR, handleQuery);
			
			var data:Object;
			
			switch (file.extension) {
				case 'conf':
					try {
						
						var str:String = loader.data;
						// replace all comments
						data = Serialize.fromJSON(loader.data);
						
					} catch (e:Error) {
						
						CONFIG::DEBUG {
							throw e;
						}
					}
					break;
				default:
					
					data = loader.data.replace(/\r\n/g, '\n');
					
					break;
			}
			
			callback(file, data, callbacks);
			
		}
	}
}