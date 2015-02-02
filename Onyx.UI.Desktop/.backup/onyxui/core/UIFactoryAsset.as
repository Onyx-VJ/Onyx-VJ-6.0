package onyxui.core {
	
	import flash.display.*;
	import flash.text.*;
	import flash.utils.*;
	
	import onyxui.assets.*;
	import onyxui.parameter.*;
	import onyxui.window.*;

	final public class UIFactoryAsset extends UIFactory {
		
		/**
		 * 	@private
		 */
		private var skin:Class;
		
		/**
		 * 	@public
		 */
		public function UIFactoryAsset(skin:Class):void {
			super(skin, { left: 0, right: 0, top: 0, bottom: 0 })
		}
		
		/**
		 * 	@public
		 */
		override public function createInstance():UIObject {
			return new UISkin(definition);
		}
	}
}