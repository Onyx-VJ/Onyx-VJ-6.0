package onyx.ui.parameter {
	
	import flash.display.*;
	import flash.events.*;
	import flash.text.*;
	
	import onyx.core.*;
	import onyx.event.*;
	import onyx.parameter.*;
	import onyx.ui.component.*;
	import onyx.ui.core.*;
	import onyx.ui.event.*;
	import onyx.ui.factory.UIFactory;
	import onyx.ui.interaction.*;
	
	use namespace skinPart;
	
	final public class UIParameterSlider extends UIParameterDisplayBase {
		
		/**
		 * 	@private
		 */
		private static const DEFAULT:UIFactory		= new UIFactory(UIParameterSliderTextDisplay);
		
		/**
		 * 	@private
		 */
		private static const COMPONENT:UIFactory	= new UIFactory(UIParameterSliderComponentDisplay);
		
		/**
		 * 	@private
		 */
		private var display:IControlValueDisplay;
		
		/**
		 * 	@private
		 */
		private static var tValue:Number	= 0;
		
		/**
		 * 	@private
		 */
		private var range:int				= 150;
		
		/**
		 * 	@private
		 */
		private var diff:Number;
		
		/**
		 * 	@public
		 */
		override public function initialize(data:Object):void {
			
			// init
			super.initialize(data);
			
			switch (data.renderType) {
				case 'component':
					display	= COMPONENT.createInstance({ color: data.color });
					break;
				default:
					display	= DEFAULT.createInstance();
					break;
			}
			addChild(display as DisplayObject);

		}
		
		/**
		 * 	@private
		 */
		private function callback(interaction:Object, e:MouseEvent):void {
			
			var param:IParameterNumeric = this.parameter as IParameterNumeric;

			switch (e.type) {
				case MouseEvent.MOUSE_WHEEL:
					
					param.value += (e.delta / 200);
					
					break;
				case MouseEvent.MOUSE_DOWN:
					
					// get ratio of value to total
					tValue	= param.value; 
					
					break;
				case MouseEvent.DOUBLE_CLICK:
					
					break;
				case MouseEvent.RIGHT_CLICK:
					
					// reset
					param.reset();
					
					break;
				case MouseEvent.MOUSE_MOVE:
					
					param.value	= tValue + (((interaction.diff.y * -1) / (e.altKey ? range * 10 : range))) * diff;
					
					break;
			}
		}
		
		/**
		 * 	@public
		 */
		override public function update():void {
			
			display.update(parameter.value.toFixed(2));
			
		}
		
		/**
		 * 	@public
		 */
		override public function attach(param:IParameter):void {
			
			var num:IParameterNumeric = param as IParameterNumeric;
			if (!num) {
				return;
			}
			
			// attach
			super.attach(param);
			
			// the range
			diff = num.max - num.min;
			
			// convenience
			Interaction.Bind(this, callback, Interaction.LEFT_DOWN, Interaction.LEFT_DRAG, Interaction.LEFT_DOUBLE, Interaction.WHEEL, Interaction.RIGHT_CLICK);
			
		}
		
		/**
		 * 	@public
		 */
		override public function arrange(rect:UIRect):void {
			
			super.arrange(rect);

			// arrange
			display.arrange(rect.identity());

		}
		
		override public function dispose():void {
			
			// convenience
			Interaction.Unbind(this);
			
			// dispose
			super.dispose();
			
		}
	}
}