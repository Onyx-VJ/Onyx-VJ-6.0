package onyx.plugin {
	
	import flash.events.*;
	
	import onyx.core.*;
	import onyx.parameter.*;
	import onyx.util.*;
	
	use namespace onyx_ns;
	use namespace parameter;

	/**
	 * 	@public
	 * 	Base class for Actionscript based items
	 * 	Support for all:
	 * 
	 * 		- FilterSurface
	 * 		- SurfaceGenerator
	 * 		- Patch
	 * 		- Module
	 * 		- Macro
	 * 
	 */

	public class PluginBase extends ParameterBase implements IPlugin {
		
		/**
		 * 	@protected
		 */
		onyx_ns var definition:IPluginDefinition;
		
		/**
		 * 	@public
		 */
		CONFIG::GC public function PluginBase():void {
			GC.watch(this);
		}

		/**
		 * 	@public
		 */
		final public function get id():String {
			return definition.id;
		}
		
		/**
		 * 	@public
		 */
		final public function get plugin():IPluginDefinition {
			return definition;
		}
		
		/**
		 * 	@public
		 */
		public function get name():String {
			return definition.name;
		}
		
		/**
		 * 	@public
		 */
		override public function dispose():void {
			
			// release!
			definition.releaseInstance(this);
			
			// dispose
			super.dispose();
			
			// release the definition
			definition = null;
		}
		
		/**
		 * 	@public
		 */
		public function serialize(options:uint = 0xFFFFFFFF):Object {
			
			const data:Object = {
				id:	this.id
			};
			
			if (parameters) {
				var s:Object = parameters.serialize();
				if (s) {
					data.parameters = s;
				}
			}
			
			return data;
		}
		
		/**
		 * 	@public
		 */
		override public function toString():String {
			
			if (!definition) {
				Console.LogError('definition not defined!');
			}
			
			return definition ? definition.id : 'UNKNOWN PLUGIN';
		}
	}
}