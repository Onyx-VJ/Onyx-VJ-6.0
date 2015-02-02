package onyx.macro {
	
	import onyx.core.*;
	import onyx.display.*;
	import onyx.event.*;
	import onyx.plugin.*;
	import onyx.util.encoding.*;
	import onyx.util.tween.*;
	
	use namespace parameter;
	
	[PluginInfo(
		id			= 'Onyx.Macro.LayerVisibility',
		name		= 'Onyx.Macro.LayerVisibility',
		version		= '1.0',
		vendor		= 'Daniel Hai',
		description = 'LayerVisibility'
	)]
	
	public final class MacroToggleVisibility extends PluginBase implements IPluginMacro {
		
		private var index:int;
		
		/**
		 * 	@public
		 */
		public function initialize(data:Object):PluginStatus {
			
			index = int(data);
			
			var display:IDisplay = Onyx.GetDisplay(0);
			if (!display) {
				return new PluginStatus('Error, no display');
			}
			
			var layer:IDisplayLayer = display.getLayer(index);
			layer.setParameterValue('visible', !layer.getParameterValue('visible'));
			
			// ok?
			return PluginStatus.OK;
		}
		
		/**
		 * 	@public
		 */
		public function repeat():void {}
	}
}