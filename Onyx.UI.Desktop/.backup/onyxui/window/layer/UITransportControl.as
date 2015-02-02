package onyxui.window.layer {
	
	import flash.events.*;
	
	import onyx.core.*;
	import onyx.display.*;
	import onyx.event.*;
	
	import onyxui.assets.*;
	import onyxui.core.*;
	import onyxui.parameter.*;
	import onyxui.renderer.*;
	
	use namespace parameter;

	public final class UITransportControl extends UIObject {

		/**
		 * 	@private
		 */
		private const rewind:UISkin						= new UISkin(UIAssetTransportRewind);
		private const forward:UISkin					= new UISkin(UIAssetTransportForward);
		private const slider:UIParameterSlider			= new UIParameterSlider();
		private const dropDown:UIParameterDropDown		= new UIParameterDropDown(UIRendererIcon);
		
		private var layer:IDisplayLayer;
		private var info:LayerTime;
		private var selected:UISkin;
		
		
		/**
		 * 	@public
		 */
		override public function initialize():void {
			
			addChild(rewind).x		= 1;
			addChild(forward).x 	= 29;
			addChild(dropDown).x	= 40;
			addChild(slider).x		= 62;
			
			dropDown.resize(24, 16);
			slider.resize(26, 16);
			
			slider.y	= 1;
			
			rewind.addEventListener(MouseEvent.CLICK, handleClick);
			forward.addEventListener(MouseEvent.CLICK, handleClick);
				
			// initialize
			super.initialize();
			
		}
		
		/**
		 *	@public 
		 */
		public function attach(layer:IDisplayLayer):void {
			
			this.layer	= layer;
			this.info	= layer.getTimeInfo();
			
			slider.attach(layer.getParameter('playSpeed'));
			dropDown.attach(layer.getParameter('playMode'));
			
			// bind
			layer.getParameter('playDirection').listen(update, true);
			
			update();

		}
		
		private function update(event:ParameterEvent = null):void {
			if (info.playDirection === 0) {
			} else if (info.playDirection > 0) {
				select(forward);
			} else {
				select(rewind);
			}
		}
		
		private function select(item:UISkin):void {
			
			if (selected) {
				selected.frame(1);
			}
			(selected = item).frame(2);

		}
		
		/**
		 * 	@private
		 */
		private function handleClick(event:MouseEvent):void {
			switch (event.currentTarget) {
				case rewind:
					layer.setParameterValue('playDirection', -1.0);
					break;
				case forward:
					layer.setParameterValue('playDirection', 1.0);
					break;
			}
		}
		
		/**
		 * 	@public
		 */
		override public function dispose():void {
			
			// bind
			layer.getParameter('playDirection').listen(update, false);
			
			// dispose
			super.dispose();

		}
	}
}