package onyxui.assets {
	
	import flash.display.*;
	import flash.events.*;
	
	[Embed(
			source='src/Assets.swf',
			symbol='ButtonSquareSkin'
	)]
	final public class UIAssetButtonSkinSquare extends SimpleButton {
		
		override public function set width(value:Number):void {
			super.scaleX = value * 0.01;
		}
		
		override public function set height(value:Number):void {
			super.scaleY = value * 0.01;
		}

	}
}