package onyxui.window.layer {
	
	import flash.display.*;
	import flash.events.*;
	import flash.text.*;
	
	import onyx.core.*;
	import onyx.plugin.*;
	
	import onyxui.assets.*;
	import onyxui.core.*;

	public final class UIFilter extends UIObject {
		
		/**
		 * 	@public
		 */
		public var target:IPlugin;
		
		/**
		 * 	@private
		 */
		private const label:TextField			= addChild(new TextField()) as TextField;
		
		/**
		 * 	@private
		 */
		private const background:UISkin			= addChildAt(new UISkin(UIAssetFilterBackgroundSkin), 0) as UISkin;
		
		/**
		 * 	@public
		 */
		private const closeButton:SimpleButton	= addChild(new UIAssetFilterCloseButton()) as SimpleButton;
		
		/**
		 * 	@private
		 */
		private var closeCallback:Function;
		
		/**
		 * 	@public
		 */
		public function UIFilter(instance:IPlugin, closeCallback:Function):void {
			
			this.target						= instance;
			this.closeCallback				= closeCallback;
			
			label.embedFonts				= true;
			label.antiAliasType				= AntiAliasType.ADVANCED;
			label.defaultTextFormat			= UIStyle.FORMAT_BLUE;
			label.mouseEnabled				= false;
			label.width						= 16;
			label.height					= 16;
			label.mouseEnabled				= false;
			label.x							= 20;
			label.y							= 2;
			label.text						= instance.name;
			
			useHandCursor = buttonMode = true;
			
			// close
			closeButton.addEventListener(MouseEvent.CLICK, handler);
			
		}
		
		/**
		 * 	@private
		 */
		private function handler(event:Event):void {
			
			// stop
			event.stopPropagation();
			
			// close
			closeCallback(target);
		}

		/**
		 * 	@public
		 */
		public function setSelected(value:Boolean):void {
			background.frame(value ? 2 : 1);
		}
		
		
		/**
		 * 	@public
		 */
		public function setMuted(value:Boolean):void {
			if (value) {
				alpha = 0.5;
			} else {
				alpha		= 1.0;
			}
		}

		/**
		 *	@public 
		 */
		override public function resize(width:int, height:int):void {
			
			label.width							= width - 20;
			
			// close me
			closeButton.x						= 2;
			closeButton.y						= 2;
			closeButton.transform.colorTransform = UIStyle.TRANSFORM_DEFAULT;
			
		}
		
		/**
		 * 	@public
		 */
		override public function dispose():void {
			closeButton.removeEventListener(MouseEvent.CLICK, handler);
		}
	}
}