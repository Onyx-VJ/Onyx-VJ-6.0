package {
	
	import flash.display.*;
	import flash.display3D.*;
	import flash.display3D.textures.*;
	import flash.events.*;
	import flash.geom.Rectangle;
	import flash.text.*;
	import flash.utils.*;
	
	final public class SlowContext3DBase {
		
		/**
		 * 	@private
		 */
		private static const BUFFER_SWAPS_PER_FRAME:int	= 250;
		
		/**
		 * 	@private
		 */
		private var stage:Stage;
		
		/**
		 * 	@private
		 */
		private static const USE_SCREEN:int				= 1;
		
		/**
		 * 	@private
		 */
		private var context:Context3D;
		
		/**
		 * 	@private
		 */
		private var frames:int;
		
		/**
		 * 	@private
		 */
		private var time:int
		
		/**
		 * 	@private
		 */
		private const buffers:Vector.<Texture>	= new Vector.<Texture>(2, true);
		
		private var textureWidth:int			= 512;
		private var textureHeight:int			= 512;
		
		/**
		 * 	@public
		 */
		public function initialize(window:NativeWindow):void {
			
			stage						= window.stage;
			stage.align					= StageAlign.TOP_LEFT;
			stage.scaleMode				= StageScaleMode.NO_SCALE;
			stage.quality				= StageQuality.LOW;
			
			// bug is here.  Framerate on Screen.screens[0] (mainscreen) = 60 fps
			var target:Rectangle		= Screen.screens[1].bounds;
			stage.nativeWindow.bounds	= new Rectangle(target.width - 512, target.height - 512, 512, 512);
			
			// stage.nativeWindow.bounds	= Screen.screens[0].bounds;		// RUNS AT 60 FPS
			// stage.nativeWindow.bounds	= Screen.screens[1].bounds;		// RUNS AT 8 FPS
			
			stage.nativeWindow.activate();
			
			stage.stage3Ds[0].addEventListener(Event.CONTEXT3D_CREATE, handleContext);
			stage.stage3Ds[0].requestContext3D();
			
			//			time 					= getTimer();
			//			fps.defaultTextFormat	= new TextFormat(null, 100, 0xFF0000);
			//			fps.width				= 500;
			//			fps.selectable			= false;
			//			addChild(fps);
			
			stage.addEventListener(Event.ENTER_FRAME, handleRender);
			stage.addEventListener(Event.ENTER_FRAME, handleFPS);
			
		}
		
		private function handleFPS(e:Event):void {
			var elapsed:int = getTimer() - time;
			++frames;
			if (elapsed > 1000) {
				
				trace((frames * (elapsed / 1000)).toFixed(2));
				time		= getTimer();
				frames		= 0;
				
			}
		}
		
		/**
		 * 	@private
		 */
		private function handleContext(e:Event):void {
			
			context = stage.stage3Ds[0].context3D;
			context.configureBackBuffer(textureWidth, textureHeight, 0, false);
			trace(context.driverInfo);
			// context.enableErrorChecking = true;
			context.clear(1,0,0,1);
			context.present();
			
			buffers[0] = context.createTexture(textureWidth, textureHeight, Context3DTextureFormat.BGRA, true);
			buffers[1] = context.createTexture(textureWidth, textureHeight, Context3DTextureFormat.BGRA, true);
			
		}
		
		private function handleRender(e:Event):void {
			
			if (!context) return;
			
			try {
				
				context.setRenderToBackBuffer();
				context.clear();
				
			} catch (e:Error) {
				
				// error drawing to the context
				// return
				trace(e);
				
				return;
			}
			
			var count:int = BUFFER_SWAPS_PER_FRAME;
			bindBuffer();
			while (--count) {
				swapBuffer();
			}
			
			context.setRenderToBackBuffer();
			context.clear(Math.random() * 0.5);
			
			// draw(buffers[0]);
			// draw(imageTexture);
			
			context.present();
			
		}
		
		private function swapBuffer():void {
			
			var prev:Texture = buffers[0];
			buffers[0] = buffers[1];
			buffers[1] = prev;
			
			context.setRenderToTexture(buffers[1]);
			context.clear(0,0,0,0);
			
		}
		
		private function bindBuffer():void {
			
			context.setRenderToTexture(buffers[0]);
			context.clear(0,0,0,0);
			
		}
	}
}