package onyx.host.swf {
	
	import onyx.core.*;
	import onyx.display.*;
	import onyx.parameter.*;
	import onyx.plugin.*;
	
	use namespace parameter;
	
	/**
	 * 	@internal
	 */
	final public class PluginSWFParameterFont extends PluginSWFParameter implements IParameterIterator {
		
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
		public function get iterator():* {
			return Onyx.EnumeratePlugins(Plugin.FONT);
		}
		
		/**
		 * 	@public
		 */
		override public function initialize(target:Object, property:String, parameterType:String, definition:PluginSWFDefinition):void {
			
			super.initialize(target, property, parameterType, definition);
			
			// do we allow nulls?
			allowNull = (definition.allowNull === undefined) ? false : definition.allowNull;
			if (!allowNull && !value) {
				value = Onyx.EnumeratePlugins(Plugin.FONT)[0];
			}
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
		public function format(value:*):String {
			return value;
		}

		/**
		 * 	@public
		 */
		override public function set value(v:*):void {

			// set the value
			super.value = v ? v.id : null;
			
		}
		
		/**
		 * 	@public
		 */
		override public function unserialize(token:*):void {
			value = token.id;
		}
		
		/**
		 * 	@public
		 */
		override public function serialize(options:uint = 0xFFFFFFFF):Object {
			return target[property].serialize(options);
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
			return target[property];
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