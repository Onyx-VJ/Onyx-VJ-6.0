package onyx.ui.component {

	import flash.text.*;
	
	import onyx.ui.core.*;
	
	public final class UITextField extends UIObject {
		
		/**
		 * 	@private
		 */
		private const label:TextField	= addChild(new TextField()) as TextField;
		
		/**
		 * 	@private
		 */
		override public function initialize(data:Object):void {
			label.text 			= data.text || '';
			label.textColor		= 0xFFFFFF;
			label.selectable	= false;
			label.border		= true;
			label.borderColor	= 0xFF0000;
		}
		
		/**
		 * 	@public
		 */
		override public function arrange(bounds:UIObjectBounds):void {
			
			super.arrange(bounds);
			
			label.width		= bounds.width;
			label.height	= bounds.height;
			
		}
		
		public function set text(value:String):void {
			label.text = value;
		}
	}
}