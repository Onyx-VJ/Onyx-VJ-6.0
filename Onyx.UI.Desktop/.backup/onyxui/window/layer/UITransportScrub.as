package onyxui.window.layer {
	
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	
	import onyx.core.*;
	import onyx.display.*;
	import onyx.event.*;
	
	import onyxui.assets.*;
	import onyxui.core.*;
	import onyxui.event.*;
	import onyxui.parameter.*;
	
	use namespace parameter;

	public final class UITransportScrub extends UIObject {
		
		/**
		 * 	@private
		 */
		private const skin:DisplayObject		= addChild(new UIAssetPlaybackControl());
		private const hitarea:DisplayObject		= addChild(new UIAssetHitArea());
		private const loopStart:DisplayObject	= addChild(new UIAssetPlayStart());
		private const loopEnd:DisplayObject		= addChild(new UIAssetPlayEnd());
		private const bounds:Rectangle			= new Rectangle();
		
		private var layer:IDisplayLayer;
		private var info:LayerTime;
		private var prev:Number;
		private var drag:DisplayObject;
		
		/**
		 * 	@public
		 */
		override public function initialize():void {
			
			skin.y	= 8;
			
			loopStart.addEventListener(MouseEvent.MOUSE_DOWN,	handleMouse);
			loopEnd.addEventListener(MouseEvent.MOUSE_DOWN,		handleMouse);
			hitarea.addEventListener(MouseEvent.MOUSE_DOWN,		handleScrub);
			
		}
		
		/**
		 * 	public
		 */
		override public function resize(width:int, height:int):void {
			
			bounds.width	= width;
			bounds.height	= height;
			
			hitarea.width	= width;
			hitarea.height	= height;
			
			super.resize(width, height);
			
			// resize
			
		}
		
		/**
		 * 	@private
		 */
		private function handleScrub(event:MouseEvent):void {
			
			event.stopPropagation();
			
			switch (event.type) {
				case MouseEvent.MOUSE_DOWN:
					
					AppStage.addEventListener(MouseEvent.MOUSE_MOVE,	handleScrub);
					AppStage.addEventListener(MouseEvent.MOUSE_UP,		handleScrub);
					
					prev				= layer.getParameterValue('playDirection');
					
					layer.setParameterValue('playDirection', 0);
					info.actualTime	= Math.min(Math.max(mouseX / bounds.width, info.playStart), info.playEnd) * info.totalTime;
					
					break;
				case MouseEvent.MOUSE_MOVE:
					
					info.actualTime	= Math.min(Math.max(mouseX / bounds.width, info.playStart), info.playEnd) * info.totalTime;
					layer.setParameterValue('playDirection', 0);
					
					break;
				case MouseEvent.MOUSE_UP:
					
					
					layer.setParameterValue('playDirection', prev);
					AppStage.removeEventListener(MouseEvent.MOUSE_MOVE,	handleScrub);
					AppStage.removeEventListener(MouseEvent.MOUSE_UP,	handleScrub);
					
					break;
			}
		}
		
		/**
		 * 	@private
		 */
		private function handleMouse(event:MouseEvent):void {
			
			event.stopPropagation();
			
			switch (event.type) {
				case MouseEvent.MOUSE_DOWN:
					
					drag	= event.currentTarget as DisplayObject;
					
					AppStage.addEventListener(MouseEvent.MOUSE_MOVE,	handleMouse);
					AppStage.addEventListener(MouseEvent.MOUSE_UP,		handleMouse);
					
					break;
				case MouseEvent.MOUSE_MOVE:
					
					switch (drag) {
						case loopStart:
							drag.x	= Math.max(Math.min(mouseX, loopEnd.x), 0);
							layer.setParameterValue('playStart', drag.x / bounds.width);
							break;
						case loopEnd:
							drag.x	= Math.max(Math.min(mouseX, bounds.width), loopStart.x);
							layer.setParameterValue('playEnd', drag.x / bounds.width);
							break;
					}
					
					break;
				case MouseEvent.MOUSE_UP:
					
					AppStage.removeEventListener(MouseEvent.MOUSE_MOVE,	handleMouse);
					AppStage.removeEventListener(MouseEvent.MOUSE_UP,	handleMouse);
					
					break;
			}
			
		}
		
		/**
		 * 	@public
		 */
		public function attach(layer:IDisplayLayer):void {
			
			this.layer	= layer;
			this.info	= layer.getTimeInfo();
			
			this.layer.getParameter('playStart').listen(updateStart, true);
			this.layer.getParameter('playEnd').listen(updateEnd,	true);
			
			updateStart();
			updateEnd();
		}
		
		/**
		 * 	@private
		 */
		private function updateStart(event:ParameterEvent = null):void {
			loopStart.x	= info.playStart * bounds.width;
		}
		
		/**
		 * 	@private
		 */
		private function updateEnd(event:ParameterEvent = null):void {
			loopEnd.x	= info.playEnd * bounds.width;
		}
		
		/**
		 * 	@public
		 */
		public function setEnabled(value:Boolean):void {
			
			if (value) {
				addEventListener(Event.ENTER_FRAME, handleFrame);	
			} else {
				removeEventListener(Event.ENTER_FRAME, handleFrame);
			}
			
		}

		/**
		 * 	@private
		 */
		private function handleFrame(event:Event):void {
			
			skin.x	= Math.min(Math.max(layer.time, 0),1) * bounds.width;

		}
		
		/**
		 * 	@public
		 */
		override public function dispose():void {
			
			// remove listeners
			loopStart.removeEventListener(MouseEvent.MOUSE_DOWN,	handleMouse);
			loopEnd.removeEventListener(MouseEvent.MOUSE_DOWN,		handleMouse);
			hitarea.removeEventListener(MouseEvent.MOUSE_DOWN,		handleScrub);
			
			layer.getParameter('playStart').listen(updateStart, false);
			layer.getParameter('playEnd').listen(updateEnd, false);
			
			
			// remove
			removeEventListener(Event.ENTER_FRAME, handleFrame);
			
			// dispose
			super.dispose();
		}
	}
}