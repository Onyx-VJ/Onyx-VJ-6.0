package onyx.ui.window {
	
	import flash.display.*;
	import flash.events.*;
	import flash.text.*;
	import flash.utils.*;
	
	import onyx.core.*;
	import onyx.display.*;
	import onyx.event.*;
	import onyx.host.*;
	import onyx.ui.component.*;
	import onyx.ui.core.*;
	import onyx.ui.factory.*;
	import onyx.ui.window.channel.*;
	import onyx.ui.window.layer.*;
	
	use namespace skinPart;
	
	[UIComponent(id='Onyx.UI.Desktop.Displays')]
	
	public final class WindowDisplay extends UIContainer {
		
		/**
		 * 	@private
		 */
		private var display:UIDisplay;

		/**
		 * 	@public
		 */
		override public function initialize(data:Object):void {
			
			super.initialize(data);
			
			addChild(display = UIFactoryDefinitions.CreateInstance('Onyx.UI.Desktop.Displays::Display'));
			
			// add display
			Onyx.addEventListener(OnyxEvent.DISPLAY_CREATE, handler);
		}
		
		
		/**
		 * 	@private
		 */
		private function handler(e:OnyxEvent):void {
			switch (e.type) {
				case OnyxEvent.DISPLAY_CREATE:
					display.attach(e.data as IDisplay);
					break;
			}
		}

		/**
		 * 	@public
		 */
		override public function dispose():void {
			
			// dispose
			super.dispose();
			
		}
	}
}