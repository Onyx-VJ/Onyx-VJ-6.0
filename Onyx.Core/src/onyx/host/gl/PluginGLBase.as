package onyx.host.gl {

	import onyx.core.*;
	import onyx.plugin.*;

	// public
	public class PluginGLBase extends PluginBase implements IPlugin {
		
		/**
		 * 	@public
		 */
		public var dataVert:Vector.<Number>;
		
		/**
		 * 	@public
		 */
		public var dataFrag:Vector.<Number>;
		
		/**
		 * 	@protected
		 */
		protected var context:IDisplayContextGPU;
		
		/**
		 * 	@public
		 */
		override public function dispose():void {
			
			// vertex
			dataVert = null;
			dataFrag = null;
			
			// dispose
			super.dispose();

		}
	}
}