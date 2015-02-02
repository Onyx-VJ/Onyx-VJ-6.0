package onyx.ui.window.browser {
	
	import flash.display.DisplayObject;
	import flash.events.*;
	import flash.filters.DropShadowFilter;
	import flash.text.*;
	
	import onyx.core.*;
	import onyx.ui.component.*;
	import onyx.ui.core.*;
	import onyx.ui.factory.UIFactoryDefinitions;
	
	use namespace skinPart;

	[UISkinPart(id='thumbnail',		type='bitmap',		constraint='fill')]
	[UISkinPart(id='background',	type='buttonSkin',	transform='default::transform', constraint='relative', top='0', left='0', right='0', bottom='0', skinClass='ButtonClearUp')]
	[UISkinPart(id='label',			type='text',		constraint='fill')]
	final public class UIFileControl extends UIObject {
		
		/**
		 * 	@private
		 */
		private var reference:IFileReference;
		
		/**
		 * 	@private
		 */
		skinPart var thumbnail:UIBitmap;
		
		/**
		 * 	@private
		 */
		skinPart var background:UIButtonSkin;
		
		/**
		 * 	@private
		 */
		skinPart var label:UITextField;
		
		/**
		 * 	@public
		 */
		override public function initialize(data:Object):void {
			
			super.initialize(data);

			label.filters		= [new DropShadowFilter(3,45,0,1,0,0,2,1)];
			cacheAsBitmap = true;
		}
		
		/**
		 * 	@public
		 */
		public function set file(value:IFileReference):void {
			
			reference			= value;
			label.mouseEnabled	= false;
			label.text			= value.name;
			
		}
		
		/**
		 * 	@public
		 */
		public function get file():IFileReference {
			return reference;
		}
		
		/**
		 * 	@public
		 */
		override public function arrange(rect:UIRect):void {
			
			// arrange
			super.arrange(rect);
			
			// rende
			background.measure(rect.identity());
			label.measure(rect.identity());
			
		}
	}
}