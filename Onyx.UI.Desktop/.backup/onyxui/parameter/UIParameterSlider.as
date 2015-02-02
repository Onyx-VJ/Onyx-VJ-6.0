package onyxui.parameter {
	
	import flash.display.*;
	import flash.events.*;
	import flash.text.*;
	
	import onyx.core.*;
	import onyx.event.*;
	import onyx.parameter.*;
	
	import onyxui.assets.*;
	import onyxui.core.*;
	import onyxui.event.*;
	import onyxui.interaction.*;
	
	final public class UIParameterSlider extends UIParameter {
		
		private static const DEFAULT_FACTORY:IFactory	= new UIFactory(UIParameterSliderTextDisplay); 
		
		/**
		 * 	@private
		 */
		private var display:IControlValueDisplay
		
		/**
		 * 	@private
		 */
		private var range:int				= 150;
		private var diff:Number;
		private static var tValue:Number	= 0;
		
		/**
		 * 	@public
		 */
		public function UIParameterSlider(display:IFactory = null, horizontal:Boolean = false):void {
			
			this.display = display ? display.createInstance() || new UIParameterSliderTextDisplay();
			addChild(this.display as DisplayObject);
		}
		
		/**
		 * 	@public
		 */
		override public function initialize():void {
			
			// convenience
			Interaction.Bind(this, callback, Interaction.LEFT_DOWN, Interaction.LEFT_DRAG, Interaction.LEFT_DOUBLE, Interaction.WHEEL, Interaction.RIGHT_CLICK);
			
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
				case InteractionEvent.RIGHT_CLICK:
					
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
		override public function update(e:ParameterEvent = null):void {
			
			if (!this.parameter) {
				return;
			}
			
			display.updateDisplay();
			
		}
		
		override public function attach(param:Parameter):void {
			
			var num:IParameterNumeric = param as IParameterNumeric;
			if (!num) {
				return;
			}
						
			// attach
			super.attach(param);
			
			// attach parameter
			display.attach(parameter);
			
			// the range
			diff = num.max - num.min;
			
			// update
			update();
		}
		
		/**
		 * 	@public
		 */
		override public function resize(width:int, height:int):void {
			
			display.resize(width, height);

		}
		
		override public function dispose():void {
			
			// convenience
			Interaction.Unbind(this);
			
			// dispose
			super.dispose();
			
		}
	}
}