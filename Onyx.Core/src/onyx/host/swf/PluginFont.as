package onyx.host.swf {
	
	import flash.display.*;
	import flash.system.*;
	import flash.utils.*;
	
	import onyx.core.*;
	import onyx.parameter.*;
	import onyx.plugin.*;
	
	use namespace onyx_ns;
	use namespace parameter;
	
	final public class PluginFont implements IPluginDefinition {
		
		/**
		 * 	@private
		 */
		internal var pluginType:int		= Plugin.FONT;
		
		/**
		 * 	@private
		 */
		internal var definition:Class;
		
		/**
		 * 	@protected
		 */
		internal var iconClass:Class;
		
		/**
		 * 	@private
		 * 	Set by PluginSWFHost
		 */
		internal var data:Object	= {};
		
		/**
		 * 	@public
		 */
		public function unserialize(token:*):void {
			
			if (token.enabled !== undefined) {
				data.enabled = token.enabled;
			}
			
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
		 * 	Returns null, because font is registered
		 */
		public function createInstance(... args:Array):IPlugin {
			return null;
		};
		
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
			
		}
	}
}