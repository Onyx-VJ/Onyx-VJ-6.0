package onyx.ui.window.layer {
	
	import flash.events.*;
	
	import onyx.core.*;
	import onyx.display.*;
	import onyx.event.*;
	import onyx.ui.component.*;
	import onyx.ui.core.*;
	import onyx.ui.parameter.*;
	import onyx.ui.renderer.*;
	
	use namespace parameter;
	use namespace skinPart;
	
	[UIComponent(id='layerTransport')]
	
	[UISkinPart(id='rewind',	type='skin',		skinClass='TransportRewind')]
	[UISkinPart(id='forward',	type='skin',		skinClass='TransportForward')]
	[UISkinPart(id='dropDown',	type='parameter',	constraint='absolute', bounds='30,1,25,16')]
	[UISkinPart(id='slider',	type='parameter',	constraint='absolute', bounds='52,1,38,15')]

	public final class UILayerTransport extends UIObject {

		/**
		 * 	@private
		 */
		skinPart var rewind:UISkin;
		
		/**
		 * 	@private
		 */
		skinPart var forward:UISkin;
		
		/**
		 * 	@private
		 */
		skinPart var slider:UIParameter;
		
		/**
		 * 	@private
		 */
		skinPart var dropDown:UIParameter;
		
		/**
		 * 	@private
		 */
		private var layer:IDisplayLayer;
		
		/**
		 * 	@private
		 */
		private var info:LayerTime;
		
		/**
		 * 	@private
		 */
		private var bounds:UIRect;
		
		/**
		 * 	@private
		 */
		private var selected:UISkin;
		
		/**
		 * 	@public
		 */
		override public function initialize(data:Object):void {
				
			// initialize
			super.initialize(data);
			
			rewind.addEventListener(MouseEvent.CLICK, handleClick);
			forward.addEventListener(MouseEvent.CLICK, handleClick);
			select(forward);
			
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
			layer.getParameter('playDirection').addEventListener(ParameterEvent.VALUE_CHANGE, update);
			
			// update
			update();

		}
		
		/**
		 * 	@private
		 */
		private function update(event:ParameterEvent = null):void {
			if (info.playDirection === 0) {
			} else if (info.playDirection > 0) {
				select(forward);
			} else {
				select(rewind);
			}
		}
		
		/**
		 * 	@private
		 */
		override public function arrange(rect:UIRect):void {
			
			super.arrange(rect);
			
			rewind.x 	= 2;
			forward.x	= 16;
			
			bounds = rect.identity();
			slider.measure(bounds);
			dropDown.measure(bounds);
			
		}
		
		private function select(item:UISkin):void {

			if (selected) {
				selected.setCurrentFrame(1);
			}
			
			(selected = item).setCurrentFrame(2);
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
			layer.getParameter('playDirection').removeEventListener(ParameterEvent.VALUE_CHANGE, update);
			
			// dispose
			super.dispose();

		}
	}
}