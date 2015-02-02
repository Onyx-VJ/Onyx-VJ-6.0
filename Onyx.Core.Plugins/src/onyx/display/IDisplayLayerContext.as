package onyx.display {
	
	import onyx.core.*;
	
	public interface IDisplayLayerContext {
		
		/**
		 * 	@public
		 */
		function setBlendMode(value:IPlugin):Boolean;
		
		/**
		 * 	@public
		 */
		function getBlendMode():IPlugin;
		
		/**
		 * 	@public
		 */
		function setTransform(value:IPlugin):Boolean;
		
		/**
		 * 	@public
		 */
		function getTransform():IPlugin;
		
		/**
		 * 	@public
		 */
		function setGenerator(value:IPlugin):Boolean;
		
		/**
		 * 	@public
		 */
		function getGenerator():IPlugin;
		
		/**
		 * 	@public
		 */
		function getChannel():IDisplayChannel;
		
	}
}