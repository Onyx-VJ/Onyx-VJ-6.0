package onyx.ui.parameter {
	
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.utils.*;
	
	import onyx.core.*;
	import onyx.event.*;
	import onyx.parameter.*;
	import onyx.ui.core.*;
	import onyx.ui.factory.UIFactory;
	import onyx.util.*;
	
	public class UIParameterDisplayBase extends UIObject implements IUIParameter {
		
		/**
		 * 	@protected
		 */
		protected const bounds:UIRect			= new UIRect();
		
		/**
		 * 	@protected
		 */
		protected var parameter:IParameter;
		
		/**
		 * 	@public
		 */
		public function attach(param:IParameter):void {
			
			this.parameter	= param;
			this.update();
		}
		
		/**
		 * 	@public
		 */
		public function update():void {}
		
		/**
		 * 	@protected
		 */
		public function highlightForBind(show:Boolean):void {
			
			if (show) {
				
				var overlay:UIParameterOverlay	= getChildByName('overlay') as UIParameterOverlay || addChild(new UIParameterOverlay(parameter)) as UIParameterOverlay;
				overlay.setSize(bounds.width + 1, bounds.height);
				
			} else {
				
				overlay						= getChildByName('overlay') as UIParameterOverlay;
				if (overlay && contains(overlay)) {
					removeChild(overlay);
					(overlay as IControlParameterProxy).dispose();
				}
			}
		}
		
		/**
		 * 	@public
		 */
		override public function arrange(rect:UIRect):void {
			
			// arrange
			super.arrange(rect);
			
			bounds.width	= rect.width;
			bounds.height	= rect.height;
			
			var overlay:UIParameterOverlay = getChildByName('overlay') as UIParameterOverlay; 
			if (overlay) {
				overlay.setSize(rect.width, rect.height);
			}
		}
	}
}