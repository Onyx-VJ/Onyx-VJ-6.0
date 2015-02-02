package onyx.core {
	
	[Compiler(Link)]
	
	public interface IPluginFilter extends IPlugin {
		
		function get type():uint;
		function getOwner():IChannel;
		
	}
}