package tests {
	
	import flash.display.Bitmap;
	import flash.display3D.*;
	import flash.display3D.textures.*;
	
	final public class ScaleTest extends TestBase {
		
		/**
		 * 	@private
		 */
		private var renderProg:Program3D;
		private var base:Texture;
		private var index:IndexBuffer3D;
		private var vertex:VertexBuffer3D;
		private var transform:Program3D;
		
		public const assets:Object	= {
			base:		'test-alpha.png',
			render:		'Onyx.RenderGL.Direct.onx',
			transform:	'Onyx.RenderGL.Transform.onx'
		};
		
		/**
		 * 	@public
		 */
		override public function resize():void {
			
			render();
			
		}
		
		public function render():void {
			
			// vertex position to attribute register 0
			context.clear(0, 0, 0, 1);
			context.setBlendFactors(Context3DBlendFactor.SOURCE_ALPHA, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);
			context.setDepthTest(false, Context3DCompareMode.NOT_EQUAL);
			
			var screenX:Number	= 512 / stage.stageWidth;
			var screenY:Number	= 256 / stage.stageHeight;
			var ratio:Number	= Math.min(stage.stageWidth / 320, stage.stageHeight / 240);
			
			drawTransform(base, Vector.<Number>([
//				1.0,	0.0,	0.0,	0.0,
//				0.0,	1.0,	0.0,	0.0,
//				0.0,	0.0,	1.0,	0.0,
//				0.0,	0.0,	0.0,	1.0
				
				ratio * screenX,	0.0,	0.0,	ratio * screenX - 1.0,
				0.0,	ratio * screenY,	0.0,	1.0 - ratio * screenY,
				0.0,	0.0,	1.0,	0.0,
				0.0,	0.0,	0.0,	1.0
				
				// this keeps same ratio
//				512 / stage.stageWidth,	0.0,	0.0,	(512 / stage.stageWidth) - 1.0,
//				0.0,	256 / stage.stageHeight,	0.0,	1.0 - (256 / stage.stageHeight),
//				0.0,	0.0,	1.0,	0.0,
//				0.0,	0.0,	0.0,	1.0
			]));
			// draw(base);
			
			context.present();
		}
	
		/**
		 * 	@public
		 */
		public function initialize():void {
			
			// create programs
			renderProg	= createProgram(assets.render);
			transform	= createProgram(assets.transform);
			
			base		= context.createTexture(512, 256, Context3DTextureFormat.BGRA, true);
			base.uploadFromBitmapData(assets.base.bitmapData);
			
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
			
			render();
			
		}
		
		/**
		 * 	@private
		 */
		private function draw(texture:Texture):void {
			
			context.setProgram(renderProg);
			context.setTextureAt(0, texture);
			context.setTextureAt(1, null);
			context.drawTriangles(index);
			
		}
		
		/**
		 * 	@private
		 */
		private function drawTransform(texture:Texture, matrix:Vector.<Number>):void {
			
			context.setProgram(transform);
			context.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 0, matrix);
			context.setTextureAt(0, texture);
			// context.setTextureAt(1, texture);
			context.drawTriangles(index);
		}
	}
}