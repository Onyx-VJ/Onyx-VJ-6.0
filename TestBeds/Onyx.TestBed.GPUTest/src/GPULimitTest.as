package {
	
	import flash.display.*;
	import flash.display3D.*;
	import flash.display3D.textures.*;
	import flash.events.Event;
	
	final public class GPULimitTest extends Sprite {
		
		private var context:Context3D;
		private var totalMemory:uint	= 350 * 1048576;
		private var allowedMemory:uint	= totalMemory;
		private var textures:int;
		
		/**
		 * 	@public
		 */
		public function GPULimitTest():void {
			
			stage.stage3Ds[0].addEventListener(Event.CONTEXT3D_CREATE, handleContext);
			stage.stage3Ds[0].requestContext3D();
			
			stage.nativeWindow.activate();
			
		}
		
		/**
		 * 	@private
		 */
		private function handleContext(e:Event):void {
			
			context = stage.stage3Ds[0].context3D;
			context.configureBackBuffer(1024, 1024, 0, false);
			
			var texture:Texture;
			while (texture = requestTexture(512, 512)) {
				++textures;
			}
			
			trace(textures, allowedMemory, totalMemory, totalMemory - allowedMemory, textures * (512 * 512* 4));
			
		}
		
		private function requestTexture(width:int, height:int):Texture {
			var requested:uint = width * height * 4;
			if (allowedMemory - requested > 0) {
				allowedMemory -= requested;
				try {
					return context.createTexture(width, height, Context3DTextureFormat.BGRA, false);
				} catch (e:Error) {
					trace(e);
					return null;
				}
			}
			return null;
		}
	}
}