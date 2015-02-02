package onyx.host.swf {
	
	import onyx.core.*;

	final public class PluginFactoryDefault implements IPluginFactory {
		
		/**
		 * 	@private
		 */
		private var definition:Class;
		
		/**
		 * 	@public
		 */
		public function PluginFactoryDefault(definition:Class):void {
			this.definition = definition;
		}
		
		/**
		 * 	@public
		 */
		public function createInstance(... args:Array):IPlugin {
			return new definition();
		}
		
		/**
		 * 	@public
		 */
		public function releaseInstance(plugin:IPlugin):void {}
	}
}