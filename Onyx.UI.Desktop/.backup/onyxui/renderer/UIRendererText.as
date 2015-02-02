package onyxui.renderer {

	import flash.display.*;
	import flash.text.*;
	
	import onyxui.assets.*;
	import onyxui.core.*;
	
	public final class UIRendererText extends UIRenderer {
		
		/**
		 * 	@private
		 */
		private var skin:DisplayObject		= addChild(new UIButtonSkin(UIAssetButtonSkinAlt));
		
		/**
		 * 	@private
		 */
		private var label:TextField;
		
		/**
		 * 	@public
		 */
		public function UIRendererText():void {
			
			addChild(label	= new TextField());
			
			label.name						= 'label';
			label.embedFonts				= true;
			label.antiAliasType				= AntiAliasType.ADVANCED;
			label.defaultTextFormat			= UIStyle.FORMAT_DEFAULT;
			label.mouseEnabled				= false;
			label.height					= 15;
			label.mouseEnabled				= false;
			
		}
		
		/**
		 * 	@public
		 */
		override public function set data(data:*):void {
			label.text	= String(data) || '';
		}
		
		/**
		 * 	@public
		 */
		override public function resize(width:int, height:int):void {
			label.width		= width - 2;
			label.height	= height;
			skin.width		= width;
			skin.height		= height;
		}
	}
}