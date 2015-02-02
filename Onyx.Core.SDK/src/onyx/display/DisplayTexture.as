package onyx.display {
	
	import flash.display.*;
	import flash.display3D.textures.*;
	
	import onyx.core.*;
	import onyx.display.*;
	
	final public class DisplayTexture {
		
		/**
		 * 	@public
		 */
		public var fbo:Boolean;
		
		/**
		 * 	@internal
		 */
		internal var internalTexture:Texture;
		
		/**
		 * 	@public
		 */
		public var width:int;
		
		/**
		 * 	@public
		 */
		public var height:int;
		
		/**
		 * 	@public
		 */
		public var format:String;
		
		/**
		 * 	@public
		 */
		public function DisplayTexture(width:int, height:int, fbo:Boolean, format:String):void {
			
			this.width		= width;
			this.height		= height;
			this.fbo		= fbo;
			this.format		= format
			
		}
		
		/**
		 * 	@public
		 */
		public function upload(data:BitmapData, mipLevel:uint = 0):void {
			
			if (!internalTexture) {
				throw new Error('No Internal Texture!');
			}
			
			internalTexture.uploadFromBitmapData(data, mipLevel);
		}
		
		/**
		 * 	@public
		 */
		public function toString():String {
			return '[Texture ' + internalTexture + ']';
		}
		
	}
}