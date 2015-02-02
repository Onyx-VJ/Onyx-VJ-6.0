package onyx.macro {
	
	import flash.geom.Matrix;
	
	import onyx.core.*;
	import onyx.plugin.*;
	import onyx.util.encoding.*;
	import onyx.util.tween.*;
	
	use namespace parameter;
	
	[PluginInfo(
		id			= 'Onyx.Macro.RandomMatrix',
		name		= 'Onyx.Macro.RandomMatrix',
		version		= '1.0',
		vendor		= 'Daniel Hai',
		description = 'RandomMatrix'
	)]
	
	public final class RandomMatrix extends PluginBase implements IPluginMacro {
		
		/**
		 * 	@private
		 */
		private var maxScale:Number;
		
		/**
		 * 	@public
		 */
		public function initialize(data:Object):PluginStatus {
			
			maxScale = Number(data) || 1.65;
			
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
					
					var newScale:Number	= 1 + (Math.random() * maxScale);
					var ratio:Number	= newScale * 0.2;
					var x:Number        = (Math.random() * ratio) - ratio * 0.5;
					var y:Number		= (Math.random() * ratio) - ratio * 0.5;
					
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
							'scale/a':		newScale,
							'scale/d':		newScale,
							'translate/tx':	x,
							'translate/ty':	y
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

//public final class RandomScaleLoc extends Macro {
//	
//	/**
//	 * 
//	 */
//	override public function keyDown():void {
//		
//		var scale:Number, ratio:Number, x:int, y:int;
//		
//		for each (var layer:Layer in Display.layers) {
//			
//			scale   = 1 + (Math.random() * 1.65);
//			ratio   = scale - 1;
//			x               = ratio * (-DISPLAY_WIDTH * layer.anchorX) * Math.random();
//			y               = ratio * (-DISPLAY_HEIGHT * layer.anchorY) * Math.random();
//			
//			new Tween(
//				layer,
//				175,
//				new TweenProperty('x', layer.x, x),
//				new TweenProperty('y', layer.y, y),
//				new TweenProperty('scaleX', layer.scaleX, scale),
//				new TweenProperty('scaleY', layer.scaleY, scale)
//			)
//		}       
//	}
//	
//	override public function keyUp():void {
//	}
//}
//
//public final class RandomFrameRateMacro extends Macro {
//	
//	/**
//	 * 
//	 */
//	override public function keyDown():void {
//		
//		for each (var layer:Layer in Display.layers) {
//			layer.framerate = Math.max(Math.random() * 2, 1) * (Math.random() > .5 ? 1 : -1);
//		}
//		
//	}
//	
//	override public function keyUp():void {
//	}
//}