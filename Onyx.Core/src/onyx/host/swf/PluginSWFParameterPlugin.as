package onyx.host.swf {
	
	import onyx.core.*;
	import onyx.display.*;
	import onyx.parameter.*;
	import onyx.plugin.*;
	
	use namespace parameter;
	
	/**
	 * 	@internal
	 * 	TODO, WE NEED TO ADD ABILITY TO SIGNAL FOR CPU/GPU
	 */
	final public class PluginSWFParameterPlugin extends PluginSWFParameter implements IParameterPlugin {
		
		/**
		 * 	@private
		 */
		private var pluginType:int;
		
		/**
		 * 	@private
		 */
		private var pluginDefinition:Class; 
		
		/**
		 * 	@private
		 */
		private var allowNull:Boolean;
		
		/**
		 * 	@public
		 */
		public function PluginSWFParameterPlugin(pluginType:uint):void {
			this.pluginType			= pluginType;
		}
		
		/**
		 * 	@public
		 */
		public function updatePluginType(type:uint):void {
			this.pluginType	= type;
		}

		/**
		 * 	@public
		 */
		public function get iterator():* {
			return Onyx.EnumeratePlugins(pluginType);
		}
		
		/**
		 * 	@public
		 */
		public function format(value:*):String {
			return value;
		}
		/**
		 * 	@public
		 */
		public function get currentIndex():int {
			return iterator.indexOf(value);
		}
		
		/**
		 * 	@public
		 */
		override public function initialize(target:Object, property:String, parameterType:String, definition:PluginSWFDefinition):void {
			
			// init
			super.initialize(target, property, parameterType, definition);
			
			// do we allow nulls?
			allowNull = (definition.allowNull === undefined) ? false : definition.allowNull;
			if (!allowNull && !value) {
				value = Onyx.EnumeratePlugins(pluginType)[0];
			}
		}

		/**
		 * 	@public
		 */
		override public function set value(v:*):void {
			
			// old property
			var instance:IPlugin = target[property];
			if (instance) {

				// nullify
				instance.dispose();

			}
			
			const plugin:IPluginDefinition = v as IPluginDefinition; 
			if (plugin) {
				instance = plugin.createInstance();
			} else {
				instance = null;
			}
			
			// set the value
			super.value = instance;

		}
		
		/**
		 * 	@public
		 */
		override public function unserialize(token:*):void {
			
			var id:String	= String(token.id);
			if (id) {
				
				// store
				var plugin:IPluginDefinition	= Onyx.GetPlugin(id);
				var inst:IPlugin				= plugin.createInstance();
				inst.unserialize(token);
				
				// set value
				value							= Onyx.GetPlugin(id);
				
				// to do -- need to serialize
			}
		}
		
		/**
		 * 	@public
		 */
		override public function serialize(options:uint = 0xFFFFFFFF):Object {
			
			var plugin:IPlugin	= target[property];
			var data:Object		= {
				id:		plugin.id
			}
			var info:Object		= plugin.serialize(options);
			if (info) {
				data['data'] = info;
			}
			return data;
		}
		
		/**
		 * 	@public
		 */
		override public function reset():void {
			if (definition.reset !== undefined) {
				value = Onyx.GetPlugin(definition.reset);
			}
		}

		/**
		 * 	@public
		 */
		override public function get value():* {
			const instance:IPlugin	= target[property];
			return instance ? instance.plugin : null;
		}
		
		/**
		 * 	@public
		 */
		override public function dispose():void {
			
			value = null;
			super.dispose();
			
		}
	}
}