package onyx.core {
	
	import flash.display.BitmapData;
	import flash.display3D.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.utils.*;
	
	import onyx.core.*;
	import onyx.display.*;
	import onyx.parameter.*;
	import onyx.plugin.*;
	
	public interface IDisplayContextGPU extends IDisplayContext {
		
		/**
		 * 	@public		Set Blend Factor
		 */
		function setBlendFactor(source:String, dest:String):void;
		
		/**
		 * 	@public		Clear
		 */
		function clear(color:Color):void;
		
		/**
		 * 	@public
		 */
		function bindChannel(channel:IChannelGPU):void;
		
		/**
		 * 	@public
		 */
		function swapBuffer():void;
		
		/**
		 * 	@public		Requests a texture.  You don't have to re-request the texture
		 */
		function requestTexture(width:int, height:int, fbo:Boolean = false, format:String = Context3DTextureFormat.BGRA):DisplayTexture;
		
		/**
		 * 	@public		Releases a texture.  Make sure to call this if you request a texture
		 */
		function releaseTexture(texture:DisplayTexture):void;
		
		/**
		 * 	@public		Requests a program for consumption.  This is automatically updated on gpu invalidation.
		 */
		function requestProgram(vertex:ByteArray, frag:ByteArray, info:String = ''):IDisplayProgramGPU;
		
		/**
		 * 	@public		Releases a program from consumption.
		 */
		function releaseProgram(program:IDisplayProgramGPU):void;
		
		/**
		 * 	@public		Draws a texture, with a color transformation
		 */
		function blitColorTransform(texture:DisplayTexture, transform:ColorTransform):void;
		
		/**
		 * 	@public
		 * 	The default draw program, draws a texture 1:1, no transform, no color transform
		 */
		function blit(texture:DisplayTexture):void;
		
		/**
		 * 	@public
		 * 	Uploads a bitmapdata to the buffer
		 */
		function upload(data:BitmapData):void;
		
		/**
		 * 	@public
		 * 	The default draw program, draws a texture 1:1, no transform, no color transform
		 */
		function blitTransform(texture:DisplayTexture, matrix:Vector.<Number>, colorTransform:ColorTransform = null):void;
		
		/**
		 * 	@public		Returns whether the gpu context is valid or not
		 */
		function isValid():Boolean;
		
		/**
		 * 	@public		Binds a frame buffer for drawing to 
		 */
		function bindTexture(texture:DisplayTexture):Boolean;
		
		/**
		 * 	@public		Binds a program for drawing
		 */
		function bindProgram(program:IDisplayProgramGPU):void;
		
		/**
		 * 	@public		Sets a parameter
		 */
		function uniform(type:String, data:Vector.<Number>):void;
		
		/**
		 * 	@public		Unbind all textures, setting render to back buffer
		 */
		function unbind():void;
		
		/**
		 * 	@public
		 */
		function drawProgram():void;
		
		/**
		 * 	@public
		 */
		function setTextureAt(index:int, surface:DisplayTexture = null):void;
		
		/**
		 * 	@public
		 */
		function get textureWidth():int;
		
		/**
		 * 	@public
		 */
		function get textureHeight():int;
		
		/**
		 * 	@public
		 */
		function dispose():void;
		
		/**
		 * 	@public
		 */
		function createIndexBuffer(numIndices:int):IndexBuffer3D;
		
		/**
		 * 	@public
		 */
		function createVertexBuffer(numVertices:int, dataPerVertex:int):VertexBuffer3D;
		
		/**
		 * 	@public
		 */
		function setProgramConstantsFromVector(type:String, firstRegister:int, data:Vector.<Number>, numRegisters:int = -1):void;
		
		/**
		 * 	@public
		 */
		function setProgramConstantsFromMatrix(type:String, firstRegister:int, matrix:Matrix3D, transposedMatrix:Boolean = false):void;
		
		/**
		 * 	@public
		 */
		function drawTriangles(indexBuffer:IndexBuffer3D, firstIndex:int = 0, numTriangles:int = -1):void;
		
		/**
		 * 	@public
		 */
		function setVertexBufferAt(index:int, buffer:VertexBuffer3D, bufferOffset:int = 0, format:String = 'float4'):void;
		
		/**
		 * 	@public
		 */
		function get texture():DisplayTexture;
		
		/**
		 * 	@public
		 */
		function present(texture:DisplayTexture):void;
		
	}
}