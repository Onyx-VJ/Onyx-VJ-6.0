package onyx.ui.component {
	
	import flash.display.*;
	
	import onyx.core.Console;
	import onyx.ui.core.*;
	import onyx.ui.factory.*;
	
	use namespace skinPart;

	[UIComponent(id='skin')]
	
	final public class UISkin extends UIObject {
		
		/**
		 * 	@private
		 */
		skinPart var skinObject:DisplayObject;
		
		/**
		 * 	@public
		 */
		override public function initialize(data:Object):void {
			
			// initialize
			super.initialize(data);
			
			// skin?
			if (data.skinClass) {
				
				skinObject = UIFactoryDefinitions.CreateAsset(data.skinClass);
				if (skinObject) {
					addChild(skinObject);
					if (skinObject is MovieClip) {
						(skinObject as MovieClip).stop();
					}
				} else {
					Console.LogError('no skin', this);
				}

				if (data.transform) {
					
					// set transform
					transform.colorTransform	= UIStyleManager.TRANSFORM_DEFAULT;
					
				}
			}
		}
		
		/**
		 * 	@public
		 */
		public function setCurrentFrame(frame:int):void {
			if (skinObject is MovieClip) {
				(skinObject as MovieClip).gotoAndStop(frame);
			}
		}
		
		/**
		 * 	@public
		 */
		override public function arrange(rect:UIRect):void {
			
			// arrange
			super.arrange(rect);

			// skinobj
			if (skinObject) {
				skinObject.width	= rect.width;
				skinObject.height	= rect.height;
			}
		}
	}
}