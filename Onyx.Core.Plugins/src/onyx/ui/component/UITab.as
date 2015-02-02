package onyx.ui.component {
	
	import onyx.ui.core.*;
	
	use namespace skinPart;
	
	[UIComponent(id='tab')]
	
	[UISkinPart(id='background',	type='skin',	constraint='fill', transform='transform::default', skinClass='TabBackground')]
	[UISkinPart(id='label',			type='text',	constraint='relative', left='2', right='2', top='2', height='12', textAlign='center')]

	final public class UITab extends UIObject {
		
		/**
		 * 	@private
		 */
		skinPart var label:UITextField;
		
		/**
		 * 	@private
		 */
		skinPart var background:UISkin;
		
		/**
		 * 	@public
		 */
		override public function initialize(data:Object):void {
			
			// init
			super.initialize(data);

			// store text
			label.text = data.label;
			buttonMode = useHandCursor = true;
			
		}
		
		/**
		 * 	@public
		 */
		override public function arrange(rect:UIRect):void {
			
			// arrange
			super.arrange(rect);
			
			// 
			arrangeSkins(rect.identity());
			
		}
	}
}