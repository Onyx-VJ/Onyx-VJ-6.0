package onyxui.component {
	
	import flash.geom.Rectangle;
	import flash.text.*;
	
	import onyxui.core.*;

	public class UITextField extends UIObject  {
		
		/**
		 * 	@private
		 */
		protected const label:TextField		= addChild(new TextField()) as TextField;
		
		/**
		 * 	@public
		 */
		public function UITextField(format:TextFormat = null):void {
			
			label.name						= 'label';
			label.embedFonts				= true;
			label.antiAliasType				= AntiAliasType.ADVANCED;
			label.gridFitType				= GridFitType.SUBPIXEL;
			label.defaultTextFormat			= format || UIStyle.FORMAT_DEFAULT;
			label.mouseEnabled				= false;
			label.width						= 16;
			label.height					= 16;
			
			mouseEnabled					= false;
			
		}
		
		/**
		 * 	@public
		 */
		public function set text(text:String):void {
			label.text	= text;
		}
		
		/**
		 * 	@public
		 */
		public function get text():String {
			return label.text;
		}
		
		/**
		 * 	@public
		 */
		public function appendText(text:String):void {
			label.appendText(text);
		}
		
		/**
		 * 	@public
		 */
		override public function unserialize(token:Object):void {
			
			if (token.text) {
				label.text	= token.text;
			}
			
			// unserialize constraint, etc
			super.unserialize(token);
			
		}

		/**
		 *	@public 
		 */
		override public function arrange(rect:Rectangle):void {
			
			label.x			= rect.x;
			label.y			= rect.y;
			label.width		= rect.width;
			label.height	= rect.height;

		}
	}
}