package onyx.core {

	public interface IPluginFactory {
		
		/**
		 * 	@public
		 */
		function createInstance(... args:Array):IPlugin;
		
		/**
		 * 	@public
		 */
		function releaseInstance(plugin:IPlugin):void;

	}
}