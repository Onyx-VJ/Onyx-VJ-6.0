package onyx.plugin {
	
	import flash.system.*;
	
	import onyx.core.*;
	
	public class PluginModule extends PluginBase {
		
		/**
		 * 	@public
		 */
		final public function getUserInterface():Class {
			
			if (plugin.info.ui && ApplicationDomain.currentDomain.hasDefinition(plugin.info.ui)) {
				return ApplicationDomain.currentDomain.getDefinition(plugin.info.ui) as Class;
			}
			
			return null;
		}
	}
}