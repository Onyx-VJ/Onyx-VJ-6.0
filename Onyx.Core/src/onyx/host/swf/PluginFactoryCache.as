package onyx.host.swf {
	
	import flash.display.*;
	import flash.utils.*;
	
	import onyx.core.*;
	
	final public class PluginFactoryCache implements IPluginFactory {
		
		/**
		 * 	@private
		 */
		private var definition:Class;
		
		/**
		 * 	@private
		 */
		private var count:int;
		
		/**
		 * 	@private
		 */
		private const cache:Object = {};
		
		/**
		 * 	@private
		 */
		private const instances:Dictionary	= new Dictionary(true);
		
		/**
		 * 	@public
		 */
		public var parent:PluginSWF;
		
		/**
		 * 	@public
		 */
		public function PluginFactoryCache(parent:PluginSWF, definition:Class):void {
			this.parent		= parent;
			this.definition = definition;
		}
		
		/**
		 * 	@public
		 */
		public function createInstance(... args:Array):IPlugin {

			var file:IFileReference = args[0];
			var data:Object			= args[1];
			
			var plugin:IPlugin		= new definition();
			
			// store a reference to the file
			instances[plugin]		= file;
			
			// register cache!
			FileSystem.RegisterCacheableContent(file, data, parent);
			
			// return
			return plugin;
		}
		
		/**
		 * 	@public
		 */
		public function releaseInstance(plugin:IPlugin):void {
			
			var file:IFileReference	= instances[plugin];
			
			delete instances[plugin];
			
			// register cache!
			FileSystem.ReleaseCacheableContent(file);

		}
	}
}