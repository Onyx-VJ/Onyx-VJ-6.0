package onyx.ui.component {
	
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.text.*;
	
	import onyx.core.*;
	import onyx.util.*;
	import onyx.ui.core.*;
	import onyx.util.encoding.*;
	
	use namespace skinPart;
	
	[UIComponent(id='button')]
	
	[UISkinPart(id='skin',		type='skin', transform='theme::default', constraint='fill', skinClass='ButtonSquareSkin')]
	[UISkinPart(id='label',		type='text', constraint='relative', top='1', left='2', right='2', bottom='1', textAlign='center')]
	
	final public class UIButton extends UIObject {
		
		/**
		 * 	@private
		 */
		skinPart var skin:UISkin;
		
		/**
		 * 	@private
		 */
		skinPart var label:UITextField;
		
		/**
		 * 	@public
		 */
		public var data:*;
		
		/**
		 * 	@public
		 */
		override public function initialize(data:Object):void {
			
			// init
			super.initialize(data);
			
			if (data.label) {
				label.text = data.label;
			}
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
		override public function arrange(rect:UIRect):void {
			
			super.arrange(rect);
			
			arrangeSkins(rect.identity());
		}
	}
}