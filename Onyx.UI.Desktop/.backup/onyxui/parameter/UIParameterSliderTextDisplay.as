package onyxui.parameter {
	
	import flash.text.*;
	
	import onyx.parameter.*;
	
	import onyxui.assets.*;
	import onyxui.core.*;
	
	public final class UIParameterSliderTextDisplay extends UITextField implements IControlValueDisplay {
		
		/**
		 * 	@private
		 */
		private var parameter:Parameter;
		private const skin:UIButtonSkin	= new UIButtonSkin(UIAssetButtonSkinAlt);
		
		/**
		 * 	@public
		 */
		public function UIParameterSliderTextDisplay():void {
			super(UIStyle.FORMAT_RIGHT);
		}
		
		/**
		 * 
		 */
		override public function initialize():void {
			
			this.buttonMode = this.useHandCursor = true;
			
			addChildAt(skin, 0);
			
		}
		
		/**
		 * 	@public
		 */
		public function attach(param:Parameter):void {
			parameter = param;
		}
		
		/**
		 * 	@public
		 */
		public function updateDisplay():void {
			if (parameter) {
				text		= parameter.display();
			}
		}
		
		override public function resize(width:int, height:int):void {
			
			skin.resize(width, height);
			
			super.resize(width, height);
			
		}
	}
}