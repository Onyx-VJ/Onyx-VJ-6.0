package onyxui.parameter {
	
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.text.*;
	
	import onyx.core.*;
	import onyx.event.*;
	import onyx.parameter.*;
	
	import onyxui.assets.*;
	import onyxui.core.*;
	import onyxui.event.*;
	import onyxui.interaction.*;
	
	final public class UIParameterSliderGroup extends UIParameter {
		
		/**
		 * 	@private
		 */
		private static const VALUES:Point	= new Point();
		private const label:UITextField		= new UITextField(UIStyle.FORMAT_RIGHT);
		
		/**
		 * 	@private
		 */
		private var xParam:IParameterNumeric;
		
		/**
		 * 	@private
		 */
		private var yParam:IParameterNumeric;
		
		/**
		 * 	@private
		 */
		private var range:int				= 150;
		private var diff:Point				= new Point();
		
		/**
		 * 	@public
		 */
		override public function initialize():void {
			
			// convenience
			Interaction.Bind(this, callback, Interaction.LEFT_DOWN, Interaction.LEFT_DRAG, Interaction.RIGHT_CLICK);
			
			// update
			update();
			
			// label
			label.mouseEnabled	= false;
			
			addChild(label);
			
			this.mouseEnabled	= true;
		}
		
		/**
		 * 	@private
		 */
		private function callback(interaction:Object, e:MouseEvent):void {
			
			switch (e.type) {
				case MouseEvent.MOUSE_DOWN:
					
					// get ratio of value to total
					VALUES.x		= xParam.value;
					VALUES.y		= yParam.value;
					
					break;
				case InteractionEvent.RIGHT_CLICK:
					
					xParam.reset();
					yParam.reset();
					
					break;
				case MouseEvent.DOUBLE_CLICK:
					break;
				case MouseEvent.MOUSE_MOVE:
					
					if (e.shiftKey) {
						var val:Number	=	((VALUES.x + (((interaction.diff.x) / (e.altKey ? range * 8 : range))) * diff.x) +
											VALUES.y + (((interaction.diff.y) / (e.altKey ? range * 8 : range))) * diff.y) * 0.5;
						
						xParam.value	= val;
						yParam.value	= val;
					} else {
						xParam.value	= VALUES.x + (((interaction.diff.x) / (e.altKey ? range * 8 : range))) * diff.x;
						yParam.value	= VALUES.y + (((interaction.diff.y) / (e.altKey ? range * 8 : range))) * diff.y;
					}
					
					break;
			}
		}
		
		/**
		 * 	@publc
		 */
		override public function attach(p:Parameter):void {
			
			// attach
			super.attach(p);
			
			const obj:IParameterObject				= p as IParameterObject;
			if (obj) {
				const children:Vector.<IParameter> 	= obj.getChildParameters();
				xParam								= children[0] as IParameterNumeric;
				yParam								= children[1] as IParameterNumeric;
				
				// diff?
				diff.x								= xParam.max - xParam.min;
				diff.y								= yParam.max - yParam.min;
				
			// remove
			} else {
				xParam = yParam = null;
			}
		}
		
		/**
		 * 	@private
		 */
		override public function update(event:ParameterEvent = null):void {
			if (!xParam || !yParam) {
				return;
			}
			label.text = xParam.value.toFixed(2) + 'x' + yParam.value.toFixed(2);
		}
		
		/**
		 * 	@public
		 */
		override public function resize(width:int, height:int):void {
			label.resize(width, height);
			super.resize(width, height);
		}
		
		/**
		 * 	@public
		 */
		override public function dispose():void {
			
			// convenience
			Interaction.Unbind(this);
			
			// dispose
			super.dispose();
		}
	}
}