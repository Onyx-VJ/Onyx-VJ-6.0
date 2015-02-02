package onyx.ui.window.layer {
	
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.text.*;
	
	import onyx.core.*;
	import onyx.plugin.*;
	import onyx.ui.component.*;
	import onyx.ui.core.*;
	import onyx.ui.event.SelectionEvent;
	
	use namespace skinPart;
	
	[UISkinPart(id='background',	type='skin',				constraint='relative',	top='0', right='0', left='0', bottom='0', transform='theme::default', skinClass='GeneratorBackgroundSkin')]
	[UISkinPart(id='label',			type='text',				constraint='relative',	top='1', right='0', left='0', bottom='0', color='0xCCCCCC', textAlign='left')]
	
	public final class UISelection extends UIFilterListItem {
		
		/**
		 * 	@public
		 */
		override public function initialize(data:Object):void {

			// initialize
			super.initialize(data);
			
			// label
			label.text	= plugin.name;
			
		}

		/**
		 *	@public 
		 */
		override public function arrange(rect:UIRect):void {
			
			// arrange stuff
			super.arrange(rect);
			label.measure(rect);

		}
	}
}