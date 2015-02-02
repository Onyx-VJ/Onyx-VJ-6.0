package onyx.display.gpu {
	
	import flash.display.BitmapData;
	import flash.display3D.textures.*;
	
	import onyx.core.*;
	import onyx.display.Dimensions;

	final public class DisplayTexture implements DisplayTexture {
		
		/**
		 * 	@public
		 */
		public var fbo:Boolean;
		
		/**
		 * 	@internal
		 */
		internal const size:Dimensions	= new Dimensions();
		
		/**
		 * 	@internal
		 */
		internal var texture:Texture;
		
		/**
		 * 	@public
		 */
		CONFIG::DEBUG private var debugInfo:String;
		
		/**
		 * 	@public
		 */
		public function DisplayTexture(width:int, height:int, fbo:Boolean):void {
			
			size.width		= width;
			size.height		= height;
			this.fbo		= fbo;

		}
		
		public function get width():int {
			return size.width;
		}
		
		public function get height():int {
			return size.height;
		}

		/**
		 * 	@public
		 */
		public function upload(surface:DisplaySurface):void {
			texture.uploadFromBitmapData(surface.nativeSurface);
		}
		
		/**
		 * 	@public
		 */
		CONFIG::DEBUG public function setDebugInfo(data:String):void { 
			debugInfo = data;
		}
		
		/**
		 * 	@public
		 */
		public function get nativeTexture():Texture {
			return texture;
		}
		
		/**
		 * 	@public
		 */
		public function dispose():void {}
		
		/**
		 * 	@public
		 */
		CONFIG::DEBUG public function toString():String {
			return debugInfo ? '[Texture ' + debugInfo + ']' : '[Texture]';
		}

	}
}