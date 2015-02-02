package {
	

	import flash.display.*;
	import flash.display3D.*;
	import flash.display3D.textures.*;
	import flash.events.*;
	import flash.geom.Rectangle;
	import flash.text.*;
	import flash.utils.*;
	
	[SWF(frameRate='60')]
	final public class SlowContext3DTestNewWindow extends Sprite {
		
		/**
		 * 	@private
		 */
		private static const USE_SCREEN:int				= 1;
		
		/**
		 * 	@private
		 */
		private static const BUFFER_SWAPS_PER_FRAME:int	= 100;
		
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
		
		private var textureWidth:int			= 512;
		private var textureHeight:int			= 512;
		private var window:NativeWindow;
		
		/**
		 * 	@public
		 */
		public function SlowContext3DTestNewWindow():void {
			
			const options:NativeWindowInitOptions	= new NativeWindowInitOptions();
			options.renderMode						= 'direct';
			
			window								= new NativeWindow(options);
			window.stage.align					= StageAlign.TOP_LEFT;
			window.stage.scaleMode				= StageScaleMode.NO_SCALE;
			
			// bug is here.  Framerate on Screen.screens[0] (mainscreen) = 60 fps
			window.stage.nativeWindow.bounds	= Screen.screens[USE_SCREEN].bounds;
			
			// stage.nativeWindow.bounds	= Screen.screens[0].bounds;		// RUNS AT 60 FPS
			// stage.nativeWindow.bounds	= Screen.screens[1].bounds;		// RUNS AT 8 FPS

			window.stage.nativeWindow.activate();
			
			window.stage.stage3Ds[0].addEventListener(Event.CONTEXT3D_CREATE, handleContext);
			window.stage.stage3Ds[0].requestContext3D();
			
			time 					= getTimer();
			fps.defaultTextFormat	= new TextFormat(null, 100, 0xFF0000);
			fps.width				= 500;
			fps.selectable			= false;
			window.stage.addChild(fps);
			
			window.stage.addEventListener(Event.ENTER_FRAME, handleRender);
			window.stage.addEventListener(Event.ENTER_FRAME, handleFPS);
			
			// close this window
			stage.nativeWindow.close();
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
			
			context = window.stage.stage3Ds[0].context3D;
			context.configureBackBuffer(textureWidth, textureHeight, 0, false);
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
			while (--count) {
				bindBuffer();
				swapBuffer();
			}

			context.setRenderToBackBuffer();
			context.clear();

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