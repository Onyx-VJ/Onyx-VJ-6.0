package tests {
	
	import flash.display.*;
	import flash.display3D.*;
	import flash.display3D.textures.*;
	import flash.geom.*;
	
	final public class AverageTest extends TestBase {
		
		/**
		 * 	@private
		 */
		private var blendProg:Program3D;
		private var blitProg:Program3D;
		private var base:Texture;
		private var blend:Texture;
		private var index:IndexBuffer3D;
		private var vertex:VertexBuffer3D;
		private var transform:Program3D;
		private var bufferRender:Texture;
		private var bufferTarget:Texture;
		private var grid:Texture;
		
		public const assets:Object	= {
			base:		'blend.jpg',
			grid:		'grid.png',
			blend:		'test-alpha.png',
			blendProg:	'Onyx.BlendGL.Difference.onx', // 
			blitProg:	'Onyx.RenderGL.Direct.onx',
			transform:	'Onyx.RenderGL.Transform.onx'
		};
		
		private var blendTest:String	= 'difference';
		
		/**
		 * 	@public
		 */
		override public function resize():void {
			
			render();
			
			var bmp:Bitmap = stage.getChildAt(1) as Bitmap;
			bmp.x = stage.stageWidth - bmp.width;
			
		}
		
		/**
		 * 	@public
		 */
		public function initialize():void {
			
			// create programs
			blendProg		= createProgram(assets.blendProg);
			blitProg		= createProgram(assets.blitProg);
			
			transform		= createProgram(assets.transform);
			
			bufferRender	= createFBO(1024, 1024);
			bufferTarget	= createFBO(1024, 1024);
			
			base			= createTexture(assets.base.bitmapData);
			blend			= createTexture(assets.blend.bitmapData);
			grid			= createTexture(assets.grid.bitmapData);
			
			vertex	= context.createVertexBuffer(4, 4);
			vertex.uploadFromVector(Vector.<Number>([
				
				-1.0,	1.0,	0.0,	0.0,
				-1.0,	-1.0,	0.0,	1.0,
				1.0,	-1.0,	1.0,	1.0,
				1.0,	1.0,	1.0,	0.0
				
			]), 0, 4);
			
			index	= context.createIndexBuffer(6);
			index.uploadFromVector (Vector.<uint>([0, 1, 2, 3, 2, 0]), 0, 6);
			
			context.setVertexBufferAt(0, vertex, 0,	Context3DVertexBufferFormat.FLOAT_2);
			context.setVertexBufferAt(1, vertex, 2, Context3DVertexBufferFormat.FLOAT_2);
			
			var bmp:BitmapData	= new BitmapData(640, 480, true, 0);
			bmp.draw(assets.grid.bitmapData);
			bmp.draw(assets.base.bitmapData);		// normal
			bmp.draw(assets.blend.bitmapData,	null, null, 'normal');
			stage.addChild(new Bitmap(bmp));
			
			bmp = new BitmapData(640, 480, true, 0);
			bmp.draw(assets.grid.bitmapData);
			bmp.draw(assets.base.bitmapData);		// normal
			bmp.draw(assets.blend.bitmapData,	null, null, blendTest);
			
			stage.addChild(new Bitmap(bmp)).y = 480;
			
			resize();
			
		}
		
		public function render():void {
			
			// swap
			swap();
			
			// draw
			drawNormal(bufferRender, grid);
			
			// swap
			swap();
			
			// draw
			drawNormal(bufferRender, base);
			
			// swap
			swap();
			
			// draw
			drawBlend(bufferRender, blend);

			// swap
			swap();
			
			// present
			present();
			
		}
		
		private function swap():void {
			
			const prev:Texture	= bufferTarget;
			bufferTarget		= bufferRender;
			bufferRender		= prev;
			
			// swap
			context.setRenderToTexture(bufferTarget);
			context.clear(0,0,0,0);
			
		}
		
		private function present():void {
			
			var screenX:Number	= 1024 / stage.stageWidth;
			var screenY:Number	= 1024 / stage.stageHeight;
			var ratio:Number	= 1.0; // Math.min(stage.stageWidth / 640, stage.stageHeight / 480);
			
			context.setRenderToBackBuffer();
			context.clear(0,0,0,1);

			drawTransform(bufferRender, Vector.<Number>([
				
				ratio * screenX,	0.0,	0.0,	ratio * screenX - 1.0,
				0.0,	ratio * screenY,	0.0,	1.0 - ratio * screenY,
				0.0,	0.0,	1.0,	0.0,
				0.0,	0.0,	0.0,	1.0
				
			]));
			
			context.present();
		}
	
		/**
		 * 	@private
		 */
		private function drawNormal(a:Texture, b:Texture):void {

			context.setBlendFactors(Context3DBlendFactor.ONE, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);
			context.setProgram(blitProg);
			context.setTextureAt(0, a);
			context.setTextureAt(1, null);
			context.drawTriangles(index);
			
			context.setBlendFactors(Context3DBlendFactor.ONE, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);
			context.setProgram(blitProg);
			context.setTextureAt(0, b);
			context.setTextureAt(1, null);
			context.drawTriangles(index);
			
		}
		
		/**
		 * 	@private
		 */
		private function drawBlend(a:Texture, b:Texture):void {
//			
//			// set blending?
//			context.setBlendFactors(Context3DBlendFactor.ONE, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);
//			context.setProgram(blitProg);
//			
//			context.setTextureAt(0, a);
//			context.setTextureAt(1, null);
//			context.drawTriangles(index);
//			
//			context.setBlendFactors(Context3DBlendFactor.ONE, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);
//			context.setProgram(blitProg);
//			context.setTextureAt(0, b);
//			context.setTextureAt(1, null);
//			context.drawTriangles(index);

			// set the blending prog
			context.setBlendFactors(Context3DBlendFactor.ONE, Context3DBlendFactor.ONE);
			context.setProgram(blendProg);
			context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, Vector.<Number>([0.5, 0.5, 0.5, 0.5]));
			context.setTextureAt(0, a);
			context.setTextureAt(1, b);
			
			context.drawTriangles(index);
		}
		
		/**
		 * 	@private
		 */
		private function drawTransform(texture:Texture, matrix:Vector.<Number>):void {
			
			// set blending?
			context.setBlendFactors(Context3DBlendFactor.ONE, Context3DBlendFactor.ONE);
			
			context.setProgram(transform);
			context.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 0, matrix);
			context.setTextureAt(0, texture);
			context.setTextureAt(1, null);
			context.drawTriangles(index);
		}
	}
}