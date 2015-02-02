package onyx.macro {
	
	import flash.geom.Matrix;
	
	import onyx.core.*;
	import onyx.plugin.*;
	import onyx.util.encoding.*;
	import onyx.util.tween.*;
	
	use namespace parameter;
	
	[PluginInfo(
		id			= 'Onyx.Macro.IdentityMatrix',
		name		= 'Onyx.Macro.IdentityMatrix',
		version		= '1.0',
		vendor		= 'Daniel Hai',
		description = 'IdentityMatrix'
	)]
	
	public final class IdentityMatrix extends PluginBase implements IPluginMacro {
		
		/**
		 * 	@public
		 */
		public function initialize(macroContext:Object):PluginStatus {
			
			var display:IDisplay = Onyx.GetDisplay(0);
			if (!display) {
				return new PluginStatus('Error, no display');
			}
			
			var context:IDisplayContext	= display.getContext();
			
			for each (var layer:IDisplayLayer in display.getLayers()) {
				var generator:IPluginGenerator = layer.getGenerator();
				if (generator) {
					
					// has parameters for scaling
					if (!generator.hasParameter('scale') || !generator.hasParameter('translate')) {
						continue;
					}
					
					var scale:Matrix		= generator.getParameterValue('scale');
					
					Tween.Create(350, function(ratio:Number, currentTime:int, length:int):void {
						var data:Object					= this.data;
						var generator:IPluginGenerator	= data.generator;
						
						for (var i:String in data.end) {
							var endValue:Number		= data.end[i];
							var startValue:Number	= data.start[i];
							var easing:Function		= Easing.sine.easeIn;
							generator.setParameterValue(i, easing(currentTime, startValue, (endValue - startValue), length));
						}
					}, {
						'generator':	generator,
						'start':		{
							'scale/a':		scale.a,
							'scale/d':		scale.d,
							'translate/tx':	scale.tx,	// ratio
							'translate/ty':	scale.ty	// ratio
						},
						'end':	{
							'scale/a':		1.0,
							'scale/d':		1.0,
							'translate/tx':	0.0,
							'translate/ty':	0.0
						}
					});
				}
			}
			
			return PluginStatus.OK;
		}
		
		/**
		 * 	@public
		 */
		public function repeat():void {}
		
		/**
		 * 	@public
		 */
		override public function dispose():void {
			super.dispose();
		}
	}
}