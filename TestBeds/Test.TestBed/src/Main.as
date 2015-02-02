package
{
	import flash.display.*;
	import flash.events.*;
	import flash.filters.*;
	import flash.geom.*;
	import flash.text.TextField;
	import flash.utils.*;
	
	import spark.primitives.Rect;
	
	[SWF(width='1024', height='768', frameRate='24')]
	public final class Main extends Sprite {
		
		/**
		 * 	@private
		 */
		private var data:BitmapData		= new BitmapData(640, 480, true, 0);
		
		/**
		 * 	@private
		 */
		private var data1:BitmapData	= new BitmapData(640, 480, true, 0);
		private const rect:Rectangle	= new Rectangle(0,0,640,480);
		
		private var filter:ColorMatrixFilter	= new ColorMatrixFilter([
			1, 0, 0, 0,
			0, 1, 0, 0,
			0.33, 0.33, 0.33, 0,
			0, 0, 0, 1,
		]);
		private var text:TextField			= new TextField();
		private const tests:Vector.<String>	= Vector.<String>([
			'test1', 'test2'
		]);
		private var current:int				= -1;
		
		/**
		 * 	@public
		 */
		public function Main():void {

			text.width	= stage.stageWidth;
			text.height = stage.stageHeight;
			text.mouseEnabled	= false;
			stage.addChild(text);
			stage.nativeWindow.activate();
			
			stage.addEventListener(MouseEvent.CLICK, handleClick);
			
			
		}
		
		private function handleClick(event:Event):void {
			
			current				= ++current % tests.length;
			var start:int		= getTimer();
			var name:String		= tests[current];
			var iterations:int	= 10000;
			var fn:Function		= this[name];
			
			fn(iterations);
			
			text.appendText(name + ':' + (getTimer() - start) + '\n');
		}
		
		/**
		 * 	@private
		 */
		private function test1(iterations:int):void {
			var point:Point	= new Point();
			while (--iterations) {
				data.applyFilter(data, rect, point, filter);
			}
		}
		
		/**
		 * 	@private
		 */
		private function test2(iterations:int):void {
			var point:Point	= new Point();
			data.lock();
			while (--iterations) {
				data.applyFilter(data, rect, point, filter);
			}
			data.unlock();
		}
	}
}