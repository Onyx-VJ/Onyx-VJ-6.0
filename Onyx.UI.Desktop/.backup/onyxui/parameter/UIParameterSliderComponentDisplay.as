package onyxui.parameter {
	
	import flash.text.*;
	
	import onyx.parameter.Parameter;
	
	import onyxui.assets.*;
	import onyxui.core.*;
	
	public final class UIParameterSliderComponentDisplay extends UITextField implements IControlValueDisplay {
		
		/**
		 * 	@private
		 */
		private var color:uint;
		
		/**
		 * 	@private
		 */
		private var skin:UIButtonSkin	= new UIButtonSkin(UIAssetButtonSkinAlt);
		
		/**
		 * 	@private
		 */
		private var parameter:Parameter;
		
		/**
		 * 	@public
		 */
		public function UIParameterSliderComponentDisplay(color:uint = 0xFFFFFF):void {
			this.color	= color;
			label.defaultTextFormat			= UIStyle.FORMAT_CENTER;
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
		override public function initialize():void {
			
			super.initialize();
			
			label.textColor	= color;
			
			mouseEnabled	= mouseChildren = true;
			buttonMode		= useHandCursor = true;
			
			skin.resize(label.width = 16, label.height = 16);
			addChildAt(skin, 0);
		}
		
		/**
		 * 	@public
		 */
		override public function resize(width:int, height:int):void {
			super.resize(width, height);
			skin.resize(width, height);
		}

		/**
		 * 	@public
		 */
		public function updateDisplay():void {
			
			if (!parameter) {
				return;
			}

			text		= parameter.name.charAt(0).toUpperCase();
			alpha		= parameter.value;
		}
	}
}