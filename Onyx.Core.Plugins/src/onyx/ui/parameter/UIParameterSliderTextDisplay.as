package onyx.ui.parameter {
	
	import flash.text.*;
	
	import onyx.parameter.*;
	import onyx.ui.component.*;
	import onyx.ui.core.*;
	
	use namespace skinPart;
	
	[UISkinPart(id='skin', 		type='buttonSkin',	transform='default', constraint='relative', top='0', left='0', right='0', bottom='0')]
	[UISkinPart(id='label',		type='text',		constraint='relative', top='0', left='0', right='0', bottom='0')]
	
	public final class UIParameterSliderTextDisplay extends UIObject implements IControlValueDisplay {
		
		/**
		 * 	@private
		 */
		skinPart var skin:UIButtonSkin;
		
		/**
		 * 	@private
		 */
		skinPart var label:UITextField;

		/**
		 * 	@public
		 */
		override public function initialize(data:Object):void {
			
			// hand
			this.buttonMode			= this.useHandCursor = true;
			
			// initialize
			super.initialize(data);
			
			// text align
			this.label.textAlign	= 'center';
		}
		
		/**
		 * 	@public
		 */
		public function update(value:*):void {
			label.text		= value;
		}
		
		/**
		 * 	@public
		 */
		override public function arrange(rect:UIRect):void {
			
			super.arrange(rect);
			
			arrangeSkins(rect.identity());

		}
	}
}