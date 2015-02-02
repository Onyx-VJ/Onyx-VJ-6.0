package
{
	import avmplus.*;
	
	import core.TestRunner;
	
	import flash.display.*;
	import flash.events.TimerEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.ui.*;
	import flash.utils.*;
	
	import tests.*;
	
	[SWF(width='1024', height='768', frameRate='30', backgroundColor='0x000000')]
	
	final public class TestTime extends Sprite {
		
		private const text:TextField		= addChild(new TextField()) as TextField;
		private const agg:TextField			= addChild(new TextField()) as TextField;
		private const timer:Timer			= new Timer(500, 1);
		private const testsToRun:Array		= [];
		private var currentIteration:int;
		
		private static const TEST:String	= 'abc';
		
		public function TestTime():void {
			
			agg.defaultTextFormat	= text.defaultTextFormat	= new TextFormat('Courier New');
			agg.textColor			= text.textColor	= 0xFFFFFF;
			text.width		= stage.stageWidth;
			text.height		= stage.stageHeight;
			
			agg.width		= 250;
			agg.height		= 250;
			agg.x			= stage.stageWidth - 250;
			
			stage.align		= StageAlign.TOP_LEFT;
			stage.scaleMode	= StageScaleMode.NO_SCALE;
			stage.nativeWindow.activate();
			
			timer.addEventListener(TimerEvent.TIMER_COMPLETE, handleTimer);
			
			testsToRun.push.apply(null, LexTests.getTests());
			//testsToRun.push.apply(null, DescribeTypeTests.getTests());
			
			handleTimer(null);
			
			
			doStuff();
		}
		
		private function doStuff():void {
			
			var str:String = '';
			
			str = TestTime.TEST;
			str = TEST;
			str = BMPTests.TEST;
			str = GPU::TEXTURE_BGRA;
			
		}
		
		/**
		 * 	@private
		 */
		private function handleTimer(e:*):void {
			
			output('------------------------------------');
			var current:Array = testsToRun.concat();
			current.sort(function(...args:Array):int {
				return Math.random() * 2 -1;
			});
			
			for each (var test:TestRunner in current) {
				runTest(test)
			}
			
			if (++currentIteration > 4) {

				agg.text = '';
				for each (test in testsToRun) {
					
					var avg:Array = test.tested.concat();
					avg.sort();
					avg.shift();
					avg.pop();
					
					var total:Number	= 0;
					for each (var i:int in avg) {
						total += i;
					}
					agg.appendText(test.name + ': \t' + (total / avg.length).toFixed(8) + '\n');
				}
			}
			
			// restart the timer
			timer.start();
		}
		
		private function output(... args:Array):void {
			text.appendText(args.join(' ') + '\n');
			text.scrollV = text.maxScrollV;
		}
		
		/**
		 * 	@private
		 */
		private function runTest(test:TestRunner):void {
			var i:int			= test.iterations;
			var start:int		= getTimer();
			var method:Function	= test.method;
			var args:Array		= test.args;
			
			if (args) {
				while (--i) {
					method.apply(null, args);
				}
			} else {
				while (--i) {
					method();
				}
			}
			
			var time:int = (getTimer() - start);
			test.tested.push(time);
			
			output(
				test.name + '\t',
				time.toString() + 'ms\t',
				(time / test.iterations).toFixed(8)
			);
		}
	}
}