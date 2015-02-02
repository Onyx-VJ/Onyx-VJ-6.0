package onyx.macro {
	
	import flash.geom.Matrix;
	
	import onyx.core.*;
	import onyx.plugin.*;
	import onyx.util.encoding.*;
	import onyx.util.tween.*;
	
	use namespace parameter;
	
	[PluginInfo(
		id			= 'Onyx.Macro.RandomTimeSame',
		name		= 'Onyx.Macro.RandomTimeSame',
		version		= '1.0',
		vendor		= 'Daniel Hai',
		description = 'RandomTimeSame'
	)]
	
	public final class RandomTimeSame extends PluginBase implements IPluginMacro {
		
		/**
		 * 	@public
		 */
		public function initialize(data:Object):PluginStatus {
			
			var display:IDisplay = Onyx.GetDisplay(0);
			if (!display) {
				return new PluginStatus('Error, no display');
			}
			
			var context:IDisplayContext	= display.getContext();
			
			// set the time
			var time:Number	= Math.random(); 
			for each (var layer:IDisplayLayer in display.getLayers()) {
				layer.time = time;
			}
			
			return PluginStatus.OK;
		}
		
		/**
		 * 	@public
		 */
		public function repeat():void {}
	}
}