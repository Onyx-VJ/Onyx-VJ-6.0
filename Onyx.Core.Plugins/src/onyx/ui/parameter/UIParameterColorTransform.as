package onyx.ui.parameter {
	
	import flash.events.*;
	import flash.text.*;
	
	import onyx.core.*;
	import onyx.parameter.*;
	import onyx.ui.core.*;
	import onyx.ui.interaction.*;
	
	use namespace skinPart;
	
	[UISkinPart(id='alphaMultiplier', 	type='parameter',	renderType='component', color='0xFFFFFF', constraint='absolute', bounds='1,1,15,15')]
	[UISkinPart(id='redMultiplier', 	type='parameter',	renderType='component', color='0xFF0000', constraint='absolute', bounds='15,1,15,15')]
	[UISkinPart(id='greenMultiplier', 	type='parameter',	renderType='component', color='0x00FF00', constraint='absolute', bounds='30,1,15,15')]
	[UISkinPart(id='blueMultiplier', 	type='parameter',	renderType='component', color='0x0000FF', constraint='absolute', bounds='45,1,15,15')]
	
	public final class UIParameterColorTransform extends UIParameterDisplayBase {
		
		/**
		 * 	@private
		 */
		skinPart var alphaMultiplier:UIParameter;
		
		/**
		 * 	@private
		 */
		skinPart var redMultiplier:UIParameter;

		/**
		 * 	@private
		 */
		skinPart var greenMultiplier:UIParameter;
		
		/**
		 * 	@private
		 */
		skinPart var blueMultiplier:UIParameter;
		
		/**
		 * 	@public
		 */
		override public function initialize(data:Object):void {
			
			super.initialize(data);
		}
		
		/**
		 * 	@public
		 */
		override public function highlightForBind(show:Boolean):void {
			
		}
		
		/**
		 * 	@public
		 */
		override public function attach(param:IParameter):void {
			var obj:IParameterObject = param as IParameterObject;
			if (!obj) {
				return;
			}
			
			for each (var child:IParameter in obj.getChildParameters()) {
				(this[child.id] as UIParameter).attach(child);
			}
		}
		
		/**
		 * 	@public
		 */
		override public function arrange(rect:UIRect):void {
			
			super.arrange(rect);
			
			// rect!
			rect = rect.identity();
			alphaMultiplier.measure(rect);
			redMultiplier.measure(rect);
			greenMultiplier.measure(rect);
			blueMultiplier.measure(rect);

		}
	}
}