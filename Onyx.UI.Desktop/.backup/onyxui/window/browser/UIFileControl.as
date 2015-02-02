package onyxui.window.browser {
	
	import flash.events.*;
	import flash.text.*;
	
	import onyx.core.*;
	
	import onyxui.assets.*;
	import onyxui.core.*;

	final public class UIFileControl extends UIObject {
		
		/**
		 * 	@private
		 */
		public var file:IFileReference;
		
		/**
		 * 	@private
		 */
		private var skin:UIButtonSkin	= addChild(new UIButtonSkin(UIAssetButtonSkinAlt)) as UIButtonSkin;
		
		/**
		 * 	@private
		 */
		private var label:TextField		= addChild(new TextField()) as TextField;
		
		/**
		 * 	@public
		 */
		public function UIFileControl(file:IFileReference):void {
			
			this.file						= file;
			
			label.name						= 'label';
			label.embedFonts				= true;
			label.antiAliasType				= AntiAliasType.ADVANCED;
			label.defaultTextFormat			= UIStyle.FORMAT_DEFAULT;
			label.mouseEnabled				= false;
			label.text						= file.name;
			
		}
		
		/**
		 * 	@public
		 */
		override public function resize(width:int, height:int):void {
			skin.width	= label.width = width;
			skin.height = label.height = height;
		}
	}
}