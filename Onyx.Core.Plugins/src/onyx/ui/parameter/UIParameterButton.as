package onyx.ui.parameter {
	
	import flash.events.*;
	
	import onyx.core.*;
	import onyx.parameter.*;
	import onyx.ui.component.*;
	import onyx.ui.core.*;
	
	use namespace skinPart;
	
	[UISkinPart(id='skin', type='buttonSkin',	transform='default', constraint='relative', top='0', left='0', right='0', bottom='0')]
	[UISkinPart(id='label', type='text',		transform='default', constraint='relative', top='0', left='0', right='0', bottom='0')]
	
	final public class UIParameterButton extends UIParameterDisplayBase {
		
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
			
			// click?
			skin.addEventListener(MouseEvent.CLICK, handleClick);
			
		}
		
		/**
		 * 	@private
		 */
		private function handleClick(event:Event):void {
			
			var p:IParameterExecutable = parameter as IParameterExecutable;
			if (p) {
				p.execute();
			}
		}

		/**
		 * 	@public
		 */
		override public function arrange(rect:UIRect):void {
			
			super.arrange(rect);
			
			rect	= rect.identity();
			skin.measure(rect);
			label.measure(rect);

		}
		
		/**
		 * 	@public
		 */
		override public function update():void {
			label.text	= parameter.name;
		}
		
		/**
		 * 	@public
		 */
		override public function dispose():void {
			
			// remove
			skin.removeEventListener(MouseEvent.CLICK, handleClick);
			
			// dispose
			super.dispose();

		}
	}
}