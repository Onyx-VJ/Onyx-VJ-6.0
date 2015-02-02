package onyx.ui.component {
	
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	
	import onyx.ui.core.*;
	import onyx.ui.factory.*;
	
	use namespace skinPart;
	
	[UIComponent(id='buttonSkin')]

	final public class UIButtonSkin extends UIObject {
		
		/**
		 * 	@private
		 */
		private var states:Object	= {};
		
		/**
		 * 	@private
		 */
		private var bounds:UIRect	= new UIRect();
		
		/**
		 * 	@private
		 */
		private var button:SimpleButton;
		
		/**
		 * 	@public
		 */
		override public function initialize(data:Object):void {
			
			// data
			super.initialize(data);
			
			button					= addChild(new SimpleButton(
				UIFactoryDefinitions.CreateAsset('ButtonClearUp'),
				UIFactoryDefinitions.CreateAsset('ButtonClearOver'),
				UIFactoryDefinitions.CreateAsset('ButtonClearDown'),
				UIFactoryDefinitions.CreateAsset('ButtonClearHit')
			)) as SimpleButton;
			
			// transform
			transform.colorTransform	= UIStyleManager.TRANSFORM_DEFAULT;
			mouseEnabled				= false;
			button.mouseEnabled			= true;
		}
		
		public function setReleaseEnabled(value:Boolean):void {
			button.trackAsMenu	= value;
		}
		
		/**
		 * 	@public
		 */
		override public function arrange(rect:UIRect):void {
			
			// arrange
			super.arrange(rect);
			
			button.width	= rect.width;
			button.height	= rect.height;

		}
	}
}