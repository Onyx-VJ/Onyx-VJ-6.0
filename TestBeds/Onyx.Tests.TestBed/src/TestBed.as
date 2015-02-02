package {

	import flash.display.*;
	import flash.display3D.*;
	import flash.events.*;
	import flash.filesystem.*;
	import flash.media.Camera;
	import flash.media.Video;
	import flash.net.*;
	import flash.utils.*;
	
	import tests.*;
	
	[SWF(width='1280', height='960', backgroundColor='0x333333')]
	final public class TestBed extends Sprite {
		
		/**
		 * 	@private
		 */
		private var context:Context3D;
		private var temp:Object;
		
		/**
		 * 	@private
		 */
		// private const test:TestBase	= new BlendTest();
		
		/**
		 * 	@public
		 */
		public function TestBed():void {
			
			var cam:Camera	= Camera.getCamera();
			var vid:Video	= new Video(cam.width, cam.height);
			vid.attachCamera(cam);
			cam.addEventListener('videoFrame', trace);
			trace(describeType(cam));
			trace(describeType(Camera));
			addChild(vid);
			
			// activate
			stage.align	= StageAlign.TOP_LEFT;
			stage.scaleMode	= StageScaleMode.NO_SCALE;
			stage.nativeWindow.x = 0;
			stage.nativeWindow.y = 0;
			stage.nativeWindow.activate();
			
			// load assets
			// loadAssets(initialize);

		}
//		
//		/**
//		 * 	@private
//		 */
//		private function loadAssets(callback:Function):void {
//			
//			const queue:Array		= [];
//			const assets:Object		= test.getAssets();
//			const handler:Function	= function(obj:Object, content:Object):void {
//				
//				const key:String	= obj.key;
//				const file:File		= obj.file;
//				
//				const index:int = queue.indexOf(obj);
//				if (index >= 0) {
//					
//					queue.splice(index, 1);
//					assets[key]	= content;
//					
//					if (queue.length === 0) {
//						callback();
//					}
//				}
//			}
//
//			for (var i:String in assets) {
//				var file:File = File.applicationDirectory.resolvePath(assets[i]);
//				if (file.exists) {
//					queue.push({ key: i, file: file});
//				}
//			}
//			
//			for each (var obj:Object in queue.concat()) {
//				loadAsset(obj, handler);
//			}
//		}
//		
//		/**
//		 * 	@private
//		 */
//		private function loadAsset(obj:Object, callback:Function):void {
//			
//			const file:File			= obj.file;
//			
//			const key:String		= obj.key;
//			const bytes:ByteArray	= new ByteArray();
//			const stream:FileStream	= new FileStream();
//			stream.open(file, FileMode.READ);
//			stream.readBytes(bytes);
//			
//			switch (file.type) {
//				case '.swf':
//				case '.jpg':
//				case '.jpeg':
//				case '.png':
//					
//					const loader:Loader		= new Loader();
//					loader.contentLoaderInfo.addEventListener(Event.COMPLETE, function(e:Event):void {
//						loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, arguments.callee);
//						callback(obj, loader.content);
//						temp = null;
//					});
//					loader.loadBytes(bytes);
//					
//					this.temp = loader;
//					
//					break;
//				default:
//					
//					callback(obj, bytes.readUTFBytes(bytes.length));
//					
//					break;
//			}
//		}
//		
//		/**
//		 * 	@private
//		 */
//		private function initialize():void {
//			
//			const s:Stage3D	= stage.stage3Ds[0];
//			s.addEventListener('context3DCreate', handleContext);
//			s.requestContext3D();
//			
//		}
//		
//		/**
//		 * 	@private
//		 */
//		private function handleContext(event:Event):void {
//			
//			const s:Stage3D = event.currentTarget as Stage3D;
//			context = s.context3D;
//			context.enableErrorChecking	= true;
//			context.configureBackBuffer(stage.stageWidth, stage.stageHeight, 0);
//			
//			stage.addEventListener(Event.RESIZE, handleResize);
//			
//			test.setup(stage, context);
//		}
//		
//		/**
//		 * 	@private
//		 */
//		private function handleResize(e:Event):void {
//			
//			if (stage.stageWidth < 50 || stage.stageHeight < 50) {
//				return;
//			}
//			
//			context.configureBackBuffer(stage.stageWidth, stage.stageHeight, 0, false);
//			
//			test.resize();
//		}
	}
}