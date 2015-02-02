package {
	
	import flash.display.*;
	import flash.display3D.*;
	import flash.display3D.textures.*;
	import flash.events.*;
	import flash.geom.Rectangle;
	import flash.text.*;
	import flash.utils.*;
	
	[SWF(frameRate='30', backgroundColor='0x000000')]
	final public class SlowContext3DTest extends Sprite {
		
		/**
		 * 	@private
		 */
		private static const USE_SCREEN:int				= 0;
		
		/**
		 * 	@private
		 */
		private static const BUFFER_SWAPS_PER_FRAME:int	= 250;
		
		/**
		 * 	@private
		 */
		private var context:Context3D;
		private var vBuffer:VertexBuffer3D;
		private var iBuffer:IndexBuffer3D;
		
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
		private const fps:TextField	= new TextField();
		
		/**
		 * 	@private
		 */
		private const buffers:Vector.<Texture>	= new Vector.<Texture>(2, true);
		
		private var textureWidth:int			= 1024;
		private var textureHeight:int			= 1024;
		
		/**
		 * 	@public
		 */
		public function SlowContext3DTest():void {
			
			stage.align					= StageAlign.TOP_LEFT;
			stage.scaleMode				= StageScaleMode.NO_SCALE;
			stage.quality				= StageQuality.LOW;
			
			var target:Rectangle		= Screen.screens[0].bounds;
			target = target.union(Screen.screens[1].bounds);
			
			trace(target);
			
			// bug is here.  Framerate on Screen.screens[0] (mainscreen) = 60 fps
			stage.nativeWindow.bounds	= target;
			
			// stage.nativeWindow.bounds	= Screen.screens[0].bounds;		// RUNS AT 60 FPS
			// stage.nativeWindow.bounds	= Screen.screens[1].bounds;		// RUNS AT 8 FPS

			stage.nativeWindow.activate();
			
			stage.stage3Ds[0].addEventListener(Event.CONTEXT3D_CREATE, handleContext);
			stage.stage3Ds[0].requestContext3D();
			
			time 					= getTimer();
			fps.defaultTextFormat	= new TextFormat(null, 100, 0xFF0000);
			fps.width				= 500;
			fps.selectable			= false;
			addChild(fps);
			
			stage.addEventListener(Event.ENTER_FRAME, handleRender);
			stage.addEventListener(Event.ENTER_FRAME, handleFPS);
			
		}
		
		private function handleFPS(e:Event):void {
			var elapsed:int = getTimer() - time;
			++frames;
			if (elapsed > 1000) {
				
				fps.text	= (frames * (elapsed / 1000)).toFixed(2);
				time		= getTimer();
				frames		= 0;
			}
		}
		
		/**
		 * 	@private
		 */
		private function handleContext(e:Event):void {
			
			stage.stage3Ds[0].x	= Screen.mainScreen.bounds.width;
			
			context = stage.stage3Ds[0].context3D;
			context.configureBackBuffer(textureWidth, textureHeight, 0, false);
			//context.enableErrorChecking = true;
			context.clear(1,0,0,1);
			context.present();
			
			// create textures?
			buffers[0] = context.createTexture(textureWidth, textureHeight, Context3DTextureFormat.BGRA, true);
			buffers[1] = context.createTexture(textureWidth, textureHeight, Context3DTextureFormat.BGRA, true);
			
		}
		
		private function handleRender(e:Event):void {
			
			var start:int = getTimer();
			
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
			context.clear(Math.random());

			// draw(buffers[0]);
			// draw(imageTexture);
			
			context.present();
			
			trace(start, getTimer() - start);
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