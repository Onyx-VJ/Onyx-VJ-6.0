package onyx.ui.core {
	
	import flash.display.*;
	import flash.events.Event;
	
	[UIConstraint(
		top		= '8',
		bottom	= '8',
		right	= '8',
		left	= '8'
	)]
	
	final public class UIObjectStage extends UIObject {
		
		private var minWidth:int		= 500;
		private var minHeight:int		= 375;
		
		/**
		 * 	@public
		 */
		override public function initialize(data:Object):void {

			stage.addEventListener(Event.RESIZE, resize);
			resize();

		}
		
		private function resize(e:* = null):void {
			arrange(constraint.measure(new UIObjectBounds(0, 0, Math.max(stage.stageWidth, minWidth), Math.max(stage.stageHeight, minHeight))));
		}
	}
}