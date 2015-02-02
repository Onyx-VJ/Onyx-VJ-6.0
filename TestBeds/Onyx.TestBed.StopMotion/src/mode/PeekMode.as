package mode {
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.*;
	import flash.filesystem.*;
	import flash.geom.Matrix;
	import flash.media.*;
	import flash.ui.*;
	
	final public class PeekMode extends Mode {

		/**
		 * 	@private
		 */
		private const preview:Bitmap	= new Bitmap();
		
		public var currentFrame:int		= 0;
		
		/**
		 * 	@public
		 */
		public function setFrame(frame:int):void {
			
			frame = frame % app.frames.length;
			if (frame < 0) {
				frame = app.frames.length + frame;
			}
			
			if (app.frames[frame]) {
				preview.bitmapData = app.frames[frame];
			}
			
			currentFrame = frame;
		}
		
		/**
		 * 	@public
		 */
		override public function show():void {
			stage.addChildAt(preview, 0);
			
			preview.width		= stage.stageWidth;
			preview.height		= stage.stageHeight;
		}
		
		/**
		 * 	@public
		 */
		override public function hide():void {
			if (stage.contains(preview)) {
				stage.removeChild(preview);
			}
		}
		
		/**
		 * 	@public
		 */
		override public function handleKey(e:KeyboardEvent):void {
			switch (e.type) {
				case KeyboardEvent.KEY_UP:
					
					switch (e.keyCode) {
						case 188:	// left;
							
							return setFrame(currentFrame - 1);
							
						case 190:	// right;
							
							return setFrame(currentFrame + 1);
						
						case Keyboard.SPACE:
							return app.setMode(Main.CAPTURE);
							
					}
					break;
			}
		}
	}
}