package onyxui.window.browser {
	
	import flash.events.*;
	import flash.text.*;
	
	import onyx.core.*;
	import onyx.plugin.*;
	
	import onyxui.assets.*;
	import onyxui.core.*;
	
	final public class UIProtocolControl extends UIObject {
		
		/**
		 * 	@public
		 */
		public var protocol:IPluginProtocol;
		
		/**
		 * 	@private
		 */
		private var skin:UIButtonSkin		= addChild(new UIButtonSkin(UIAssetButtonSkin)) as UIButtonSkin;
		
		/**
		 * 	@private
		 */
		private var label:TextField			= addChild(new TextField()) as TextField;
		
		/**
		 * 	@public
		 */
		public function UIProtocolControl(name:String, protocol:IPluginProtocol = null):void {
			
			this.protocol					= protocol;
			
			label.embedFonts				= true;
			label.antiAliasType				= AntiAliasType.ADVANCED;
			label.defaultTextFormat			= UIStyle.FORMAT_DEFAULT;
			label.mouseEnabled				= false;
			label.height					= 16;
			label.text						= name;
		}
		
		/**
		 * 	@public
		 */
		override public function resize(width:int, height:int):void {
			skin.width	= label.width	= width;
			skin.height = height;
			label.y		= (height / 2 - label.height / 2) >> 0;
		}
	}
}