package onyx.protocol.http {
	
	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	import flash.system.*;
	import flash.utils.*;
	
	import onyx.*;
	import onyx.core.*;
	import onyx.display.*;
	import onyx.plugin.*;
	import onyx.util.*;
	
	use namespace parameter;
		
	[PluginInfo(
		id			= 'Onyx.Protocol.HTTP',
		name		= 'Onyx.Protocol.HTTP',
		version		= '1.0',
		vendor		= 'Daniel Hai',
		description = 'HTTP Protocol'
	)]
	
	/**
	 * 	@public
	 */
	final public class HTTPProtocol extends PluginBase implements IPluginFileProtocol {
		
		/**
		 * 	@private
		 */
		parameter var rootPath:String;
		
		/**
		 * 	@private
		 */
		parameter var queryPath:String;

		/**
		 * 	@private
		 */
		private const HASH:Dictionary					= new Dictionary();
		
		/**
		 * 	@public
		 */
		public function get root():IFileReference {
			return new HTTPFileReference(this, '');
		}
		
		/**
		 * 	@public
		 */
		public function initialize(mapping:String, rootPath:String, domain:ApplicationDomain = null):PluginStatus {
			return PluginStatus.OK;
		}
		
		/**
		 * 	@public
		 */
		public function get protocol():String {
			return 'http';
		}
		
		/**
		 * 	@public
		 */
		public function browse(directory:IFileReference, callback:Callback):void {
			throw new Error('Not implemented');
		}
		
		/**
		 * 	@public
		 */
		public function write(file:IFileReference, bytes:ByteArray, callback:Callback):void {
			throw new Error('Not implemented');
		}
		
		/**
		 * 	@public
		 */
		public function load(reference:IFileReference, callback:Callback):void {
			
		}
		
		/**
		 * 	@public
		 */
		public function getFileReference(path:String):IFileReference {
			return new HTTPFileReference(this, path);
		}
		
		/**
		 * 	@public
		 */
		public function query(file:IFileReference, callback:Callback, filter:Callback = null):void {
			
			const pair:HTTPDirectoryQuery	= HASH[file.path] || (HASH[file.path] = new HTTPDirectoryQuery(this, file.path, filter));
			
			if (filter !== null) {
				
				pair.add(new Callback(filterFiles, [callback, filter]));
				pair.load(queryComplete);
				
				// call callback directly
			} else {
				
				pair.add(callback);
				pair.load(queryComplete);
				
			}
		}
		
		/**
		 * 	@private
		 */
		private function filterFiles(callback:Callback, filter:Callback, files:Vector.<IFileReference>):void {
			
			var count:int = files.length;
			var filtered:Array	= [];
			while (--count >= 0) {
				var file:IFileReference = files[count];
				if (filter.exec(file)) {
					filtered.unshift(file);
				}
			}

			callback.exec(Vector.<IFileReference>(filtered));
			
		}
		
		/**
		 * 	@private
		 */
		private function loadDefault(path:String, token:Object, callback:Callback):void {
			
			var instance:IPlugin;
			
			const file:IFileReference	= new HTTPFileReference(this, path);
			switch (file.extension) {
				case 'png':
				case 'jpg':
				case 'gif':
				case 'jpeg':
				case 'swf':
				case 'mp4':
				case 'flv':
				case 'f4v':
					return readFile(file, new Callback(handleLoad, [callback, token]));
			}
			
			callback.exec(null);
		}
		
		/**
		 * 	@public
		 */
		public function createFileStream(file:IFileReference, mode:String):IFileStream {
			return null;
		}
		
		/**
		 * 	@private
		 */
		private function handleLoad(callback:Callback, token:Object, data:Object, ref:IFileReference):void {
//			
//			var generator:IPluginGenerator;
//			
//			switch (ref.extension) {
//				case 'swf':
//					
//					if (data is PluginPatch) {
//						generator	= data as IPluginGenerator;
//						data		= ref;
//						
//						// attach parameters
//						(data as PluginPatch).attach(PluginSWF.Retrieve(generator, false));
//						
//					} else if (data is MovieClip) {
//						token.target	= data;
//						generator = Onyx.CreateInstance('Onyx.Generator.SWFMovie') as IPluginGenerator;
//					}
//					
//					break;
//				case 'mp4':
//				case 'flv':
//				case 'f4v':
//					generator	= Onyx.CreateInstance('Onyx.Generator.Movie') as IPluginGenerator;
//					break;
//				default:
//					generator = Onyx.CreateInstance('Onyx.Generator.Image') as IPluginGenerator;
//					break;
//			}
//			
//			if (!generator) {
//				return Console.Log(CONSOLE::ERROR, 'Unknown type', ref.path);
//			}
//			
//			// return
//			generator.setup(ref, data);
//			generator.unserialize(token);
//			
//			// return
//			callback.exec(generator);
		}
		
		/**
		 * 	@public
		 */
		public function readFile(path:IFileReference, callback:Callback, domain:ApplicationDomain = null, combine:Boolean = true):void {
			
			const file:HTTPFileReference = (path is HTTPFileReference) ? path as HTTPFileReference : new HTTPFileReference(this, String(path));
			if (!file.path) {
				return Console.Log(CONSOLE::ERROR, 'Error reading path:', path);
			}
			
			const pair:HTTPFileReadQuery = HASH[file.path] || (HASH[file.path] = new HTTPFileReadQuery(this, file, domain));
			
			pair.add(callback);
			pair.load(readComplete);
			
		}
		
		/**
		 * 	@private
		 */
		private function queryComplete(path:String, files:Vector.<IFileReference>, callbacks:Vector.<Callback>):void {
			for each (var callback:Callback in callbacks) {
				callback.exec(files);
			}
			delete HASH[path];
		}
		
		/**
		 * 	@private
		 */
		private function readComplete(file:IFileReference, data:Object, callbacks:Vector.<Callback>):void {
			for each (var callback:Callback in callbacks) {
				callback.exec(data, file);
			}
			delete HASH[file.path];
		}
	}
}