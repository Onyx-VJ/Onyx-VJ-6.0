package onyx.ui.window.layer {
	
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	
	import onyx.core.*;
	import onyx.display.*;
	import onyx.event.*;
	import onyx.ui.component.UISkin;
	import onyx.ui.core.*;
	import onyx.ui.event.*;
	import onyx.ui.parameter.*;
	
	use namespace parameter;
	use namespace skinPart;
	
	
	[UIComponent(id='layerScrub')]
	
	[UISkinPart(id='playHead',	type='skin', skinClass='PlaybackControl',	constraint='relative', top='0', left='0', right='0', bottom='0')]
	[UISkinPart(id='hitarea',	type='skin', skinClass='PlaybackArea')]
	[UISkinPart(id='loopStart', type='skin', skinClass='PlaybackLoopStart', constraint='relative', top='0', left='0', right='0', bottom='0')]
	[UISkinPart(id='loopEnd',	type='skin', skinClass='PlaybackLoopEnd')]

	public final class UILayerScrub extends UIObject {
		
		skinPart var playHead:UISkin;
		skinPart var hitarea:UISkin;
		skinPart var loopStart:UISkin;
		skinPart var loopEnd:UISkin;
		
		private const bounds:UIRect			= new UIRect();
		
		private var layer:IDisplayLayer;
		private var info:LayerTime;
		private var prev:Number;
		private var drag:DisplayObject;
		
		/**
		 * 	@public
		 */
		override public function initialize(data:Object):void {
			
			super.initialize(data);
			
			loopStart.addEventListener(MouseEvent.MOUSE_DOWN,	handleMouse);
			loopEnd.addEventListener(MouseEvent.MOUSE_DOWN,		handleMouse);
			hitarea.addEventListener(MouseEvent.MOUSE_DOWN,		handleScrub);
			hitarea.addEventListener(MouseEvent.RIGHT_CLICK,	handleScrub);
			hitarea.useHandCursor = hitarea.buttonMode = true;
			
		}
		
		/**
		 * 	public
		 */
		override public function arrange(rect:UIRect):void {
			
			super.arrange(rect);
			
			playHead.y		= 10;
			
			bounds.width	= rect.width;
			bounds.height	= rect.height;
			
			hitarea.width	= rect.width;
			hitarea.height	= 9;
			
			updateStart();
			updateEnd();
		}
		
		/**
		 * 	@private
		 */
		private function handleScrub(event:MouseEvent):void {
			
			event.stopPropagation();
			
			switch (event.type) {
				case MouseEvent.RIGHT_CLICK:
					
					layer.setParameterValue('playStart', 0);
					layer.setParameterValue('playEnd', 1);
					
					break;
				case MouseEvent.MOUSE_DOWN:
					
					// ctrl moves playhead/loop/end
					stage.addEventListener(MouseEvent.MOUSE_MOVE,	handleScrub);
					stage.addEventListener(MouseEvent.MOUSE_UP,		handleScrub);
					stage.addEventListener(MouseEvent.MOUSE_OVER,	handleScrub);
					stage.addEventListener(MouseEvent.MOUSE_OUT,	handleScrub);
					stage.addEventListener(MouseEvent.ROLL_OVER,	handleScrub);
					stage.addEventListener(MouseEvent.ROLL_OUT,		handleScrub);
					
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
					stage.removeEventListener(MouseEvent.MOUSE_MOVE,	handleScrub);
					stage.removeEventListener(MouseEvent.MOUSE_UP,		handleScrub);
					stage.removeEventListener(MouseEvent.MOUSE_OVER,	handleScrub);
					stage.removeEventListener(MouseEvent.MOUSE_OUT,		handleScrub);
					stage.removeEventListener(MouseEvent.ROLL_OVER,		handleScrub);
					stage.removeEventListener(MouseEvent.ROLL_OUT,		handleScrub);
					
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
					
					stage.addEventListener(MouseEvent.MOUSE_MOVE,	handleMouse);
					stage.addEventListener(MouseEvent.MOUSE_UP,		handleMouse);
					
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
					
					stage.removeEventListener(MouseEvent.MOUSE_MOVE,	handleMouse);
					stage.removeEventListener(MouseEvent.MOUSE_UP,	handleMouse);
					
					break;
			}
			
		}
		
		/**
		 * 	@public
		 */
		public function attach(layer:IDisplayLayer):void {
			
			this.layer	= layer;
			this.info	= layer.getTimeInfo();
			
			this.layer.getParameter('playStart').addEventListener(ParameterEvent.VALUE_CHANGE, updateStart);
			this.layer.getParameter('playEnd').addEventListener(ParameterEvent.VALUE_CHANGE, updateEnd);
			
			addEventListener(Event.ENTER_FRAME, handleFrame);
			
			updateStart();
			updateEnd();
		}
		
		/**
		 * 	@private
		 */
		private function updateStart(event:ParameterEvent = null):void {
			loopStart.x	= info.playStart * bounds.width;
			
			hitarea.x		= loopStart.x;
			hitarea.width	= int(loopEnd.x - hitarea.x + 1);
			
		}
		
		/**
		 * 	@private
		 */
		private function updateEnd(event:ParameterEvent = null):void {
			loopEnd.x	= info.playEnd * bounds.width;
			
			hitarea.x		= loopStart.x;
			hitarea.width	= int(loopEnd.x - hitarea.x + 1);

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
			
			playHead.x	= Math.min(Math.max(layer.time, 0),1) * bounds.width;

		}
		
		/**
		 * 	@public
		 */
		override public function dispose():void {
			
			// remove listeners
			loopStart.removeEventListener(MouseEvent.MOUSE_DOWN,	handleMouse);
			loopEnd.removeEventListener(MouseEvent.MOUSE_DOWN,		handleMouse);
			hitarea.removeEventListener(MouseEvent.MOUSE_DOWN,		handleScrub);
			
			layer.getParameter('playStart').removeEventListener(ParameterEvent.VALUE_CHANGE, updateStart);
			layer.getParameter('playEnd').removeEventListener(ParameterEvent.VALUE_CHANGE, updateEnd);
			
			
			// remove
			removeEventListener(Event.ENTER_FRAME, handleFrame);
			
			// dispose
			super.dispose();
		}
	}
}