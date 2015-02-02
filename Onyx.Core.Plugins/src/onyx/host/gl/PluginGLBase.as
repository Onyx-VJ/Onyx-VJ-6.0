package onyx.host.gl {

	import onyx.plugin.*;

	// public
	public class PluginGLBase extends PluginBase {
		
		/**
		 * 	@public
		 */
		public var dataVert:Vector.<Number>;
		
		/**
		 * 	@public
		 */
		public var dataFrag:Vector.<Number>;
		
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