package onyx.host.swf {
	
	import flash.display.*;
	import flash.system.*;
	import flash.utils.*;
	
	import onyx.core.*;
	import onyx.parameter.*;
	import onyx.plugin.*;
	
	use namespace onyx_ns;
	use namespace parameter;

	final public class PluginSWF implements IPluginDefinition {
		
		/**
		 * 	@private
		 * 	Set to -1 by default
		 */
		internal var pluginType:uint			= uint.MAX_VALUE;
		
		/**
		 * 	@private
		 */
		internal var factory:IPluginFactory;
		
		/**
		 * 	@protected
		 */
		internal var iconClass:Class;
		
		/**
		 * 	@public
		 */
		internal var flags:uint;
		
		/**
		 * 	@private
		 * 	Set by PluginSWFHost
		 */
		onyx_ns var data:PluginData;
		
		/**
		 * 	@internal
		 * 	Set by PluginSWFHost
		 */
		internal var definitions:Vector.<PluginSWFDefinition>;
		
		/**
		 * 	@public
		 */
		public function unserialize(token:*):void {
			
			// store settings
			data.settings = token;

		}
		
		/**
		 * 	@public
		 */
		public function serialize(options:uint = 0xFFFFFFFF):Object {
			return null;
		}
		
		/**
		 * 	@public
		 */
		public function createInstance(... args:Array):IPlugin {
			
			const instance:PluginBase		= factory.createInstance(args[0], args[1]) as PluginBase;
			if (!instance) {
				Console.LogError('Instance must be of type PluginBase');
				return null
			}
			instance.definition				= this;
			
			// do we have data?
			if (definitions) {
				
				instance.parameters = new ParameterList(PluginSWFHost.RetrieveParameters(instance, definitions));
				instance.initializeParameterInvalidation();

			}
			
			// return the instance
			return instance as IPlugin;
		}

		/**
		 * 	@public
		 */
		public function get enabled():Boolean {
			return data.enabled == undefined || data.enabled === true;
		}
		
		/**
		 * 	@public
		 */
		public function get type():uint {
			return pluginType;
		}
		
		/**
		 * 	@public
		 */
		public function get name():String {
			return data.name;
		}
		
		/**
		 * 	@public
		 */
		public function get dependencies():String {
			return data.depends;
		}
		
		/**
		 * 	@public
		 */
		public function get id():String {
			return data.id;
		}
		
		/**
		 * 	@public
		 */
		public function get info():Object {
			return data;
		}
		
		/**
		 * 	@public
		 */
		public function get icon():DisplayObject {
			return iconClass ? new iconClass() : null;
		}
		
		/**
		 * 	@public
		 */
		public function toString():String {
			return data.name || id;
		}
		
		/**
		 * 	@public
		 */
		public function releaseInstance(plugin:IPlugin):void {
			factory.releaseInstance(plugin);
		}
	}
}