package onyxui.assets {
	
	import flash.display.*;
	
	[Embed(
			source='src/Assets.swf',
			symbol='ButtonClear'
	)]
	public final class UIAssetHitArea extends SimpleButton {
		
		override public function set width(value:Number):void {
			super.scaleX = value * 0.01;
		}
		
		override public function set height(value:Number):void {
			super.scaleY = value * 0.01;
		}
		
	}
}