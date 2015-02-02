package
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.TextField;
	import flash.utils.getTimer;
	
	[SWF(width='1024', height='768', frameRate='30', backgroundColor='0x000000')]
	final public class Main extends Sprite {
		
		private static const ITERATIONS:int	= 1000000;
		private const text:TextField	= addChild(new TextField()) as TextField;
		
		public function Main():void {
			
			text.textColor	= 0xFFFFFF;
			text.width		= stage.stageWidth;
			text.height		= stage.stageHeight;

			stage.nativeWindow.activate();
			
			output('Array:', runTest(ITERATIONS, arrayArgs));
			output('Event:', runTest(ITERATIONS, eventArgs));
			output('Object:', runTest(ITERATIONS, objArgs));
			output('Object:', runTest(ITERATIONS, objArgs));
			output('Event:', runTest(ITERATIONS, eventArgs));
			output('Array:', runTest(ITERATIONS, arrayArgs));
			
		}
		
		private function output(... args:Array):void {
			text.appendText(args.join(' ') + '\n');
		}
		
		/**
		 * 	@private
		 */
		private function runTest(iterations:int, method:Function):String {
			var i:int		= iterations;
			var start:int	= getTimer();
			while (--i) {
				method(null);
			}
			return ((getTimer() - start) / iterations).toString();
		}
		
		/**
		 * 	@private
		 */
		private function arrayArgs(... args:Array):void {}
		
		/**
		 * 	@private
		 */
		private function objArgs(arg:Object = null):void {}
		
		/**
		 * 	@private
		 */
		private function eventArgs(e:Event = null):void {}
	}
}