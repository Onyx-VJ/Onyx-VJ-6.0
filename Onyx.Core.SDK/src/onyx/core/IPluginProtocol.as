package onyx.core {
	
	import flash.utils.*;
	
	import onyx.core.*;
	import onyx.plugin.*;
	import onyx.util.*;
	
	public interface IPluginProtocol extends IPlugin {

		/**
		 * 	@public
		 * 	Queries directory
		 */
		function query(path:IFileReference, callback:Callback, filter:Callback = null):void;
		
		/**
		 * 	@public
		 */
		function load(path:IFileReference, callback:Callback):void;
		
		/**
		 * 	@public
		 * 	Creates a new IFileReference from string data
		 */
		function getFileReference(data:String):IFileReference;

	}
}