package onyx.ui.window.browser {
	
	import onyx.core.*;
	import onyx.ui.component.*;
	import onyx.ui.core.*;
	
	use namespace skinPart;

	[UISkinPart(id='background',	type='buttonSkin',	transform='default::transform', constraint='relative', top='0', left='0', right='0', bottom='0', skinClass='ButtonClearUp')]
	[UISkinPart(id='label',			type='text',		constraint='relative', top='0', left='0', right='0', bottom='0')]

	final public class UIFilterProxy extends UIObject {
		
		/**
		 * 	@private
		 */
		public var target:IPluginDefinition;
		
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
		public function attach(target:IPluginDefinition):void {
			
			// attach
			label.text	= target.name;
			
			this.target	= target;
		}
		
		/**
		 *	@public 
		 */
		override public function arrange(rect:UIRect):void {
			
			// arrange stuff
			super.arrange(rect);
			
			label.measure(rect);
			background.measure(rect);
		}
	}
}