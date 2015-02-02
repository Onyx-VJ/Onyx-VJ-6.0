package onyx.ui.window {
	
	import flash.events.*;
	import flash.text.*;
	import flash.utils.*;
	
	import onyx.core.*;
	import onyx.event.*;
	import onyx.ui.component.*;
	import onyx.ui.core.*;
	import onyx.util.encoding.*;
	
	use namespace skinPart;
	
	[UIComponent(id='Onyx.UI.Desktop.FrameCounter', title='FPS')]
	[UISkinPart(id='frameLabel', type='text', constraint='fill')]
	
	public final class WindowFrameCounter extends UIContainer {

		/**
		 * 	@private
		 * 	This is injected
		 */
		skinPart var frameLabel:UITextField;
		
		/**
		 * 	@private
		 */
		skinPart var background:UISkin;
		
		/**
		 * 	@private
		 */
		private var appFrames:int	= 0;
		
		/**
		 * 	@private
		 */
		private var time:int		= getTimer();
		
		/**
		 * 	@private
		 */
		private var displays:Vector.<IDisplay>;
		
		/**
		 * 	@public
		 */
		override public function initialize(data:Object):void {
			
			// do defaults
			super.initialize(data);
			
			// create text
			frameLabel.text	= '';
			
			// get
			addEventListener(Event.ENTER_FRAME, frame);

		}
		
		/**
		 * 	@private
		 */
		private function handleRender(e:Event):void {
		}
		
		/**
		 * 	@private
		 */
		private function frame(event:Event):void {
			
			++appFrames;
			
			if (getTimer() - time >= 1000) {
				
				frameLabel.text	= appFrames.toString();
				time			= getTimer();
				appFrames	= 0;
			}
		}
		
		/**
		 * 	@public
		 */
		override public function dispose():void {
			
			removeEventListener(Event.ENTER_FRAME, frame);
			
		}
	}
}