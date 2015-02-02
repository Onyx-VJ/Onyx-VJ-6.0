package onyxui.parameter {
	
	import flash.events.*;
	import flash.text.*;
	
	import onyx.core.*;
	import onyx.parameter.*;
	
	import onyxui.assets.*;
	import onyxui.core.*;
	import onyxui.interaction.*;
	
	public final class UIParameterColorTransform extends UIParameter {
		
		/**
		 * 	@private
		 */
		private const children:Object		= {
			alphaMultiplier:	new UIParameterSlider(new UIParameterSliderComponentDisplay(0xFFFFFF)),
			redMultiplier:		new UIParameterSlider(new UIParameterSliderComponentDisplay(0xFF3333)),
			greenMultiplier:	new UIParameterSlider(new UIParameterSliderComponentDisplay(0x33FF33)),
			blueMultiplier:		new UIParameterSlider(new UIParameterSliderComponentDisplay(0x6666FF))
		};
		
		/**
		 * 	@public
		 */
		override public function initialize():void {
			
			// init
			for each (var slider:UIParameterSlider in children) {
				slider.resize(16, 16);
				addChild(slider);
			}
			
			children.alphaMultiplier.x	= 2;
			children.redMultiplier.x	= 18;
			children.greenMultiplier.x	= 34;
			children.blueMultiplier.x	= 50;
		}
		
		/**
		 * 	@public
		 */
		override public function attach(param:Parameter):void {
			
			if (!param) {
				for each (var control:UIParameter in children) {
					control.attach(null);
				}
				
				return;
			}
			
			const params:Vector.<IParameter> = (param as IParameterObject).getChildParameters();
			for each (var child:IParameter in params) {
				children[child.id].attach(child);
			}
		}
	}
}