package onyxui.component {
	
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.text.*;
	
	import onyx.core.*;
	
	import onyxui.assets.*;
	import onyxui.core.*;
	
	use namespace skin;
	
	[UISkinPart(id='skin',		definition='onyxui.component::UIButtonSkin',		top='0', left='0', right='0', bottom='0',	skin='onyxui.assets::UIAssetButtonSkin')]
	[UISkinPart(id='label',		definition='onyxui.component::UITextField',			top='2', left='2', right='2', height='15')]
	
	final public class UIButton extends UIObject {
		
		/**
		 * 	@private
		 */
		skin var skin:UIButtonSkin;
		
		/**
		 * 	@private
		 */
		skin var label:UITextField;
		
		/**
		 * 	@public
		 */
		public function set text(text:String):void {
			label.text	= text;
		}
		
		/**
		 * 	@public
		 */
		override public function unserialize(token:Object):void {
			trace(this, token);
			if (token.label) {
				trace('x');
				text	= token.label;
			}
		}
	}
}