package onyx.ui.renderer {

	import flash.display.*;
	import flash.text.*;
	
	import onyx.core.*;
	import onyx.parameter.IParameter;
	import onyx.parameter.IParameterIterator;
	import onyx.plugin.*;
	import onyx.ui.component.*;
	import onyx.ui.core.*;
	
	use namespace skinPart;

	[UISkinPart(id='skin', type='buttonSkin', transform='default', constraint='relative', top='0', left='0', right='0', bottom='0')]
	
	public final class UIRendererIcon extends UIRenderer {
		
		/**
		 * 	@private
		 */
		skinPart var skin:UIButtonSkin;
		
		/**
		 * 	@private
		 */
		private var icon:DisplayObject;
		
		/**
		 * 	@public
		 */
		override public function update(parameter:IParameterIterator, data:*):void {
			
			while (numChildren > 0) {
				removeChildAt(0);
			}
			
			var plugin:IPluginDefinition = data;
			if (plugin) {
				icon = plugin.icon;
				if (icon) {
					addChild(icon);
				}
			}
		}
		
		/**
		 * 	@public
		 */
		override public function arrange(rect:UIRect):void {
			
			// arrange
			super.arrange(rect);
			
			// arrange
			skin.arrange(rect.identity());
			
		}
	}
}