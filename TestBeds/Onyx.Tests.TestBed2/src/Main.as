package {
	
	import flash.display.*;
	import flash.display3D.*;
	import flash.events.*;
	
	import onyx.display.*;
	import onyx.tests.*;
	import onyx.util.*;
	
	[SWF(width='1280', height='768', backgroundColor='0x000000')]
	final public class Main extends Sprite {
		
		/**
		 * 	@private
		 */
		private var context:ContextGL;
		
		/**
		 * 	@private
		 */
		private var test:TestBaseGL;
		
		/**
		 * 	@public
		 */
		public function Main():void {

			// activate
			stage.align				= StageAlign.TOP_LEFT;
			stage.scaleMode			= StageScaleMode.NO_SCALE;
			stage.nativeWindow.x	= Screen.mainScreen.bounds.width / 2 - 512;
			stage.nativeWindow.y	= Screen.mainScreen.bounds.height / 2 - 384;
			stage.nativeWindow.activate();
			
			test					= new BlendTest();
			
			// initialize
			initialize();
			
			// closing?
			stage.nativeWindow.addEventListener(Event.CLOSING, handler);
			
		}
		
		/**
		 * 	@private
		 */
		private function initialize():void {
			
			AssetManager.loadAssets(test.getAssets(), function(... args:Array):void {
				
				AssetManager.loadAssets({
					'Render.Direct':	'render/Onyx.RenderGL.Direct.onx',
					'Render.Transform':	'render/Onyx.RenderGL.Transform.onx'
				}, initializeComplete);
				
			});
			
		}
		
		/**
		 * 	@private
		 */
		private function initializeComplete(assets:Object):void {

			// set up the context
			test.setup(stage, context = new ContextGL(stage, assets));

			// stage
			stage.addEventListener(Event.ENTER_FRAME, handler);
			
		}
		
		/**
		 * 	@private
		 */
		private function handler(event:Event):void {
			
			switch (event.type) {
				case Event.ENTER_FRAME:
					
					// render
					try {
						test.render();
					} catch (e:Error) { trace(e.message); }
					
					break;
				case Event.CLOSING:
					
					stage.removeEventListener(Event.ENTER_FRAME, handler);
					
					break;
			}
		}
	}
}