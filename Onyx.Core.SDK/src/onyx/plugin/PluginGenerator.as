package onyx.plugin {
	
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.media.*;
	
	import onyx.core.*;
	import onyx.display.*;
	import onyx.event.*;
	import onyx.plugin.*;
	import onyx.util.*;
	
	use namespace parameter;
	use namespace onyx_ns;

	public class PluginGenerator extends PluginBase {
		
		/**
		 * 	@protected
		 */
		protected var file:IFileReference;
		
		/**
		 * 	@protected
		 */
		protected const dimensions:Dimensions			= new Dimensions();
		
		/**
		 * 	@public
		 */
		public function getDimensions():Dimensions {
			return dimensions;
		}
		
		/**
		 * 	@public
		 */
		override public function serialize(options:uint = Plugin.SERIALIZE_ALL):Object {

			const serialized:Object	= {
				path:	file.path
			};
			const p:Object			= parameters.serialize();
			if (p) {
				serialized.parameters = p;
			}
			
			return serialized;
		}

		/**
		 * 	@public
		 */
		final public function getFile():IFileReference {
			return file;
		}
	}
}