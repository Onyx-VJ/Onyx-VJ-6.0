package onyx.protocol.filesystem {
	
	import flash.display.*;
	import flash.events.*;
	import flash.filesystem.*;
	import flash.net.*;
	import flash.system.*;
	import flash.utils.*;
	
	import onyx.core.*;
	import onyx.display.*;
	import onyx.host.*;
	import onyx.plugin.*;
	import onyx.util.*;
	
	use namespace parameter;
	
	[PluginInfo(
		id			= 'Onyx.Protocol.FileSystem',
		name		= 'Onyx.Protocol.FileSystem',
		version		= '1.0',
		vendor		= 'Daniel Hai',
		description = 'FileSystem Protocol'
	)]
	final public class FileSystemProtocol extends PluginBase implements IPluginFileProtocol {
		
		/**
		 * 	@private
		 */
		private static const NORMALIZE_SLASHES:RegExp		= new RegExp('\\\\', 'g');
		
		/**
		 * 	@private
		 * 	This shares reads (do we need this)?
		 */
		private const HASH:Dictionary						= new Dictionary();
		
		/**
		 * 	@private
		 */
		internal var root:String;
		
		/**
		 * 	@private
		 */
		internal var mapping:String						= '';
		
		/**
		 * 	@internal
		 */
		internal var domain:ApplicationDomain;
		
		/**
		 * 	@public
		 */
		public function initialize(mapping:String, root:String, domain:ApplicationDomain = null):PluginStatus {
			
			var rootPath:File	= new File(root);
			if (!rootPath.exists || !rootPath.isDirectory) {
				return new PluginStatus('Root Path does not exist!');
			}
			
			// store stuff
			this.domain		= domain || ApplicationDomain.currentDomain;
			this.mapping	= normalize(mapping);
			this.root		= normalize(root);
			
			// return ok
			return PluginStatus.OK;
		}
		
		/**
		 * 	@public
		 * 	Normalizes a path
		 */
		public function normalize(path:String):String {
			return path.replace(NORMALIZE_SLASHES, '/');
		}
		
		/**
		 * 	@public
		 */
		public function getRelativePath(path:String):String {
			path = normalize(path);
			if (path.indexOf(root) === -1) {
				Console.LogError('Not a child of:', path, root);
				return path;
			}
			return path.replace(root, '');
		}
		
		/**
		 * 	@public
		 */
		public function getFileReference(path:String):IFileReference {
			return new FileSystemReference(this, path.substr(mapping.length));
		}
		
		/**
		 * 	@public
		 */
		public function query(file:IFileReference, callback:Callback, filter:Callback = null):void {
			
			const pair:FileSystemDirectoryQuery = HASH[file.path] || (HASH[file.path] = new FileSystemDirectoryQuery(this, file.path, filter));
			
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
		 * 	@public
		 * 	Loads content.  Should return a IPluginGenerator if custom or null if no custom generator
		 * 	The Filesystem host will determine based on the extension if null is passed
		 */
		public function load(file:IFileReference, callback:Callback):void {
			
			readFile(file, new Callback(handleLoad, [callback]), ContentDomain, false);
			
		}
		
		/**
		 * 	@public
		 */
		public function createFileStream(file:IFileReference, mode:String):IFileStream {
			const stream:FileSystemStream = new FileSystemStream();
			stream.openAsync(file as File, mode);
			return stream;
		}
		
		/**
		 * 	@private
		 */
		private function handleLoad(callback:Callback, data:Object, file:FileSystemReference):void {

			switch (file.extension) {
				case 'swf':
					var info:LoaderInfo	= data as LoaderInfo;
					if (info.content is IPluginGenerator) {
						callback.exec(file, data, info.content as IPluginGenerator);
						return;
					}
					break;
			}
			
			// by default, pass no generator, since we want the container to handle that
			callback.exec(file, data, null);
		}
		
		/**
		 * 	@public
		 */
		public function readFile(file:IFileReference, callback:Callback, domain:ApplicationDomain = null, combine:Boolean = true):void {
			
			if (!file.path || file.isDirectory) {
				return Console.LogError('Error reading path:', file.path);
			}
			
			var pair:FileSystemReadQuery;
			switch (file.extension) {
				
				// on movies, use a localstream, rather than re-using
				case 'flv':
				case 'f4v':
				case 'mp4':
					
					pair = new FileSystemReadQuery(this, file as FileSystemReference, domain);
					pair.load(callback, readComplete);
					
					break;
				default:
					
					if (combine) {
						pair = HASH[file.path] || (HASH[file.path] = new FileSystemReadQuery(this, file as FileSystemReference, domain));	
					} else {
						pair = new FileSystemReadQuery(this, file as FileSystemReference, domain);
					}
					pair.load(callback, readComplete);

			}
		}
		
		/**
		 * 	@public
		 */
		public function browse(location:IFileReference, callback:Callback):void {
			// new FileBrowseQuery().initialize(location, callback);
		}
		
		/**
		 * 	@public
		 */
		public function write(file:IFileReference, bytes:ByteArray, callback:Callback):void {
			HASH[file.path] = new FileSystemWriteProcess().initialize(file, bytes, new Callback(handleWrite, [file, callback]));
		}
		
		/**
		 * 	@private
		 */
		private function handleWrite(file:IFileReference, callback:Callback):void {
			
			delete HASH[file.path];
			callback.exec();
		}
		
		/**
		 * 	@private
		 */
		private function queryComplete(path:String, files:Vector.<IFileReference>, callbacks:Vector.<Callback>):void {
			delete HASH[path];
			for each (var callback:Callback in callbacks) {
				callback.exec(files);
			}
		}
		
		/**
		 * 	@public
		 */
		public function get protocol():String {
			return 'file';
		}
		
		/**
		 * 	@private
		 */
		private function readComplete(file:IFileReference):void {
			delete HASH[file.path];
		}
	}
}