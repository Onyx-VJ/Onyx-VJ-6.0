package onyx.ui.window.layer {
	
	import flash.events.*;
	
	import onyx.core.*;
	import onyx.ui.component.*;
	import onyx.ui.core.*;
	import onyx.ui.event.*;
	
	use namespace skinPart;
	
	public class UIFilterListItem extends UIObject {
		
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
		public var index:int;
		
		/**
		 * 	@internal
		 */
		public var plugin:IPlugin;
		
		/**
		 * 	@public
		 */
		override public function initialize(data:Object):void {
			
			// init!
			super.initialize(data);
			
			// set
			label.mouseEnabled			= false;
			useHandCursor = buttonMode	= true;
			
			// handleclick!
			background.addEventListener(MouseEvent.CLICK,		handleMouse);
			background.addEventListener(MouseEvent.RIGHT_CLICK, handleMouse);

		}
		
		/**
		 * 	@private
		 */
		private function handleMouse(e:MouseEvent):void {
			
			switch (e.type) {
				case MouseEvent.CLICK:
					dispatchEvent(new SelectionEvent(SelectionEvent.SELECT, plugin));
					break;
				case MouseEvent.RIGHT_CLICK:
					plugin.getParameters().reset();
					break;
			}
		}

		
		/**
		 * 	@public
		 */
		public function attach(plugin:IPlugin, index:int):void {
			this.plugin	= plugin;
			this.index	= index;
		}
		
		/**
		 * 	@public
		 */
		public function setSelected(value:Boolean):void {
			background.setCurrentFrame(value ? 2 : 1);
		}
		
		/**
		 * 	@public
		 */
		override public function dispose():void {
			
			// handleclick!
			background.removeEventListener(MouseEvent.CLICK, handleMouse);
			background.removeEventListener(MouseEvent.RIGHT_CLICK, handleMouse);

			// dispose
			super.dispose();
		}
	}
}