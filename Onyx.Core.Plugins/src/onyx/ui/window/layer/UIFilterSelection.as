package onyx.ui.window.layer {
	
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.text.*;
	
	import onyx.core.*;
	import onyx.plugin.*;
	import onyx.ui.component.*;
	import onyx.ui.core.*;
	import onyx.ui.event.*;
	
	use namespace skinPart;
	
	[UISkinPart(id='background',	type='skin',				constraint='relative',	top='0', right='0', left='0', bottom='0', transform='theme::default', skinClass='FilterBackgroundSkin')]
	[UISkinPart(id='label',			type='text',				constraint='relative',	top='1', right='0', left='15', bottom='0', color='0xCCCCCC', textAlign='left')]
	[UISkinPart(id='closeButton',	type='skin',				constraint='absolute',	bounds='5,5,7,7', transform='theme::default', skinClass='FilterClose')]
	
	public final class UIFilterSelection extends UIFilterListItem {
		
		/**
		 * 	@public
		 */
		skinPart var closeButton:UISkin;
		
		/**
		 * 	@public
		 */
		override public function initialize(data:Object):void {
			
			// initialize
			super.initialize(data);
			
			// label
			label.text	= plugin.name;
			
			// use cursor
			closeButton.addEventListener(MouseEvent.CLICK, handler);
			
		}
		
		/**
		 * 	@public
		 */
		public function setMuted(value:Boolean):void {
			if (value) {
				alpha = 0.5;
			} else {
				alpha = 1.0;
			}
		}
		
		/**
		 * 	@private
		 */
		private function handler(event:MouseEvent):void {
			
			dispatchEvent(new SelectionEvent(SelectionEvent.REMOVE, plugin));
		}
		
		/**
		 *	@public 
		 */
		override public function arrange(rect:UIRect):void {
			
			// arrange stuff
			super.arrange(rect);
			
			label.measure(rect);
			closeButton.measure(rect);
			
		}
		
		/**
		 * 	@public
		 */
		override public function dispose():void {
			
			closeButton.addEventListener(MouseEvent.CLICK, handler);
			
			super.dispose();
		}
	}
}