package onyx.protocol.http {
	
	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	
	import onyx.core.*;
	import onyx.util.*;
	import onyx.util.encoding.*;
	
	use namespace parameter;
	
	final internal class HTTPDirectoryQuery {
		
		/**
		 * 	@private
		 */
		private const callbacks:Vector.<Callback> = new Vector.<Callback>();
		
		/**
		 * 	@private
		 */
		private var loader:URLLoader;
		
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
		private var path:String;
		
		/**
		 * 	@private
		 */
		private var protocol:HTTPProtocol;
		
		/**
		 * 	@public
		 */
		public function HTTPDirectoryQuery(protocol:HTTPProtocol, path:String, filter:Callback):void {
			this.protocol	= protocol;
			this.path		= path;
			this.filter		= filter;
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
			
			if (!loader) {
				
				loader = new URLLoader();
				loader.addEventListener(Event.COMPLETE,			handleQuery);
				loader.addEventListener(IOErrorEvent.IO_ERROR,	handleQuery);
				
				var path:String = protocol.queryPath + '\\' + this.path + '\\manifest.json';
				path = path.replace(/\\/g, '/');
				path = path.replace(/\/\//g, '/');
				
				Console.Log(CONSOLE::MESSAGE, 'Scanning:', path);
				loader.load(new URLRequest(path));
			};
		}
		
		/**
		 * 	@private
		 */
		private function handleQuery(event:Event):void {
			
			loader.removeEventListener(Event.COMPLETE,			handleQuery);
			loader.removeEventListener(IOErrorEvent.IO_ERROR,	handleQuery);
			
			CONFIG::DEBUG {
				if (event is ErrorEvent) {
					throw new Error((event as ErrorEvent).text);
				}
			}
			
			var obj:Object		= Serialize.fromJSON(loader.data);
			var manifest:Array	= obj.files as Array;
			if (manifest) {
				
				const files:Vector.<IFileReference>	= new Vector.<IFileReference>();
				for each (var path:Object in manifest) {
					var ref:IFileReference = new HTTPFileReference(protocol, path.path);
					files.push(ref);
				}
			}
			
			callback(path, files, callbacks);

		}
	}
}