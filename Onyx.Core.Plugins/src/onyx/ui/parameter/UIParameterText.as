package onyx.ui.parameter {
	
	import flash.events.*;
	import flash.geom.Rectangle;
	
	import onyx.core.*;
	import onyx.parameter.*;
	import onyx.ui.component.*;
	import onyx.ui.core.*;
	import onyx.ui.factory.UIFactory;
	
	use namespace skinPart;
	
	[UISkinPart(id='skin',	type='buttonSkin',	transform='default', constraint='relative', top='0', left='0', right='0', bottom='0')]
	[UISkinPart(id='label', type='text',		transform='default', constraint='relative', top='0', left='0', right='0', bottom='0')]
	
	final public class UIParameterText extends UIParameterDisplayBase {
		
		/**
		 * 	@private
		 */
		skinPart var skin:UIButtonSkin;
		
		/**
		 * 	@private
		 */
		skinPart var label:UITextField;
		
		/**
		 * 	@private
		 */
		private var popup:UIParameterTextPopUp;
		
		/**
		 * 	@public
		 */
		override public function initialize(data:Object):void {
			
			// init
			super.initialize(data);
			
			// add listener
			skin.addEventListener(MouseEvent.CLICK, handleClick);

		}
		
		/**
		 * 	@private
		 */
		private function handleClick(event:Event):void {
			
			application.addChild(popup = new UIFactory(UIParameterTextPopUp).createInstance());
			
			var rect:Rectangle = this.getRect(application);
			popup.arrange(new UIRect(rect.x - 75, rect.y - 75, 150, 150));
			popup.text		= parameter.value;
			popup.setFocus();
			popup.addEventListener(Event.CHANGE,			handleChange);
			popup.addEventListener(KeyboardEvent.KEY_DOWN,	handleChange);
			popup.addEventListener(KeyboardEvent.KEY_UP,	handleChange);
			
			// listen
			application.addEventListener(MouseEvent.CLICK, handleMouse);
			
			//
			event.stopPropagation();
			
		}
		
		private function handleMouse(e:MouseEvent):void {
			clearPopup();
		}
		
		private function clearPopup():void {
			if (popup) {
				
				popup.removeEventListener(Event.CHANGE, handleChange);
				application.removeChild(popup);
				application.removeEventListener(MouseEvent.CLICK, handleMouse);
				
				popup.dispose();
				popup = null;
				
			}
		}
		
		private function handleChange(e:Event):void {
			
			e.stopPropagation();
			
			switch (e.type) {
				case Event.CHANGE:
					parameter.value = popup.text;
					break;
			}
		}

		/**
		 * 	@public
		 */
		override public function arrange(rect:UIRect):void {
			
			super.arrange(rect);
			
			rect = rect.identity();
			skin.measure(rect);
			label.measure(rect);
		}
		
		/**
		 * 	@public
		 */
		override public function update():void {
			label.text	= parameter.value;
		}
		
		/**
		 * 	@public
		 */
		override public function dispose():void {
			
			clearPopup();
			
			// remove
			skin.removeEventListener(MouseEvent.CLICK, handleClick);
			
			// dispose
			super.dispose();

		}
	}
}