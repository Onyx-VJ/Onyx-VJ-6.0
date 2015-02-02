package
{
	import flash.display.*;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.net.*;
	import flash.system.JPEGLoaderContext;
	import flash.system.LoaderContext;
	
	[SWF(width='1280', height='720', frameRate='30')]
	public class LargeSWFMovieTest extends Sprite {
		
		private const layers:Vector.<String>	= Vector.<String>([
			BlendMode.NORMAL,
			BlendMode.DARKEN,
			BlendMode.HARDLIGHT,
			BlendMode.MULTIPLY,
			BlendMode.SCREEN,
			
			BlendMode.DARKEN,
			BlendMode.HARDLIGHT,
			BlendMode.MULTIPLY,
			BlendMode.SCREEN,
			
			BlendMode.DARKEN,
			BlendMode.HARDLIGHT,
			BlendMode.MULTIPLY,
			BlendMode.SCREEN
		]);
		private var loader:Loader;
		private var data:BitmapData				= new BitmapData(1280, 720, true, 0);
		private var content:MovieClip;
		private var preview:NativeWindow;
		
		public function LargeSWFMovieTest() {
			init();
			
		}
		
		private function init():void {
			
			var opt:NativeWindowInitOptions = new NativeWindowInitOptions();
			opt.renderMode					= 'direct';
			
			preview = new NativeWindow(opt);
			preview.bounds	= Screen.screens[1].bounds;
			preview.stage.scaleMode = StageScaleMode.NO_SCALE;
			preview.stage.align		= StageAlign.TOP_LEFT;
			preview.stage.addChild(new Bitmap(data));
			preview.stage.displayState = StageDisplayState.FULL_SCREEN;
			preview.stage.fullScreenSourceRect = new Rectangle(0,0,1280,720);
			preview.activate();
			
			var context:JPEGLoaderContext	= new JPEGLoaderContext();
			loader = new Loader();
			loader.load(new URLRequest('loaded.swf'), context);
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, handleComplete);
			
			stage.nativeWindow.activate();
			
		}
		
		private function handleComplete(e:Event):void {
			
			content = loader.content as MovieClip;
			addEventListener(Event.ENTER_FRAME, handleFrame);
		}
		
		private function handleFrame(e:Event):void {
			
			data.lock();
			data.fillRect(data.rect, 0);
			
			for each (var blend:String in layers) {
				content.gotoAndStop(int(content.totalFrames * Math.random()) + 1);
				data.draw(content, new Matrix(Math.random() * 2 + 1, 0, 0, Math.random() * 2 + 1, Math.random() * -640), null, blend, null, true);
			}
			
			data.unlock();
		}
	}
}