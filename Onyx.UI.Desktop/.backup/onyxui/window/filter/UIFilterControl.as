package onyxui.window.filter {
	
	import flash.events.*;
	import flash.text.*;
	
	import onyx.core.*;
	import onyx.plugin.*;
	
	import onyxui.assets.*;
	import onyxui.core.*;

	final public class UIFilterControl extends UIObject {
		
		/**
		 * 	@private
		 */
		public var plugin:IPluginDefinition;
		
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
		public function UIFilterControl(plugin:IPluginDefinition):void {
			
			// store plugin
			this.plugin						= plugin;
			
			label.embedFonts				= true;
			label.antiAliasType				= AntiAliasType.ADVANCED;
			label.defaultTextFormat			= UIStyle.FORMAT_DEFAULT;
			label.mouseEnabled				= false;
			label.text						= plugin.name;
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