package mode {
	
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.media.*;
	import flash.ui.*;
	
	final public class CaptureMode extends Mode {
		
		/**
		 * 	@private
		 */
		private var video:Video;
		
		/**
		 * 	@private
		 */
		private var camera:Camera;
		
		/**
		 * 	@private
		 */
		private var preview:Bitmap;
		
		/**
		 * 	@public
		 */
		override public function init(app:Main):void {
			
			// init
			super.init(app);
			
			// info
			camera = Camera.getCamera('1');
			camera.setMode(1920,1080,24);
			video	= new Video(stage.stageWidth, stage.stageHeight);
			video.attachCamera(camera);
			video.width 	= stage.stageWidth;
			video.height	= stage.stageHeight;
			video.smoothing	= true;
			
			preview = new Bitmap();
			preview.alpha	= 0.3;

		}
		
		/**
		 * 	@public
		 */
		override public function show():void {
			stage.addChildAt(video, 0);
		}
		
		override public function hide():void {
			stage.removeChild(video);
		}

		/**
		 * 	@public
		 */
		override public function handleKey(e:KeyboardEvent):void {
			
			switch (e.type) {
				case KeyboardEvent.KEY_DOWN:
					
					switch (e.keyCode) {
						case Keyboard.Z:
							
							var frame:BitmapData	= app.frames[app.frames.length - 1];
							if (frame) {
								preview.bitmapData	= frame;
							}
							stage.addChild(preview);
							
							break;
						case Keyboard.SPACE:
							
							Main.PEEK.setFrame(app.frames.length - 1);
							
							return app.setMode(Main.PEEK);
					}
					
					break;
				
				case KeyboardEvent.KEY_UP:
					switch (e.keyCode) {
						case 188:	// left;
							
							Main.PEEK.setFrame(Main.PEEK.currentFrame - 1);
							
							return app.setMode(Main.PEEK);
						case 190:	// right;
							
							Main.PEEK.setFrame(Main.PEEK.currentFrame + 1);
							
							return app.setMode(Main.PEEK);
						case Keyboard.Z:
							
							if (stage.contains(preview)) {
								stage.removeChild(preview);
							}
							
							break;
						case Keyboard.ENTER:
							
							const bmp:BitmapData	= new BitmapData(video.width, video.height, false, 0);
							bmp.draw(video, new Matrix(video.width / video.videoWidth, 0, 0, video.height / video.videoHeight));
							
							// save
							app.save(bmp);

							break;
					}
					
					break;
			}
		}
	}
}