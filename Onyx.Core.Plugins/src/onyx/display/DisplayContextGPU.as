package onyx.display {
	
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
	import onyx.event.OnyxEvent;
	import onyx.plugin.*;
	import onyx.util.*;
	
	use namespace parameter;
	use namespace onyx_ns;
	
	final public class DisplayContextGPU extends EventDispatcher implements IDisplayContextGPU {
		
		/**
		 * 	@private
		 */
		private static const NORMAL_TRANSFORM:Vector.<Number>	= Vector.<Number>([1.0, 1.0, 1.0, 1.0]); 
		
		/**
		 * 	@public
		 * 	TODO: Inline
		 */
		public static function getNearestPowerOfTwo(v:int):int {
			
			// fast check
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
		 * 	@parameter
		 */
		parameter const colorTransform:ColorTransform					= new ColorTransform();
		
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
		 * 	Stores the vertex buffer that we'll use (rect)
		 */
		private var uvBuffer:VertexBuffer3D;
		
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
		private const renderBlit:IPluginRenderGPU		= Onyx.CreateInstance('Onyx.Display.Render.Direct::GPU') as IPluginRenderGPU;
		
		/**
		 * 	@public
		 */
		private const renderTransform:IPluginRenderGPU	= Onyx.CreateInstance('Onyx.Display.Render.Transform::GPU') as IPluginRenderGPU;
		
		/**
		 * 	@public
		 */
		private const renderColor:IPluginRenderGPU		= Onyx.CreateInstance('Onyx.Display.Render.ColorTransform::GPU') as IPluginRenderGPU;
		
		/**
		 * 	@private
		 */
		internal var txWidth:int;
		
		/**
		 * 	@private
		 */
		internal var txHeight:int;
		
		/**
		 * 	@private
		 * 	Size of the context in pixels (not texture size)
		 */
		private const size:Dimensions					= new Dimensions();
		
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
		private var boundChannel:IChannelGPU;
		
		/**
		 * 	@private
		 */
		private var boundTexture:DisplayTexture;
		
		/**
		 * 	@private
		 */
		private var target:DisplayTexture;
		
		/**
		 * 	@private
		 */
		private var uploadTexture:DisplayTexture;
		
		/**
		 * 	@private
		 */
		private var matrix:Vector.<Number>;
		
		/**
		 * 	@private
		 */
		private var antiAlias:int	= 0;
		
		/**
		 * 	@parameter
		 */
		parameter const outputMatrix:Matrix	= new Matrix();
		
		/**
		 * 	@public
		 */
		public function bindChannel(channel:IChannelGPU):void {
			
			boundChannel = channel;
			boundTexture = channel.texture;
			
			context.setRenderToTexture(target.internalTexture);
		}
		
		/**
		 * 	@public
		 */
		public function setPosition(x:int, y:int):void {
			if (!stage3D) {
				return;
			}
			
			stage3D.x = x;
			stage3D.y = y;
		}
		
		/**
		 * 	@public
		 */
		public function set textureAntiAlias(value:int):void {
			
			// antialias
			antiAlias = value;
			
			if (context) {
				context.configureBackBuffer(size.width, size.height, antiAlias, false);
			}
		}
		
		/**
		 * 	@public
		 */
		public function get textureAntiAlias():int {
			return antiAlias;
		}
		
		/**
		 * 	@public
		 */
		public function upload(data:BitmapData):void {
			
			// uploads a texture
			uploadTexture.internalTexture.uploadFromBitmapData(data);
			
			// then draws it
			blit(uploadTexture);
		}
		
		/**
		 * 	@public
		 */
		public function initialize(stage:Stage, x:int, y:int, width:int, height:int):PluginStatus {
			
			this.stage			= stage;
			this.txWidth		= getNearestPowerOfTwo(width);
			this.txHeight		= getNearestPowerOfTwo(height);
			size.width			= width;
			size.height			= height;
			
			updateProjectionMatrix();
			
			this.stage.addEventListener(Event.RESIZE,				handleContext);
			
			this.stage3D		= stage.stage3Ds[0];
			this.stage3D.addEventListener(Event.CONTEXT3D_CREATE,	handleContext);
			this.stage3D.addEventListener(ErrorEvent.ERROR,			handleContext);
			this.stage3D.requestContext3D();
			this.stage3D.x		= x;
			this.stage3D.y		= y;
			
			// store a buffer
			target			= this.requestTexture(txWidth, txHeight, true);
			uploadTexture	= this.requestTexture(txWidth, txHeight, false);

			if (!stage3D) {
				return new PluginStatus('Error initializing context');
			}
			
			if (!renderBlit || !renderTransform || renderBlit.initialize(null, this) !== PluginStatus.OK || renderTransform.initialize(null, this) !== PluginStatus.OK || renderColor.initialize(null, this) !== PluginStatus.OK) {
				return new PluginStatus('Error Initializating Default Renderers');
			}
			
			// ok
			return PluginStatus.OK;
		}
		
		/**
		 * 	@public
		 */
		internal function updateProjectionMatrix():void {
			
			var screenX:Number	= txWidth / size.width * outputMatrix.a;
			var screenY:Number	= txHeight / size.height * outputMatrix.d;
			
			matrix	= Vector.<Number>([
				
				screenX,	0.0,		0.0,	screenX - 1.0 + outputMatrix.tx,
				0.0,		screenY,	0.0,	1.0 - screenY - outputMatrix.ty,
				0.0,		0.0,		1.0,	0.0,
				0.0,		0.0,		0.0,	1.0
				
			]);
			
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
			return size.width;
		}
		
		/**
		 * 	@public
		 */
		public function get height():int {
			return size.height;
		}
		
		/**
		 * 	@public
		 */
		public function swapBuffer():void {
			
			var temp:DisplayTexture					= boundTexture;
			boundTexture							= target;
			target									= temp;
			
			// clear the buffer
			context.setRenderToTexture(target.internalTexture);
			context.clear();
			
		}
		
		/**
		 * 	@public
		 */
		public function get texture():DisplayTexture {
			return boundTexture;
		}
		
		/**
		 * 	@private
		 */
		private function handleContext(e:Event):void {
			
			trace(e);
			
			switch (e.type) {
				case Event.RESIZE:
					
					break;
				case Event.CONTEXT3D_CREATE:
					
					// store the context
					context	= stage3D.context3D;
					valid	= true;
					
					// reconfigure buffer
					context.configureBackBuffer(size.width, size.height, antiAlias, false);
					context.setDepthTest(false, Context3DCompareMode.NEVER);
					CONFIG::DEBUG {
						context.enableErrorChecking	= true;
						Console.Debug('Context Created:', context.driverInfo, size.width + 'x' + size.height);
					}
					
					// create the buffers
					// TODO, calculate texture uv here, so we don't draw a full texture
					vBuffer		= context.createVertexBuffer(4, 4);
					vBuffer.uploadFromVector(Vector.<Number>([
						
						//	x		y		z
						
						-1.0,	1.0,	0.0,	0.0,
						-1.0,	-1.0,	0.0,	1.0,
						1.0,	-1.0,	1.0,	1.0,
						1.0,	1.0,	1.0,	0.0
						
					]), 0, 4);
					
					iBuffer	= context.createIndexBuffer(6);
					iBuffer.uploadFromVector (Vector.<uint>([0, 1, 2, 3, 2, 0]), 0, 6);
					
					// set vertices for transformations -- uv is full
					context.setVertexBufferAt(0, vBuffer, 0, Context3DVertexBufferFormat.FLOAT_2); //xy
					context.setVertexBufferAt(1, vBuffer, 2, Context3DVertexBufferFormat.FLOAT_2); //uv
					
					// INVALIDATE CONTEXT!
					invalidateContext();
					
					context.setRenderToBackBuffer();
					context.clear(0,0,0);
					context.present();
					
					// dispatch
					dispatchEvent(new OnyxEvent(OnyxEvent.GPU_CONTEXT_CREATE));
					
					break;
				case ErrorEvent.ERROR:
					
					this.context	= null;
					
					break;
			}
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
				texture.internalTexture = context.createTexture(texture.width, texture.height, Context3DTextureFormat.BGRA, texture.fbo);
				if (texture.fbo) {
					context.setRenderToTexture(texture.internalTexture, false);
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
		public function requestTexture(width:int, height:int, fbo:Boolean = false, format:String = Context3DTextureFormat.BGRA):DisplayTexture {
			
			// test powers
			width	= getNearestPowerOfTwo(width);
			height	= getNearestPowerOfTwo(height);
			
			const texture:DisplayTexture = new DisplayTexture(width, height, fbo, Context3DTextureFormat.BGRA);
			requestedTextures.push(texture);
			
			if (valid) {
				texture.internalTexture = context.createTexture(width, height, Context3DTextureFormat.BGRA, fbo);
				if (fbo) {
					context.setRenderToTexture(texture.internalTexture, false);
					context.clear(0, 0, 0, 0);
				}
			}
			
			return texture;
		}
		
		/**
		 * 	@public
		 */
		public function requestProgram(vertex:ByteArray, frag:ByteArray, info:String = ''):IDisplayProgramGPU {
			const program:DisplayProgram = new DisplayProgram(this, vertex, frag, info);
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
		public function releaseProgram(program:IDisplayProgramGPU):void {
			const index:int				= requestedPrograms.indexOf(program);
			if (index !== -1) {
				requestedPrograms.splice(index, 1);
			}
			program.dispose();
		}
		
		/**
		 * 	@public
		 */
		public function releaseTexture(texture:DisplayTexture):void {
			
			if (!texture) {
				return;
			}
			
			const index:int = requestedTextures.indexOf(texture);
			if (index !== -1) {
				requestedTextures.splice(index, 1);
			}
			
			// release
			texture.internalTexture.dispose();
			texture.internalTexture = null;
			
		}
		
		/**
		 * 	@public
		 */
		public function blitColorTransform(texture:DisplayTexture, transform:ColorTransform):void {
			
			renderColor.setParameterValue('colorTransform', Vector.<Number>([transform.redMultiplier, transform.greenMultiplier, transform.blueMultiplier, transform.alphaMultiplier]));
			renderColor.render(this, texture);
			
		}
		
		/**
		 * 	@public
		 */
		public function bindTexture(texture:DisplayTexture):Boolean {
			if (texture && texture.internalTexture) {
				context.setRenderToTexture(texture.internalTexture);
				return true;
			}
			return false;
		}
		
		/**
		 * 	@public
		 */
		public function bindProgram(program:IDisplayProgramGPU):void {
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
		public function setProgramConstantsFromVector(type:String, firstRegister:int, data:Vector.<Number>, numRegisters:int = -1):void {
			context.setProgramConstantsFromVector(type, firstRegister, data, numRegisters);
		}
		
		/**
		 * 	@public
		 */
		public function setProgramConstantsFromMatrix(type:String, firstRegister:int, matrix:Matrix3D, transposedMatrix:Boolean = false):void {
			context.setProgramConstantsFromMatrix(type, firstRegister, matrix, transposedMatrix);
		}
		
		/**
		 * 	@public
		 */
		public function drawTriangles(indexBuffer:IndexBuffer3D, firstIndex:int = 0, numTriangles:int = -1):void {
			context.drawTriangles(indexBuffer, firstIndex, numTriangles);
		}
		
		/**
		 * 	@public
		 */
		public function unbind():void {
			
			if (boundChannel) {
				boundChannel.swapTexture(boundTexture);
				boundChannel = null;
			}
			
			// set render to back buffer!
			context.setRenderToBackBuffer();
		}
		
		/**
		 * 	@public
		 */
		public function present(texture:DisplayTexture):void {
			
			// set render
			context.setRenderToBackBuffer();
			
			// draw with default matrix
			blitTransform(texture, matrix, colorTransform);
			
			// present!
			context.present();
		}
		
		/**
		 * 	@public
		 */
		public function blit(texture:DisplayTexture):void {
			renderBlit.render(this, texture);
		}
		
		/**
		 * 	@public
		 */
		public function blitTransform(texture:DisplayTexture, matrix:Vector.<Number>, transform:ColorTransform = null):void {
			
			// set vertices for transformations
			context.setVertexBufferAt(0, vBuffer, 0, Context3DVertexBufferFormat.FLOAT_2); //xy
			context.setVertexBufferAt(1, vBuffer, 2, Context3DVertexBufferFormat.FLOAT_2); //uv
			context.setVertexBufferAt(2, null);
			
			// draw with matrix
			renderTransform.setParameterValue('matrix',			matrix);
			renderTransform.setParameterValue('colorTransform', transform ? Vector.<Number>([transform.redMultiplier, transform.greenMultiplier, transform.blueMultiplier, transform.alphaMultiplier]) : NORMAL_TRANSFORM);
			
			renderTransform.render(this, texture);

		}
		
		/**
		 * 	@public
		 */
		public function drawProgram():void {
			
			// set vertices for transformations
			context.setVertexBufferAt(0, vBuffer, 0, Context3DVertexBufferFormat.FLOAT_2); //xy
			context.setVertexBufferAt(1, vBuffer, 2, Context3DVertexBufferFormat.FLOAT_2); //uv
			context.setVertexBufferAt(2, null);

			context.drawTriangles(iBuffer);
		}
		
		/**
		 * 	@public
		 */
		public function setTextureAt(index:int, texture:DisplayTexture = null):void {
			context.setTextureAt(index, texture ? texture.internalTexture : null);
		}
		
		/**
		 * 	@public
		 */
		public function isValid():Boolean {
			return context !== null && context.driverInfo !== 'Disposed';
		}
		
		/**
		 * 	@public
		 */
		public function dispose():void {
			renderBlit.dispose();
			renderTransform.dispose();
			renderColor.dispose();			
		}
		
		/**
		 * 	@public
		 */
		public function createIndexBuffer(numIndices:int):IndexBuffer3D{
			
			CONFIG::DEBUG {
				if (!context) {
					throw new Error('Context Not Created!');
				}
			}
			
			return context.createIndexBuffer(numIndices);
		}
		
		/**
		 * 	@public
		 */
		public function createVertexBuffer(numVertices:int, dataPerVertex:int):VertexBuffer3D {
			return context.createVertexBuffer(numVertices, dataPerVertex);
		}
		
		/**
		 * 	@public
		 */
		public function setVertexBufferAt(index:int, buffer:VertexBuffer3D, bufferOffset:int = 0, format:String = 'float4'):void {
			context.setVertexBufferAt(index, buffer, bufferOffset, format);
		}
		
		/**
		 * 	@public
		 */
		public function get textureWidth():int {
			return txWidth;
		}
		
		/**
		 * 	@public
		 */
		public function get textureHeight():int {
			return txHeight;
		}
	}
}