package onyxui.window {
	
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.text.*;
	import flash.utils.*;
	
	import onyx.core.*;
	import onyx.display.*;
	import onyx.event.*;
	
	import onyxui.assets.*;
	import onyxui.component.*;
	import onyxui.core.*;
	
	use namespace skin;
	
	[PluginInfo(
		title	= 'Frame Counter',
		width	= '300',
		height	= '300',
		top		= '150',
		left	= '150'
	)]

	[UISkinPart(id='text', definition='onyxui.component::UITextField',	constraint='relative', top='0', left='0', right='0', height='0')]

	final public class WindowFrameCounter extends UIObject {
		
		/**
		 * 	@private
		 */
		private var appFrames:int	= 0;
		private var dspFrames:int	= 0;
		private var time:int		= getTimer();
		
		// this is automated by the factory
		skin var text:UITextField;
		
		private var display:IDisplay;

		/**
		 * 	@public
		 */
		override protected function initialize():void {
			
//			addChild(text);
//			display	= Onyx.GetDisplay(0);
//			if (display) {
//				display.addEventListener(ChannelEvent.RENDER_POST, handleRender);
//				
//				bitmap.bitmapData	= display.getSurface();
//				bitmap.width		= 320;
//				bitmap.height		= 240;
//				bitmap.x			= 4;
//				bitmap.y			= 18;
//				addChildAt(bitmap, 1);
//			}
			
			// get
			 addEventListener(Event.ENTER_FRAME, frame);

		}
		
		/**
		 * 	@private
		 */
		private function handleRender(event:Event):void {
			++dspFrames;
		};
		
		/**
		 * 	@private
		 */
		private function frame(event:Event):void {

			++appFrames;
			
			if (getTimer() - time >= 1000) {
				text.text		= appFrames.toString();
				time			= getTimer();
				text.appendText(':' + dspFrames);
				
				dspFrames		= appFrames	= 0;
			}
		}
		
		/**
		 * 	@public
		 */
		
		/**
		 * 	@public
		 */
		override public function dispose():void {
			
			removeEventListener(Event.ENTER_FRAME, frame);
			
		}
	}
}