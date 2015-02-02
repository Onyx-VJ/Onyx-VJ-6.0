package onyxui.parameter {
	
	import flash.display.*;
	
	import onyx.core.*;
	import onyx.parameter.*;
	
	import onyxui.core.*;
	
	final public class UIParameterList extends UIObject {
		
		/**
		 * 	@public
		 */
		protected static const CONTROL_MAP:Object = {
			'number':				UIParameterSlider,
			'matrix/scale':			UIParameterSliderGroup,
			'matrix/translate':		UIParameterSliderGroup,
			'point':				UIParameterSliderGroup,
			'colorTransform':		UIParameterColorTransform,
			'function':				UIParameterButton,
			'boolean':				UIParameterDropDown,
			'layer':				UIParameterDropDown,
			'blendMode':			UIParameterDropDown,
			'color':				UIParameterColorPicker
		};
		
		/**
		 * 	@protected
		 */
		public static function CreateControl(parameter:Parameter):UIParameter {
			var c:Class				= CONTROL_MAP[parameter.type];
			if (!c) {

				CONFIG::DEBUG {
					throw new Error('unsupported type:' + parameter.type);
				}
				
				return null;
			}
			var control:UIParameter	= new c();
			control.attach(parameter);
			return control;
		}
		
		/**
		 * 	@private
		 */
		private const controls:Vector.<UIParameter>	= new Vector.<UIParameter>();
		private const labels:Vector.<UITextField>	= new Vector.<UITextField>();
			
		/**
		 * 	@public
		 */
		public function attach(parameters:ParameterList, excludeKey:Object = null):void {
			
			if (!excludeKey) {
				excludeKey = {};
			}
			
			// remove
			remChildren();
			
			// loop
			const iter:Vector.<IParameter> = parameters.iterator;
			var y:int		= 0;
			
			for each (var parameter:Parameter in iter) {
				if (excludeKey[parameter.name] === undefined) {
					var control:UIParameter = CreateControl(parameter);
					if (control) {
						labels.push(addChild(new UITextField()) as UITextField);
						controls.push(control);
						addChild(control);
					}
				}
			}
			
			// arrange
			arrangeChildren();
		}
		
		/**
		 * 	@public
		 */
		override public function remChildren():void {
			
			// remove
			super.remChildren();
			
			// splice
			controls.splice(0, controls.length);
			labels.splice(0, labels.length);

		}
		
		/**
		 *	@private	 
		 */
		override public function arrangeChildren():void {
			
			var y:int = 0;
			for (var count:int = 0; count < controls.length; count++) {
				var control:UIParameter	= controls[count];
				var label:UITextField	= labels[count];
				label.resize(bounds.width * .45,	16);
				label.moveTo(0,	y);
				label.text	= control.showLabel() ? control.getDisplayName() : ''
				control.resize(bounds.width * .55, 16);
				control.moveTo(bounds.width * .45, y);
				y += 16;
			}
			
		}
		
		/**
		 * 	@public
		 */
		override public function resize(width:int, height:int):void {
			
			bounds.width	= width;
			bounds.height	= height;
			
			arrange();
		}
	}
}