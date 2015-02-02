package onyx.ui.renderer {

	import flash.display.*;
	import flash.text.*;
	
	import onyx.parameter.IParameterIterator;
	import onyx.ui.component.*;
	import onyx.ui.core.*;
	
	use namespace skinPart;
		
	[UISkinPart(id='skin',	type='buttonSkin',	transform='default::transform', constraint='relative', top='0', left='0', right='0', bottom='0')]
	[UISkinPart(id='label',	type='text',		constraint='relative', top='0', left='0', right='0', bottom='0')]
	
	public final class UIRendererText extends UIRenderer {
		
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
			
			super.initialize(data);
			
			label.textAlign = data.textAlign || 'left';
			label.mouseEnabled	= false;
			
			skin.setReleaseEnabled(true);

		}
		
		/**
		 * 	@public
		 */
		override public function update(parameter:IParameterIterator, data:*):void {
			label.text	= parameter.format(data);
		}
		
		/**
		 * 	@public
		 */
		override public function arrange(rect:UIRect):void {
			
			super.arrange(rect);

			var bounds:UIRect	= rect.identity();
			label.arrange(bounds);
			skin.arrange(bounds);
			
		}
	}
}