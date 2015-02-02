package onyx.core {

	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.system.*;
	import flash.utils.*;
	
	import onyx.core.*;
	import onyx.plugin.*;
	import onyx.util.*;
	import onyx.util.filesystem.*;
	
	use namespace parameter;
	
	final public class FileSystem {
		
		/**
		 * 	@public
		 */
		public static const APPEND:String					= "append";
		
		/**
		 * 	@public
		 */
		public static const READ:String						= "read";
		
		/**
		 * 	@public
		 */
		public static const UPDATE:String					= "update";
		
		/**
		 * 	@public
		 */
		public static const WRITE:String					= "write";
		
		/**
		 * 	@internal
		 * 	These are the default file maps
		 * 	/library
		 * 	/plugins
		 * 	/settings
		 */
		[Inspectable]
		internal static const fileMapping:Object			= {};
		
		/**
		 * 	@internal
		 * 	These are default protocol maps
		 * 	http://, etc
		 */
		[Inspectable]
		internal static const protocolMapping:Object		= {};
		
		/**
		 * 	@protected
		 * 	Stores references of generator objects that can be re-used
		 */
		private static const CACHE:Object		= {};
		
		/**
		 * 	@public
		 */
		public static function CreateStub(input:String):String {
			return input.replace(/[\/|\?]/g, '-');
		}
		
		/**
		 * 	@public
		 */
		public static function EnumerateProtocols(type:uint):Vector.<IPluginProtocol> {
			
			const protocols:Vector.<IPluginProtocol> = new Vector.<IPluginProtocol>();
			
			for each (var protocol:IPluginProtocol in protocolMapping) {
				protocols.push(protocol);
			}
			protocols.fixed	= true;
			
			return protocols;
		}
		
		/**
		 * 	@public
		 */
		public static function CreateFileStream(file:IFileReference, mode:String):IFileStream {
			if (file.protocol is IPluginFileProtocol) {
				return (file.protocol as IPluginFileProtocol).createFileStream(file, mode);
			}
			return null;
		} 

		/**
		 * 	@public
		 */
		public static function RegisterProtocol(name:String, protocol:IPluginProtocol):void {
			protocolMapping[name] = protocol;
		}
		
		/**
		 * 	@public
		 * 	Specifies a file mapping
		 * 	@throws IllegalOperationError
		 */
		public static function RegisterFileMap(path:String, rootPath:String, plugin:IPluginDefinition, domain:ApplicationDomain):void {
			
			if (!plugin) {
				return Console.LogError(new Error('No Protocol Passed in!'));
			}
			
			var protocol:IPluginFileProtocol = plugin.createInstance() as IPluginFileProtocol;
			if (!protocol) {
				return Console.LogError(new Error('File Mapping Protocol Invalid!'));
			}

			var status:PluginStatus	= protocol.initialize(path, rootPath, domain);
			if (status !== PluginStatus.OK) {
				return Console.LogError(status.message);
			}
	
			// associate the file mapping
			fileMapping[path] = protocol;

		}
		
		/**
		 * 	@public
		 */
		public static function RegisterCacheableContent(file:IFileReference, data:Object, factory:IPluginFactory):void {
			var cache:GeneratorCache = CACHE[file.path];
			if (!cache) {
				CACHE[file.path] = cache = new GeneratorCache(file, factory, data);
			}
			++cache.count;
			trace('CACHE:', file.path, cache.count);
		}
		
		/**
		 * 	@public
		 */
		public static function ReleaseCacheableContent(file:IFileReference):void {
			var cache:GeneratorCache	= CACHE[file.path];
			if (cache) {
				if (--cache.count === 0) {
					if (cache.data is LoaderInfo) {
						(cache.data as LoaderInfo).loader.unload();
					}
					delete CACHE[file.path];
				}
			}
			trace('RELEASE CACHE:', file.path, cache.count);
		}

		/**
		 * 	@public
		 * 	Loads a layer
		 */
		public static function Load(file:IFileReference, callback:Callback):void {
			
			var cache:GeneratorCache = CACHE[file.path];
			
			// need to check caching here?
			if (cache) {
				
				callback.exec(cache.file, cache.data, cache.factory.createInstance(cache.file, cache.data));
				return;
			}

			// load
			file.protocol.load(file, new Callback(handleLoad, [callback]));

		}
		
		/**
		 * 	@private
		 */
		private static function handleLoad(callback:Callback, file:IFileReference, data:Object, generator:IPluginGenerator):void {
			
			// it's a patch already?
			if (generator) {
				
				callback.exec(file, data, generator);
			
			// check to see if we can re-use this file
			} else {
				
				// no generator for the file, so let's pass null
				var plugin:IPluginDefinition = Onyx.GetDefaultGenerator(file);
				if (!plugin) {
					callback.exec(file, null, null);
					return;
				}

				// exec -- pass in null for token, because we're not going to unserialize yet
				callback.exec(file, data, plugin.createInstance(file, data));

			}
		}
		
		/**
		 * 	@public
		 * 	Reads a file
		 */
		public static function ReadFile(file:IFileReference, callback:Callback, domain:ApplicationDomain = null):void {
			
			CONFIG::DEBUG {
				if (!file) {
					throw new Error(file + ' not defined');
				}
			}
			
			var protocol:IPluginFileProtocol = file.protocol as IPluginFileProtocol;
			if (!protocol) {
				return Console.LogError(file.protocol, 'does not support reading:', file);
			}
			
			protocol.readFile(file, callback, domain);
		}
		
		/**
		 * 	@public
		 * 	Queries directory
		 */
		public static function Query(ref:IFileReference, callback:Callback, filter:Callback = null, recursive:Boolean = false):void {
			
			if (!ref.isDirectory) {
				return Console.LogError(ref.path, ' is not a directory');
			}

			var protocol:IPluginProtocol	= ref.protocol;
			if (recursive) {
				var query:RecursiveQuery = new RecursiveQuery(protocol);
				query.initialize(ref, callback, filter);
			} else {
				protocol.query(ref, callback, filter);
			}

		}
		
		/**
		 * 	@public
		 * 	Creates a new IFileReference from string data
		 */
		public static function GetFileReference(path:String):IFileReference {
			
			// use a mapping
			if (path.charAt(0) === '/') {
				
				// if there's not a second index
				var index:int					= path.indexOf('/', 1);
				var mapping:String				= path.substr(0, index > 0 ? index : int.MAX_VALUE);
				var protocol:IPluginProtocol	= fileMapping[mapping];
				
				return (protocol) ? protocol.getFileReference(path) : null;
			}
			
			// protocol must have a name, no?
			index = path.indexOf(':/', 1);
			if (index > 1) {
				
				mapping				= path.substr(0, index);
				protocol			= protocolMapping[mapping]
					
				return protocol ? protocol.getFileReference(path) : null;
			}
			
			Console.LogError('Must use file mapping', path);
			
			return null;
		}
		
		/**
		 * 	@public
		 */
		public static function Write(file:IFileReference, bytes:ByteArray, callback:Callback):void {
			if (!file) {
				return Console.Log(CONSOLE::ERROR, 'no file to write?');	
			}
			var pr:IPluginFileProtocol = file.protocol as IPluginFileProtocol;
			if (pr) {
				pr.write(file, bytes, callback);
			} else {
				Console.Log(CONSOLE::WARNING, pr, ' does not support writing');
			}
		}
	}
}


import flash.events.*;

import onyx.core.*;
import onyx.event.*;

final class GeneratorCache extends EventDispatcher {
	
	/**
	 * 	@public
	 */
	public var data:Object;
	
	/**
	 * 	@public
	 */
	public var factory:IPluginFactory;
	
	/**
	 * 	@public
	 */
	public var count:int;
	
	/**
	 * 	@public
	 */
	public var file:IFileReference;
	
	/**
	 * 	@public
	 */
	public function GeneratorCache(ref:IFileReference, factory:IPluginFactory, data:Object):void {
		this.file		= ref;
		this.factory	= factory;
		this.data		= data;
	}
	
}