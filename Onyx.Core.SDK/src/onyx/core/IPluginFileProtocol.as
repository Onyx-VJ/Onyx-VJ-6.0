package onyx.core {
	
	import flash.system.ApplicationDomain;
	import flash.utils.*;
	
	import onyx.core.*;
	import onyx.plugin.*;
	import onyx.util.*;
	
	public interface IPluginFileProtocol extends IPluginProtocol {
		
		/**
		 * 	@public
		 */
		function initialize(mapping:String, rootPath:String, domain:ApplicationDomain = null):PluginStatus;

		/**
		 * 	@public
		 * 	Reads a file
		 */
		function readFile(path:IFileReference, callback:Callback, domain:ApplicationDomain = null, combine:Boolean = true):void;
		
		/**
		 * 	@public
		 */
		function browse(location:IFileReference, callback:Callback):void;
		
		/**
		 * 	@public
		 */
		function write(file:IFileReference, bytes:ByteArray, callback:Callback):void;
		
		/**
		 * 	@public
		 */
		function createFileStream(file:IFileReference, mode:String):IFileStream;

	}
}