package onyx.core {
	
	import onyx.core.*;
	import onyx.plugin.*;
	import onyx.display.*;

	public interface IPluginPlayMode extends IPlugin {
		
		// update
		function initialize(layer:IDisplayLayer):PluginStatus;
		function update():Number;

	}
}