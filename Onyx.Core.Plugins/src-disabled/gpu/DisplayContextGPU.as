package onyx.display.gpu {
	
	import flash.desktop.*;
	import flash.display.*;
	import flash.display3D.*;
	import flash.display3D.textures.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.system.System;
	import flash.ui.*;
	import flash.utils.*;
	
	import onyx.core.*;
	import onyx.display.*;
	import onyx.plugin.*;
	import onyx.util.*;
	
	use namespace parameter;
	use namespace onyx_ns;

	final public class DisplayContextGPU extends EventDispatcher implements IDisplayContextGPU {
		
		/**
		 * 	@private
		 */
		public static function getNearestPowerOfTwo(v:int):int {

			if ((v & (v-1)) === 0) {
				return v;
			}
			
			--v;
			v |= v >> 1;
			v |= v >> 2;
			v |= v >> 4;
			v |= v >> 8;
			v |= v >> 16;
			
			return ++v;
		}

		/**
		 * 	@private
		 */
		private const requestedPrograms:Array		= [];
		
		/**
		 * 	@private
		 */
		private const requestedTextures:Array		= [];
		
		/**
		 * 	@public
		 */
		internal var context:Context3D;
		
		/**
		 * 	@private
		 * 	Stores the vertex buffer that we'll use (rect)
		 */
		private var vBuffer:VertexBuffer3D;
		
		/**
		 * 	@private
		 * 	Stores the index buffer that we'll use (rect)
		 */
		private var iBuffer:IndexBuffer3D;
		
		/**
		 * 	@public
		 */
		internal var stage3D:Stage3D;
		
		/**
		 * 	@public
		 */
		internal var stage:Stage;
		
		/**
		 * 	@public
		 */
		public const identity:Point						= new Point();
		
		/**
		 * 	@public
		 */
		private const renderBlit:IPluginFilterGPU		= Onyx.CreateInstance('Onyx.Display.GPU.Render.Direct') as IPluginFilterGPU;
		
		/**
		 * 	@public
		 */
		private const renderTransform:IPluginFilterGPU	= Onyx.CreateInstance('Onyx.Display.GPU.Render.Transform') as IPluginFilterGPU;
		
		/**
		 * 	@public
		 */
		private const renderColor:IPluginFilterGPU		= Onyx.CreateInstance('Onyx.Display.GPU.Render.ColorTransform') as IPluginFilterGPU;

		/**
		 * 	@private
		 */
		public var textureWidth:int;
		
		/**
		 * 	@private
		 */
		public var textureHeight:int;
				
		/**
		 * 	@private
		 * 	This is a first in last out, meaning, the earlier something requests the texture, is the order in which it will regain a texture
		 * 	upon lost context
		 */
		private var textures:Array						= [];
		
		/**
		 * 	@private
		 */
		private var currentMemory:uint;
		
		/**
		 * 	@public
		 */
		private var maximumMemory:uint;
		
		/**
		 * 	@private
		 */
		private var valid:Boolean;
		
		/**
		 * 	@private
		 */
		private var _frameRate:Number;
		
		/**
		 * 	@private
		 */
		private const buffers:Vector.<DisplayTexture>	= new Vector.<DisplayTexture>(2, true);
		
		/**
		 * 	@public
		 */
		public function initialize(stage:Stage, textureWidth:int, textureHeight:int, frameRate:Number = 30):PluginStatus {
			
			this._frameRate		= frameRate;
			this.stage			= stage;
			this.textureWidth	= textureWidth;
			this.textureHeight	= textureHeight;
			
			this.stage3D		= stage.stage3Ds[0];
			this.stage3D.addEventListener(Event.CONTEXT3D_CREATE,	handleContext);
			this.stage3D.addEventListener(ErrorEvent.ERROR,			handleContext);
			this.stage3D.requestContext3D();
			
			buffers[0]			= this.requestTexture(textureWidth, textureHeight, true) as DisplayTexture;
			buffers[1]			= this.requestTexture(textureWidth, textureHeight, true) as DisplayTexture;
			
			if (!stage3D) {
				return new PluginStatus('Error initializing context');
			}
			
			if (!renderBlit || !renderTransform || renderBlit.initialize(this) !== PluginStatus.OK || renderTransform.initialize(this) !== PluginStatus.OK || renderColor.initialize(this) !== PluginStatus.OK) {
				return new PluginStatus('Error Initializating Default Renderers');
			}
			
			// ok
			return PluginStatus.OK;
		}
		
		/**
		 * 	@public
		 */
		public function get frameRate():Number {
			return 0;
		}
		
		/**
		 * 	@public
		 */
		public function get width():int {
			return textureWidth;
		}
		
		/**
		 * 	@public
		 */
		public function get height():int {
			return textureHeight;
		}
		
		/**
		 * 	@public
		 */
		public function bindBuffer():void {
			
			CONFIG::GL {
				Console.Log(CONSOLE::DEBUG, 'Clearing Bind Buffers');
			}
			
			// buffer 1 is previous buffer
			context.setRenderToTexture(buffers[1].nativeTexture);
			context.clear(0, 0, 0, 0);
			
			// buffer 0 is target
			context.setRenderToTexture(buffers[0].nativeTexture);
			context.clear(0, 0, 0, 0);
		}
		
		/**
		 * 	@public
		 */
		public function swapBuffer():void {
			
			CONFIG::GL {
				Console.Log(CONSOLE::DEBUG, 'Swapping Bind Buffers');
			}
			
			const prev:DisplayTexture	= buffers[0];
			buffers[0]					= buffers[1];
			buffers[1]					= prev;
			
			// bind it
			context.setRenderToTexture(buffers[0].nativeTexture);
			context.clear(0, 0, 0, 0);

		}
		
		/**
		 * 	@public
		 */
		public function getBuffer():DisplayTexture {
			return buffers[1];
		}
		
		/**
		 * 	@private
		 */
		private function handleContext(e:Event):void {
			switch (e.type) {
				case Event.CONTEXT3D_CREATE:
					
					// store the context
					context	= stage3D.context3D;
					valid	= true;
					
					// reconfigure buffer
					context.configureBackBuffer(stage.stageWidth, stage.stageHeight, 0);
					context.setDepthTest(false, Context3DCompareMode.ALWAYS);
					// context.enableErrorChecking	= true;
					
					CONSOLE::DEBUG('Context Created:', context.driverInfo, stage.stageWidth + 'x' + stage.stageHeight);
					
					// create the buffers
					vBuffer	= context.createVertexBuffer(4, 4);
					vBuffer.uploadFromVector(Vector.<Number>([
						
						-1.0,	1.0,	0.0,	0.0,
						-1.0,	-1.0,	0.0,	1.0,
						1.0,	-1.0,	1.0,	1.0,
						1.0,	1.0,	1.0,	0.0
						
					]), 0, 4);
					
					iBuffer	= context.createIndexBuffer(6);
					iBuffer.uploadFromVector (Vector.<uint>([0, 1, 2, 3, 2, 0]), 0, 6);
					
					// set vertices for transformations
					context.setVertexBufferAt(0, vBuffer, 0, Context3DVertexBufferFormat.FLOAT_2); //xy
					context.setVertexBufferAt(1, vBuffer, 2, Context3DVertexBufferFormat.FLOAT_2); //uv
					
					invalidateContext();
					
					context.setRenderToBackBuffer();
					context.clear(0,0,0);
					context.present();
					
					break;
				case ErrorEvent.ERROR:
					
					trace(e);
					this.context	= null;
					
					break;
			}
		}
		
		/**
		 * 	@public
		 * 	Validates the context by trying to draw a color
		 */
		public function validate(color:Color):Boolean {
			
			try {
				// set render to back buffer
				context.setRenderToBackBuffer();
				context.clear(color.r, color.g, color.b, color.a);
				
			} catch (e:Error) {
				return valid = false;
			}
			
			return valid = true;
		} 
		
		/**
		 * 	@private
		 */
		private function invalidateContext():void {
			
			CONFIG::DEBUG {
				Console.Log(CONSOLE::MESSAGE, 'GPU Context Invalidated');
			}
			
			// reset requested memory/program
			
			// loop through textures and stuff
			for each (var texture:DisplayTexture in requestedTextures) {
				texture.texture = context.createTexture(texture.width, texture.height, Context3DTextureFormat.BGRA, texture.fbo);
				
				if (texture.fbo) {
					context.setRenderToTexture(texture.texture, false);
					context.clear(0, 0, 0, 0);
				}
			}
			
			// loop through textures and stuff
			for each (var program:DisplayProgram in requestedPrograms) {
				program.program = context.createProgram();
				program.program.upload(program.vertexProgram, program.fragmentProgram);
			}
		}
		
		/**
		 * 	@public
		 */
		public function setBlendFactor(source:String, dest:String):void {
			context.setBlendFactors(source, dest);
		}
		
		/**
		 * 	@public
		 */
		public function clear(color:Color):void {
			
			// clear with color
			context.clear(color.r, color.g, color.b, color.a);
			
		}
		
		/**
		 * 	@public
		 */
		public function requestTexture(width:int, height:int, fbo:Boolean = false):DisplayTexture {
			
			// test powers
			width	= getNearestPowerOfTwo(width);
			height	= getNearestPowerOfTwo(height);
			
			const texture:DisplayTexture = new DisplayTexture(width, height, fbo);
			requestedTextures.push(texture);
			
			if (valid) {
				texture.texture = context.createTexture(width, height, Context3DTextureFormat.BGRA, fbo);
				if (fbo) {
					context.setRenderToTexture(texture.texture, false);
					context.clear(0, 0, 0, 0);
				}
			}
			
			return texture;
		}

		/**
		 * 	@public
		 */
		public function requestProgram(vertex:ByteArray, frag:ByteArray, info:String = ''):IDisplayProgram {
			const program:DisplayProgram = new DisplayProgram(vertex, frag, info);
			requestedPrograms.push(program);
			if (context) {
				program.program				= context.createProgram();
				program.program.upload(vertex, frag);
			}
			return program;
		}
		
		/**
		 * 	@public
		 */
		public function releaseTexture(input:DisplayTexture):void {
			
			const texture:DisplayTexture = input as DisplayTexture;
			if (!texture) {
				return;
			}

			const index:int = requestedTextures.indexOf(texture);
			if (index !== -1) {
				requestedTextures.splice(index, 1);
			}
			
			// release
			texture.texture.dispose();
			texture.texture = null;

		}
		
		/**
		 * 	@public
		 */
		public function drawColorTransform(surface:DisplayTexture, transform:ColorTransform):void {
			
			renderColor.setParameterValue('colorTransform', Vector.<Number>([transform.redMultiplier, transform.greenMultiplier, transform.blueMultiplier, transform.alphaMultiplier]));
			renderColor.render(surface);
			
		}
		
		/**
		 * 	@public
		 */
		public function bindTexture(texture:DisplayTexture):Boolean {
			if (texture && texture.nativeTexture) {
				context.setRenderToTexture(texture.nativeTexture);
				return true;
			}
			return false;
		}
		
		/**
		 * 	@public
		 */
		public function bindProgram(program:IDisplayProgram):void {
			context.setProgram(program.nativeProgram);
		}
		
		/**
		 * 	@public
		 */
		public function uniform(type:String, data:Vector.<Number>):void {
			context.setProgramConstantsFromVector(type, 0, data);
		}
		
		/**
		 * 	@public
		 */
		public function unbind():void {
			context.setRenderToBackBuffer();
		}
		
		/**
		 * 	@public
		 */
		public function present():void {
			context.present();
		}
		
		/**
		 * 	@public
		 */
		public function draw(texture:DisplayTexture):void {
			renderBlit.render(texture);
		}
		
		/**
		 * 	@public
		 */
		public function drawTransform(texture:DisplayTexture, matrix:Vector.<Number>):void {
			renderTransform.setParameterValue('matrix', matrix);
			renderTransform.render(texture);
			
		}
		
		/**
		 * 	@public
		 */
		public function drawProgram():void {
			context.drawTriangles(iBuffer);
		}
		
		/**
		 * 	@public
		 */
		public function setTextureAt(index:int, texture:DisplayTexture = null):void {
			context.setTextureAt(index, texture ? texture.nativeTexture : null);
		}
		
		/**
		 * 	@public
		 */
		public function dispose():void {
			renderBlit.dispose();
			renderTransform.dispose();
			renderColor.dispose();			
		}
	}

}