package tests {
	
	import flash.display.*;
	import flash.display3D.*;
	import flash.display3D.textures.*;
	import flash.geom.*;
	
	final public class BlendTest extends TestBase {

		/**
		 * 	@private
		 */
		private var blendProg:Program3D;
		private var base:Texture;
		private var blend:Texture;
		private var bufferRender:Texture;
		private var bufferTarget:Texture;
		
		/**
		 * 	@public
		 */
		public function BlendTest() {
			super(
				{
					grid:		'grid.png',
					base:		'blend.jpg',
					blend:		'test-alpha.png',
					blendProg:	'Onyx.BlendGL.Lighten.onx' 
				}
			);
		}
		
		/**
		 * 	@private
		 */
		private function initializeSurface():void {
			var channel:BitmapData	= new BitmapData(640, 480, true, 0x808080);
			channel.draw(assets.base);
			
//			var bmp:BitmapData	= new BitmapData(640, 480, true, 0x333333);
//			bmp.draw(assets.base);
//			// bmp.draw(assets.blend, null, null, 'lighten', null, true);
//			
//			channel.draw(bmp, null, null, null, null, true);
			
			stage.addChild(new Bitmap(channel)).transform.matrix	= new Matrix(1,0,0,1,0,480);
		}
		
		/**
		 * 	@public
		 */
		override public function initialize():void {
			
			super.initialize();
			
			// create programs
			blendProg		= createProgram(assets.blendProg);
			
			bufferRender	= createFBO(1024, 1024);
			bufferTarget	= createFBO(1024, 1024);
			
			base			= createTexture(assets.base.bitmapData);
			blend			= createTexture(assets.blend.bitmapData);
			
			initializeSurface();
			
			// resize
			resize();
			
		}
		
		public function render():void {
			
//			// swap
			swap();

////			// draw
			drawNormal(bufferRender, base);
////			
////			// swap
			swap();
//			
//			// draw
			drawBlend(blendProg, bufferRender, blend);
//
//			// swap
			swap();
			
			// present
			present(bufferRender, 0.5, 0.5, 0.5);
			
		}
		
		/**
		 * 	@public
		 */
		override public function resize():void {
			render();
		}
		
		
		private function swap():void {
			
			const prev:Texture	= bufferTarget;
			bufferTarget		= bufferRender;
			bufferRender		= prev;
			
			// context.setBlendFactors(Context3DBlendFactor.SOURCE_ALPHA,Context3DBlendFactor.ONE_MINUS_DESTINATION_ALPHA);
			
			// swap
			context.setRenderToTexture(bufferTarget);
			context.clear(0,0,0,0);
			
		}
	}
}