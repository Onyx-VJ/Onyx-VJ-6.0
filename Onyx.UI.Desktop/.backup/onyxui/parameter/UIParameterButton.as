package onyxui.parameter {
	
	import flash.events.*;
	
	import onyx.core.*;
	import onyx.parameter.*;
	
	import onyxui.assets.*;
	import onyxui.core.*;

	public class UIParameterButton extends UIParameter {
		
		/**
		 * 	@private
		 */
		private const skin:UIButtonSkin	= addChild(new UIButtonSkin(UIAssetButtonSkin)) as UIButtonSkin;
		
		/**
		 * 	@private
		 */
		private const label:UITextField	= addChild(new UITextField()) as UITextField;
		
		/**
		 * 	@public
		 */
		override public function initialize():void {
			skin.addEventListener(MouseEvent.CLICK, handleClick);
			label.text	= parameter.name;
		}
		
		/**
		 * 	@private
		 */
		private function handleClick(event:Event):void {
			var p:IParameterExecutable = parameter as IParameterExecutable;
			if (p) {
				p.execute();
			}
		}

		/**
		 * 	@public
		 */
		override public function showLabel():Boolean {
			return false;
		}
		
		/**
		 * 	@public
		 */
		override public function resize(width:int, height:int):void {
			label.resize(width, height);
			skin.resize(width, height);
			
			super.resize(width, height);
		}
		
		/**
		 * 	@public
		 */
		override public function dispose():void {
			
			// remove
			skin.removeEventListener(MouseEvent.CLICK, handleClick);
			
			// dispose
			super.dispose();

		}
	}
}