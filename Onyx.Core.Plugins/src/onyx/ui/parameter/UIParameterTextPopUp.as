package onyx.ui.parameter {
	
	import flash.events.*;
	
	import onyx.core.*;
	import onyx.parameter.*;
	import onyx.ui.component.*;
	import onyx.ui.core.*;
	
	use namespace skinPart;
	
	[UISkinPart(id='skin',	type='skin',	transform='theme::default', skinClass='DropDownBackground', constraint='relative', top='0', left='0', right='0', bottom='0')]
	[UISkinPart(id='label', type='text',	constraint='relative', top='0', left='0', right='0', bottom='0')]
	
	final public class UIParameterTextPopUp extends UIObject {
		
		/**
		 * 	@private
		 */
		skinPart var skin:UISkin;
		
		/**
		 * 	@private
		 */
		skinPart var label:UITextField;
		
		/**
		 * 	@public
		 */
		override public function initialize(data:Object):void {
			
			// init
			super.initialize(data);
			
			label.editable	= true;
			label.multiline	= true;
			
			addEventListener(MouseEvent.MOUSE_DOWN, 	handleMouse);
			addEventListener(MouseEvent.MOUSE_UP,		handleMouse);
			addEventListener(MouseEvent.CLICK,			handleMouse);

		}
		
		/**
		 * 	@private
		 */
		private function handleMouse(e:MouseEvent):void {
			e.stopPropagation();
		}
		
		/**
		 * 	@public
		 */
		override public function arrange(rect:UIRect):void {
			
			// update
			super.arrange(rect);
			
			rect = rect.identity();
			skin.measure(rect);
			label.measure(rect);
			
		}
		
		public function set text(value:String):void {
			label.text = value;
		}
		
		public function get text():String {
			return label.text;
		}

		/**
		 * 	@public
		 */
		public function setFocus():void {
			
			label.setFocus();
			
		}
		
		/**
		 * 	@public
		 */
		override public function dispose():void {
			
			removeEventListener(MouseEvent.MOUSE_DOWN, 		handleMouse);
			removeEventListener(MouseEvent.MOUSE_UP,		handleMouse);
			removeEventListener(MouseEvent.CLICK,			handleMouse);
			
			// dispose
			super.dispose();

		}
	}
}