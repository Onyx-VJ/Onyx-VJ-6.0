package onyx.plugin {
	
	import onyx.core.*;
	
	use namespace onyx_ns;
	
	public class PluginFilterBase extends PluginBase {
		
		/**
		 * 	@protected
		 */
		parameter var muted:Boolean;
		
		/**
		 * 	@public
		 */
		override public function serialize(options:uint = 0xFFFFFFFF):Object {
			
			const data:Object = {
				id:	plugin.id
			};
			if (parameters) {
				data.parameters = parameters.serialize();
			}
			
			return data;
		}
	}
}