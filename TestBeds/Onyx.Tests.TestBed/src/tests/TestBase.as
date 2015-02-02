package tests {
	
	import com.adobe.utils.AGALMiniAssembler;
	
	import flash.display.BitmapData;
	import flash.display.Stage;
	import flash.display3D.*;
	import flash.display3D.textures.Texture;

	public class TestBase {
		
		/**
		 * 	@private
		 */
		private static function getSize(input:int):int {
			const sizes:Array	= [2,4,8,16,32,64,128,256,1024,2048];
			for each (var size:int in sizes) {
				if (size >= input) {
					return size;
				}
			}
			return 2048;
		}
		
		/**
		 * 	@private
		 * 	Tokenizes a text file into usable
		 */
		private static function tokenize(data:String):Object {
			
			const reg:RegExp 		= /\[(.+?)\]/g;
			const serialized:Object	= {};
			var match:Array;
			var token:String;
			var last:int;
			
			// look for tokens
			while (match = reg.exec(data)) {
				if (last) {
					serialized[token] = data.substr(last, reg.lastIndex - last - match[0].length);
				}
				
				token	= match[1];
				last	= reg.lastIndex;
			}
			serialized[token] = data.substr(last);
			
			// not valid
			if (!serialized['Plugin.Shader.Vertex'] || !serialized['Plugin.Shader.Fragment']) {
				return null;
			}
			const obj:Object	= {};
			
			// copy the shader data
			obj['Vertex']			= serialized['Plugin.Shader.Vertex'];
			obj['Fragment']			= serialized['Plugin.Shader.Fragment'];
			
			// save
			return obj;
		}
		
		/**
		 * 	@private
		 */
		private var dependencies:Array;
		
		/**
		 * 	@private
		 */
		protected var context:Context3D;
		
		/**
		 * 	@private
		 */
		protected var stage:Stage;
		
		protected var multProg:Program3D;
		
		private var blitProg:Program3D;
		private var transform:Program3D;
		
		protected var index:IndexBuffer3D;
		protected var vertex:VertexBuffer3D;
		
		/**
		 * 	@protected
		 */
		protected const assets:Object	= {
			blitProg:	'Onyx.RenderGL.Direct.onx',
			transform:	'Onyx.RenderGL.Transform.onx',
			multProg:	'Onyx.BlendGL.UnMultiply.onx'
		};
		
		/**
		 * 	@public
		 */
		public function TestBase(additional:Object):void {
			for (var i:String in additional) {
				assets[i] = additional[i];
			}
		}
		
		/**
		 * 	@public
		 */
		final public function setup(stage:Stage, context:Context3D):void {
			
			// save
			this.context	= context;
			this.stage		= stage;
			
			this.initialize();
			
		}
		
		/**
		 * 	@public
		 */
		public function initialize():void {
			
			multProg 		= createProgram(assets.multProg);
			blitProg		= createProgram(assets.blitProg);
			transform		= createProgram(assets.transform);
			
			vertex	= context.createVertexBuffer(4, 4);
			vertex.uploadFromVector(Vector.<Number>([
				
				-1.0,	1.0,	0.0,	0.0,
				-1.0,	-1.0,	0.0,	1.0,
				1.0,	-1.0,	1.0,	1.0,
				1.0,	1.0,	1.0,	0.0
				
			]), 0, 4);
			
			index	= context.createIndexBuffer(6);
			index.uploadFromVector (Vector.<uint>([0, 1, 2, 3, 2, 0]), 0, 6);
			
			// set vertex
			context.setVertexBufferAt(0, vertex, 0,	Context3DVertexBufferFormat.FLOAT_2);
			context.setVertexBufferAt(1, vertex, 2, Context3DVertexBufferFormat.FLOAT_2);
		}
		
		/**
		 * 	@public
		 */
		public function resize():void {
		}
		
		/**
		 * 	@public
		 */
		final public function createTexture(data:BitmapData, unmultiply:Boolean = true):Texture {
			
			const width:int		= getSize(data.width);
			const height:int	= getSize(data.height);
			
			if (unmultiply) {
				
				var input:Texture	=  context.createTexture(width, height, Context3DTextureFormat.BGRA, false);
				input.uploadFromBitmapData(data);
				
				var tex:Texture 	= context.createTexture(width, height, Context3DTextureFormat.BGRA, true);
				context.setRenderToTexture(tex);
				context.clear();
				draw(input);
				
				var output:Texture	= context.createTexture(width, height, Context3DTextureFormat.BGRA, true);
				
				context.setBlendFactors(Context3DBlendFactor.ONE, Context3DBlendFactor.ONE);
				context.setRenderToTexture(output);
				context.clear();
				
				this.drawUnMultiply(tex);
				
				input.dispose();
				tex.dispose();
				
				return output;
				
			} else {
				
				input = context.createTexture(width, height, Context3DTextureFormat.BGRA, false);
				input.uploadFromBitmapData(data);
				return input;
				
			}
			
			return null;
		}
		
		final public function drawUnMultiply(a:Texture):void {

			// set the blending prog
			context.setBlendFactors(Context3DBlendFactor.ONE, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);
			context.setProgram(multProg);
			context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, Vector.<Number>([1.0, 1.0, 1.0, 1.0]));
			context.setTextureAt(0, a);
			
			// draw?
			context.drawTriangles(index);
			
		}
		
		/**
		 * 	@public
		 */
		final public function createFBO(width:int, height:int):Texture {
			const tex:Texture = context.createTexture(width, height, Context3DTextureFormat.BGRA, true);
			context.setRenderToTexture(tex);
			context.clear(0,0,0,0);
			context.setRenderToBackBuffer();
			return tex;
		}
		
		/**
		 * 	@public
		 */
		final public function createProgram(asset:String):Program3D {
			const token:Object					= tokenize(asset);
			const program:Program3D				= context.createProgram();
			const assembler:AGALMiniAssembler	= new AGALMiniAssembler();
			program.upload(assembler.assemble(Context3DProgramType.VERTEX, token['Vertex']), assembler.assemble(Context3DProgramType.FRAGMENT, token['Fragment']));
			
			return program;
		}
		
		/**
		 * 	@public
		 */
		final public function getAssets():Object {
			return assets;
		}
		
		/**
		 * 	@protected
		 */
		protected function present(texture:Texture, r:Number = 0, g:Number = 0, b:Number = 0):void {
			
			var screenX:Number	= 1024 / stage.stageWidth;
			var screenY:Number	= 1024 / stage.stageHeight;
			var ratio:Number	= 1.0; // Math.min(stage.stageWidth / 640, stage.stageHeight / 480);
			
			context.setRenderToBackBuffer();
			context.clear(r, g, b, 1.0);
			
			drawTransform(texture, Vector.<Number>([
				
				ratio * screenX,	0.0,	0.0,	ratio * screenX - 1.0,
				0.0,	ratio * screenY,	0.0,	1.0 - ratio * screenY,
				0.0,	0.0,	1.0,	0.0,
				0.0,	0.0,	0.0,	1.0
				
			]));
			
			// present
			context.present();
		}
		
		/**
		 * 	@private
		 */
		final protected function drawNormal(a:Texture, b:Texture):void {
			
			context.setBlendFactors(Context3DBlendFactor.SOURCE_ALPHA, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);
			context.setProgram(blitProg);
			context.setTextureAt(0, a);
			context.setTextureAt(1, null);
			context.drawTriangles(index);
			
			context.setBlendFactors(Context3DBlendFactor.SOURCE_ALPHA, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);
			context.setProgram(blitProg);
			context.setTextureAt(0, b);
			context.setTextureAt(1, null);
			context.drawTriangles(index);
			
		}
		
		/**
		 * 	@private
		 */
		final protected function draw(a:Texture):void {

			context.setProgram(blitProg);
			context.setBlendFactors(Context3DBlendFactor.ONE, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);
			context.setTextureAt(0, a);
			context.setTextureAt(1, null);
			context.drawTriangles(index);
			
		}

		/**
		 * 	@private
		 */
		final protected function drawBlend(program:Program3D, a:Texture, b:Texture):void {

			// set the blending prog
			context.setBlendFactors(Context3DBlendFactor.ONE, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);
			context.setProgram(program);
			context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, Vector.<Number>([0.0, 0.0, 0.0, 0.0]));
			context.setTextureAt(0, a);
			context.setTextureAt(1, b);
			
			// draw?
			context.drawTriangles(index);
		}
		
		/**
		 * 	@private
		 */
		private function drawTransform(texture:Texture, matrix:Vector.<Number>):void {
			
			// set blending?
			context.setBlendFactors(Context3DBlendFactor.ONE, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);
			
			// set the transformation program
			context.setProgram(transform);
			context.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 0, matrix);
			context.setTextureAt(0, texture);
			context.setTextureAt(1, null);
			context.drawTriangles(index);
		}
	}
}