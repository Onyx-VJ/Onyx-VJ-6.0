package onyx.plugin {
	
	final public class PluginStatus {
		
		/**
		 * 	<p>Constant that is returned when a plugin is initialized successfully.</p>
		 * 	<p>Make sure to return PluginStatus.OK -- now new PluginStatus('OK'), as internally we are testing against (status === PluginStatus.OK)</p>
		 * 	<p>If initializing has an error, return the error message.</p>
		 * 	<p>return new PluginStatus('Error Initializing Filter!')</p> 
		 */
		public static const OK:PluginStatus		= new PluginStatus('OK');
		
		
		/**
		 * 	<p>Returns whether initialization is asynchronous.  This is only valid currently for Module Development.</p>
		 * 
		 * 	@see onyx.plugin.Plugin
		 * 	@see onyx.plugin.PluginModule
		 * 
		 */
		public static const ASYNC:PluginStatus	= new PluginStatus('ASYNCHRONOUS OPERATION NOT ALLOWED HERE');
		
		/**
		 * 	The error message that occured when initializing the plugin. 
		 */
		public var message:String;
		
		/**
		 * @constructor
		 * @param Array Array of arguments that is concatenated as the error message. (similar to trace)
		 */
		public function PluginStatus(... args:Array):void {
			this.message	= args.join(' ');
		}
		
		/**
		 * 	@public
		 */
		public function toString():String {
			return message;
		}
	}
}