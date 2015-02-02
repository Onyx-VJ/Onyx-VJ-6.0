package onyx.ui.component {
	
	import onyx.ui.core.*;
	
	use namespace skinPart;
	
	[UIComponent(id='windowSkin')]

	[UISkinPart(id='background',	type='skin',	transform='theme::default',	constraint='relative', left='0', right='0', top='0', bottom='0', skinClass='WindowBackground')]
	[UISkinPart(id='label',			type='text',	constraint='relative',	left='2',	right='2', top='2',	height='15')]
	
	// container bounds should be top 18
	final public class UIWindow extends UIContainer {

		// [UISkinPart(constraint='relative', left='0', right='0', top='0', height='15')]
		skinPart var label:UITextField;
		
		// [UISkinPart(constraint='relative', left='0', right='0', top='0', bottom='0', skinClass='WindowBackground')]
		skinPart var background:UISkin;
		
		/**
		 * 	@private
		 */
		override public function initialize(data:Object):void {
			
			// initialize
			super.initialize(data);
			
			// data
			if (label && data) { 
				label.text	= data.title;
			}
		}
		
		/**
		 * 	@public
		 */
		public function get content():UIObject {
			return getChildAt(2) as UIObject;
		}
		
		/**
		 * 	@public
		 */
		CONFIG::DEBUG override public function toString():String {
			return '[UIWindow: ' + (label ? label.text : '') + ']';
		}
	}
}