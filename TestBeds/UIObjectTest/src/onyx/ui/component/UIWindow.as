package onyx.ui.component {
	
	import onyx.ui.core.*;
	
	use namespace skin;
	
	[UISkinPart(id='skin',		type='skin',	left='0',	right='0', top='0', bottom='0', skinClass='WindowBackground')]
	[UISkinPart(id='label',		type='text',	left='0',	right='0', top='0',	height='15')]

	final public class UIWindow extends UIObject {
		
		/**
		 * 	@public
		 */
		skin var label:UITextField;
		
		/**
		 * 	@public
		 */
		skin var skin:UISkin;
		
		/**
		 * 	@private
		 */
		override public function initialize(data:Object):void {
			
			if (label && data) { 
				label.text	= data.title;
			}

		}
	}
}