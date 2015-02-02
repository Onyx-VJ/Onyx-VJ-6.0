package onyx.ui.parameter {
	
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.text.*;
	
	import onyx.core.*;
	import onyx.event.*;
	import onyx.parameter.*;
	import onyx.ui.component.*;
	import onyx.ui.core.*;
	import onyx.ui.event.*;
	import onyx.ui.interaction.*;
	
	use namespace skinPart;
	
	[UISkinPart(id='skin', 		type='buttonSkin',	transform='default', constraint='relative', top='0', left='0', right='0', bottom='0')]
	[UISkinPart(id='label', 	type='text',		transform='default', constraint='relative', top='0', left='0', right='0', bottom='0', textAlign='center')]
	final public class UIParameterSliderGroup extends UIParameterDisplayBase {
		
		/**
		 * 	@private
		 */
		private static const VALUES:Point	= new Point();

		/**
		 * 	@private
		 */
		skinPart var label:UITextField;
		
		/**
		 * 	@private
		 */
		skinPart var skin:UIButtonSkin;
		
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
		
		/**
		 * 	@private
		 */
		private var diff:Point				= new Point();
		
		/**
		 * 	@publc
		 */
		override public function attach(p:IParameter):void {
			
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
		 * 	@public
		 */
		override public function initialize(data:Object):void {
			
			// initialize
			super.initialize(data);
			
			// convenience
			Interaction.Bind(this, callback, Interaction.LEFT_DOWN, Interaction.LEFT_DRAG, Interaction.RIGHT_CLICK);

			this.buttonMode		= this.useHandCursor = true;
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
				case MouseEvent.RIGHT_CLICK:
					
					xParam.reset();
					yParam.reset();
					
					break;
				case MouseEvent.DOUBLE_CLICK:
					break;
				case MouseEvent.MOUSE_MOVE:
					
					if (e.shiftKey) {
						var val:Number	=	((VALUES.x + (((interaction.diff.x) / (e.ctrlKey ? range * 8 : range))) * diff.x) +
											VALUES.y + (((interaction.diff.y) / (e.ctrlKey ? range * 8 : range))) * diff.y) * 0.5;
						
						xParam.value	= val;
						yParam.value	= val;
					} else {
						
						xParam.value	= VALUES.x + (((interaction.diff.x) / (e.ctrlKey ? range * 8 : range))) * diff.x;
						yParam.value	= VALUES.y + (((interaction.diff.y) / (e.ctrlKey ? range * 8 : range))) * diff.y;
						
					}
					
					break;
			}
		}
		
		/**
		 * 	@public
		 */
		override public function update():void {
			if (!xParam || !yParam) {
				return;
			}
			label.text = xParam.value.toFixed(2) + 'x' + yParam.value.toFixed(2);
		}
		
		/**
		 * 	@public
		 */
		override public function arrange(rect:UIRect):void {
			super.arrange(rect);
			arrangeSkins(rect.identity());
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