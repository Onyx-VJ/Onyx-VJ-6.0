package {

	import flash.display.*;
	import flash.display3D.*;
	import flash.display3D.textures.*;
	import flash.events.Event;
	import flash.events.MouseEvent;

	[SWF(width='1024', height='1024', frameRate='60')]
	final public class GPUPerformance extends Sprite {
		
		private var context:Context3D;
		private var textures:Vector.<Texture>	= new Vector.<Texture>();
		private var data:BitmapData	= new BitmapData(1024, 1024, true, 0x00);
		private var stats:Stats;

		/**
		 * 	@public
		 */
		public function GPUPerformance():void {
			
			stage.align		= StageAlign.TOP_LEFT;
			stage.scaleMode	= StageScaleMode.NO_SCALE;
			stage.stage3Ds[0].addEventListener(Event.CONTEXT3D_CREATE, handleContext);
			stage.stage3Ds[0].requestContext3D();
			stage.nativeWindow.activate();
			
			addChild(stats = new Stats());
			
			stage.addEventListener(MouseEvent.MOUSE_DOWN, handleMouse);
		}
		
		/**
		 * 	@private
		 */
		private function handleMouse(e:MouseEvent):void {
			if (!context) {
				return;
			}
			
			textures.push(context.createTexture(data.width, data.height, Context3DTextureFormat.BGRA, false));
			
		}
		
		/**
		 * 	@private
		 */
		private function handleContext(e:Event):void {
			
			this.context		= stage.stage3Ds[0].context3D;
			context.configureBackBuffer(stage.stageWidth, stage.stageHeight, 0, false);
			addEventListener(Event.ENTER_FRAME, handleFrame);
		}
		
		/**
		 * 	@private
		 */
		private function handleFrame(e:Event):void {
			
			// data.fillRect(data.rect, Math.random() * 0xFFFFFF);
			
			// try
			for each (var texture:Texture in textures) {
				texture.uploadFromBitmapData(data);
			}
			
			context.clear();
			context.present();

		}
	}
}