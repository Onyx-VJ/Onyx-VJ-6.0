package onyx.ui.parameter {
	
	import flash.display.*;
	import flash.text.*;
	import flash.text.engine.TextBaseline;
	
	import onyx.parameter.*;
	import onyx.ui.core.*;
	import onyx.ui.factory.UIFactoryDefinitions;
	
	public final class UIParameterSliderComponentDisplay extends UIObject implements IControlValueDisplay {
		
		/**
		 * 	@private
		 */
		private var drawColor:uint;
		
		/**
		 * 	@private
		 */
		private var skin:DisplayObject

		/**
		 * 	@public
		 */
		public function update(value:*):void {
			alpha = value;
		}
		
		/**
		 * 	@public
		 */
		override public function initialize(data:Object):void {
			
			super.initialize(data);
			
			mouseEnabled		= mouseChildren = true;
			buttonMode			= useHandCursor = true;
			
			switch (uint(data.color)) {
				case 0xFFFFFF:
					addChild(skin = UIFactoryDefinitions.CreateAsset('ComponentAlpha'));
					break;
				case 0xFF0000:
					addChild(skin = UIFactoryDefinitions.CreateAsset('ComponentRed'));
					break;
				case 0x00FF00:
					addChild(skin = UIFactoryDefinitions.CreateAsset('ComponentGreen'));
					break;
				case 0x0000FF:
					addChild(skin = UIFactoryDefinitions.CreateAsset('ComponentBlue'));
					break;
			}
		}
		
		/**
		 * 	@public
		 */
		override public function arrange(rect:UIRect):void {
			
			super.arrange(rect);
			
		}
	}
}