package onyx.macro {
	
	import flash.geom.Matrix;
	
	import onyx.core.*;
	import onyx.plugin.*;
	import onyx.util.encoding.*;
	import onyx.util.tween.*;
	
	use namespace parameter;
	
	[PluginInfo(
		id			= 'Onyx.Macro.RandomTime',
		name		= 'Onyx.Macro.RandomTime',
		version		= '1.0',
		vendor		= 'Daniel Hai',
		description = 'RandomTime'
	)]
	
	public final class RandomTime extends PluginBase implements IPluginMacro {
		
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
			for each (var layer:IDisplayLayer in display.getLayers()) {
				layer.time = Math.random();
			}
			
			return PluginStatus.OK;
		}
		
		/**
		 * 	@public
		 */
		public function repeat():void {
		}
	}
}