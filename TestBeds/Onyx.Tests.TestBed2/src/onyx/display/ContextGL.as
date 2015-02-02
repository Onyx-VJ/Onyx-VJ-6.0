package onyx.display {
	
	import com.adobe.utils.*;
	
	import flash.display.*;
	import flash.display3D.*;
	import flash.display3D.textures.*;
	import flash.events.*;

	final public class ContextGL extends EventDispatcher {
		
		/**
		 * 	@public
		 */
		
		/**
		 * 	@private
		 */
		private static const assembler:AGALMiniAssembler	= new AGALMiniAssembler();
		
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
		 */
		public var stage:Stage;
		
		/**
		 * 	@private
		 */
		private var stage3D:Stage3D;
		
		/**
		 * 	@private
		 */
		private var context:Context3D;
		
		/**
		 * 	@private
		 */
		private var assets:Object;
		
		/**
		 * 	@private
		 */
		private var renderDirect:Program3D;
		
		/**
		 * 	@private
		 */
		private var renderTransform:Program3D;
		
		/**
		 * 	@private
		 */
		private var backgroundColor:Color;
		
		/**
		 * 	@protected
		 */
		private var index:IndexBuffer3D;
		
		/**
		 * 	@protected
		 */
		private var vertex:VertexBuffer3D;
		
		/**
		 * 	@private
		 */
		private var width:int;
		
		/**
		 * 	@private
		 */
		private var height:int;
		
		/**
		 * 	@private
		 * 	target		= 1
		 * 	rendered	= 0
		 */
		private const buffer:Vector.<Texture>	= new Vector.<Texture>(2, true);
		
		/**
		 * 	@public
		 */
		public function ContextGL(stage:Stage, assets:Object, width:int = 1024, height:int = 1024):void {
			
			this.width				= width;
			this.height				= height;
			this.backgroundColor	= Color.BLACK;
			
			this.assets				= assets;
			
			this.stage				= stage;
			this.stage3D			= stage.stage3Ds[0];
			this.stage3D.addEventListener(Event.CONTEXT3D_CREATE, handleContext);
			this.stage3D.requestContext3D();

		}
		
		/**
		 * 	@private
		 */
		private function handleContext(event:Event):void {
			
			context = stage3D.context3D;
			context.configureBackBuffer(width, height, 0, false);
			context.enableErrorChecking	= true;
			context.setDepthTest(false, Context3DCompareMode.NEVER);
			
			// create programs
			renderDirect	= createProgram(assets['Render.Direct']);
			renderTransform = createProgram(assets['Render.Transform']);
			
			// create the buffers
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
			
			// create front and back buffers for our own rendering
			buffer[0] = createFrameBuffer(width, height);
			buffer[1] = createFrameBuffer(width, height);
			
			// re-dispatch the event
			dispatchEvent(event);

		}
		
		/**
		 * 	@public
		 */
		public function createTexture(data:BitmapData, premultiply:Boolean = true):Texture {
			
			const width:int			= getSize(data.width);
			const height:int		= getSize(data.height);
			const texture:Texture	= context.createTexture(width, height, Context3DTextureFormat.BGRA, false);
			texture.uploadFromBitmapData(data);
			
			if (premultiply) {
				
				const buffer:Texture	= this.createFrameBuffer(width, height);
				context.setRenderToTexture(buffer);
				context.clear(0, 0, 0, 0);
				
				// set blend
				context.setBlendFactors(Context3DBlendFactor.ONE, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);
				draw(texture);
				
				// dispose original texture
				texture.dispose();
				
				// return
				return buffer;
			}
			
			return texture;
		}
		
		/**
		 * 	@public
		 */
		public function createFrameBuffer(width:int, height:int):Texture {
			return context.createTexture(getSize(width), getSize(height), Context3DTextureFormat.BGRA, true);
		}
		
		/**
		 * 	@public
		 */
		public function present():void {
			
			context.setRenderToBackBuffer();
			context.clear(backgroundColor.r, backgroundColor.g, backgroundColor.b, backgroundColor.a);

			// why unmultiplied?
			setBlendFactor(Context3DBlendFactor.ONE, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);
			draw(buffer[0]);
			
			context.present();
		}
		
		/**
		 * 	@public
		 */
		public function bindBuffer():void {
			
			// swap
			context.setRenderToTexture(buffer[0]);
			context.clear(0,0,0,0);
			
			// swap
			context.setRenderToTexture(buffer[1]);
			context.clear(0,0,0,0);

		}

		/**
		 * 	@public
		 */
		public function getBuffer():Texture {
			return buffer[0];
		}
		
		/**
		 * 	@public
		 */
		public function swapBuffer():void {
			
			const prev:Texture	= buffer[0];
			buffer[0]			= buffer[1];
			buffer[1]			= prev;
			
			// swap
			context.setRenderToTexture(buffer[1]);
			context.clear(0,0,0,0);
			
		}
		
		/**
		 * 	@public
		 */
		public function isValid():Boolean {
			return context !== null;
		}
		
		/**
		 * 	@public
		 */
		public function clear(color:Color = null):void {
			if (!color) {
				color = Color.CLEAR;
			}
			context.clear(color.r, color.g, color.b, color.a);
		}
		
		/**
		 * 	@public
		 */
		public function exec(program:Program3D, ... textures:Array):void {
			
			context.setProgram(program);
			for (var count:int = 0; count < textures.length; ++count) {
				context.setTextureAt(count, textures[count]);
			}
			context.drawTriangles(index);

		}
		
		public function setProgramConstants(program:String, data:Vector.<Number>):void {
			context.setProgramConstantsFromVector(program, 0, data);
		}
		
		/**
		 * 	@public
		 */
		public function createProgram(token:Object):Program3D {

			const program:Program3D = context.createProgram();
			program.upload(assembler.assemble(Context3DProgramType.VERTEX, token['Plugin.Shader.Vertex']), assembler.assemble(Context3DProgramType.FRAGMENT, token['Plugin.Shader.Fragment']));
			
			// return
			return program;
		}
		
		/**
		 * 	@public
		 */
		final public function draw(texture:Texture):void {
			
			context.setProgram(renderDirect);
			context.setTextureAt(0, texture);
			context.setTextureAt(1, null);
			context.drawTriangles(index);

		}
		
		/**
		 * 	@public
		 */
		final public function setBlendFactor(src:String, dst:String):void {
			context.setBlendFactors(src, dst);
		}
	}
}