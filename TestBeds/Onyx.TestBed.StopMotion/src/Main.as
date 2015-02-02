package {

	import flash.display.*;
	import flash.events.*;
	import flash.filesystem.*;
	import flash.media.*;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.text.TextField;
	import flash.utils.ByteArray;
	
	import mode.*;
	
	import util.PNGEncoder;
	
	[SWF(width='1024', height='768', frameRate='60')]
	final public class Main extends Sprite {
		
		/**
		 * 	@private
		 */
		private const dir:File		= new File('d:\\bodie');
		
		/**
		 * 	@private
		 */
		public static const CAPTURE:CaptureMode		= new CaptureMode();
		
		/**
		 * 	@private
		 */
		public static const PEEK:PeekMode			= new PeekMode();
		
		/**
		 * 	@private
		 */
		public const frames:Array	= [];
		
		/**
		 * 	@private
		 */
		private var loader:Loader					= new Loader();
		private var queue:Array						= [];
		private var currentFile:File;
		
		/**
		 * 	@private
		 */
		private var currentMode:Mode;
		
		/**
		 * 	@private
		 */
		private var status:TextField;
		
		/**
		 * 	@public
		 */
		public function Main():void {
			
			// defaults
			stage.scaleMode		= StageScaleMode.NO_SCALE;
			stage.align			= StageAlign.TOP_LEFT;
			stage.displayState	= StageDisplayState.FULL_SCREEN_INTERACTIVE;
			stage.addEventListener(KeyboardEvent.KEY_DOWN, handleKey);
			stage.addEventListener(KeyboardEvent.KEY_UP, handleKey);
			stage.nativeWindow.activate();
			
			// init
			init();
			
		}
		
		/**
		 * 	@private
		 */
		private function scanDir():void {
			
			if (!dir.exists) {
				dir.createDirectory();
			}
			
			const files:Array		= dir.getDirectoryListing();
			for each (var file:File in files) {
				if (file.type === '.png') {
					queue.push(file);
				}
			}
			
			queueNext();
		}
		
		private function queueNext():void {
			
			currentFile = queue.shift();
			if (!currentFile) {
				return start();
			}
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, handleFile);
			loader.load(new URLRequest(currentFile.nativePath));
		}
		
		private function handleFile(e:Event):void {
			
			const info:LoaderInfo	= e.currentTarget as LoaderInfo;
			info.removeEventListener(Event.COMPLETE, handleFile);
			frames.push((info.content as Bitmap).bitmapData);
			
			trace('loading image ', frames.length - 1);
			
			queueNext();
		}
		
		private function start():void {
			
			CAPTURE.init(this);
			PEEK.init(this);
			
			// capture
			setMode(CAPTURE);
		}
		
		/**
		 * 	@public
		 */
		public function save(data:BitmapData):void {
			
			var name:String 	= pad(frames.push(data) - 1, 8) + '.png';
			trace('saving ' + name);
			var bytes:ByteArray	= PNGEncoder.encode(data);
			
			
			const stream:FileStream	= new FileStream();
			stream.open(dir.resolvePath(name), FileMode.WRITE);
			stream.writeBytes(bytes);
			stream.close();
			
		}
		
		private function pad(value:int, chars:int):String {
			var str:String = value.toString();
			while (str.length < chars) {
				str = '0' + str;
			}
			return str;
		}
		
		/**
		 * 	@private
		 */
		private function init():void {
			
			// scan
			scanDir();

		}
		
		/**
		 * 	@private
		 */
		public function setMode(mode:Mode):void {
			
			if (currentMode) {
				currentMode.hide();
			}
			
			currentMode = mode;
			currentMode.show();
		}
		
		/**
		 * 	@private
		 */
		private function handleKey(e:KeyboardEvent):void {
			if (currentMode) {
				currentMode.handleKey(e);
			}
		}
	}
}