package onyx.core {
	
	import flash.display.*;
	import flash.geom.*;
	
	import onyx.core.*;
	import onyx.display.*;
	import onyx.parameter.*;
	import onyx.plugin.*;
	
	/**
	 * 	@public
	 */
	public interface IPluginHost extends IPlugin {
		
		/**
		 * 	@public
		 */
		function initialize():PluginStatus;

		/**
		 * 	@public
		 */
		function createDefinitions(data:Object, file:IFileReference, callback:Function):void;

		/**
		 * 	@public
		 * 	Creates parameters
		 */
		function createParameters(target:Object, cache:Boolean = true):Vector.<IParameter>;

	}
}