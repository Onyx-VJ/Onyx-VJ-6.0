package onyx.core {
	
	import flash.display.*;
	
	import onyx.display.*;
	import onyx.plugin.*;
	
	/**
	 * 	@public
	 */
	public interface IDisplayTransformCPU extends IDisplayTransform {
		
		/**
		 * 	@public
		 */
		function initialize(context:IDisplayContextCPU, dimensions:Dimensions):PluginStatus;
		
		/**
		 * 	@public
		 */
		function render(context:IDisplayContextCPU, source:IBitmapDrawable, smoothing:Boolean = true, quality:String = null):void;
		
	}
}