package onyx.ui.window.browser {
	
	import flash.display.DisplayObject;
	import flash.events.*;
	import flash.text.*;
	
	import onyx.core.*;
	import onyx.ui.component.*;
	import onyx.ui.core.*;
	import onyx.ui.factory.UIFactoryDefinitions;
	
	use namespace skinPart;

	[UISkinPart(id='background',	type='buttonSkin',	transform='default::transform', constraint='relative', top='0', left='0', right='0', bottom='0', skinClass='ButtonClearUp')]
	[UISkinPart(id='label',			type='text',		constraint='relative', top='0', left='16', right='0', bottom='0')]
	final public class UIDirControl extends UIObject {
		
		/**
		 * 	@private
		 */
		private var reference:IFileReference;
		
		/**
		 * 	@private
		 */
		skinPart var background:UIButtonSkin;
		
		/**
		 * 	@private
		 */
		skinPart var icon:DisplayObject;
		
		/**
		 * 	@private
		 */
		skinPart var label:UITextField;
		
		/**
		 * 	@public
		 */
		public function set file(value:IFileReference):void {
			
			icon = addChild(UIFactoryDefinitions.CreateAsset('FolderIcon'));
			icon.x = 2;
			icon.y = 2;
			
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
			
			super.arrange(rect);
			
			background.measure(rect.identity());
			label.measure(rect.identity());
			
		}
	}
}