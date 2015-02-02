package tests {
	
	import flash.display.*;
	import flash.display3D.*;
	import flash.display3D.textures.*;
	import flash.events.Event;
	import flash.events.NetStatusEvent;
	import flash.geom.*;
	import flash.media.Video;
	import flash.utils.*;
	
	import tests.net.Stream;
	
	final public class MovieTest extends TestBase {
		
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
		private var stream:Stream	= new Stream();
		private var video:Video		= new Video();
		private var data:BitmapData;
		private var tex:Texture;
		
		public const assets:Object	= {
			blitProg:	'Onyx.RenderGL.Direct.onx',
			transform:	'Onyx.RenderGL.Transform.onx'
		};
		
		/**
		 * 	@public
		 */
		override public function resize():void {
			
			render();
			
		}
		
		private function handleStream(event:NetStatusEvent):void {
			
			switch (event.info.code) {
				case 'NetStream.Play.Metadata':
					
					var data:Object = stream.metadata;
					video.width		= data.width;
					video.height	= data.height;
					
					this.data = new BitmapData(video.width, video.height, false, 0);
					break;
			}
		}
		
		/**
		 * 	@public
		 */
		override public function initialize():void {
			
			stream.addEventListener(NetStatusEvent.NET_STATUS, handleStream);
			stream.play('videoplayback.mp4');
			
			video.attachNetStream(stream);
			stage.addChild(video);
			
			// create programs
			blitProg		= createProgram(assets.blitProg);
			transform		= createProgram(assets.transform);
			
			bufferRender	= createFBO(2048, 2048);
			bufferTarget	= createFBO(2048, 2048);
			tex				= createFBO(2048, 2048);
			
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
			
			// resize
			resize();
			
			// handle frame
			stage.addEventListener(Event.ENTER_FRAME, handleFrame);
			
		}
		
		/**
		 *	@public
		 */
		override public function dispose():void {
			
			// handle frame
			stream.removeEventListener(NetStatusEvent.NET_STATUS, handleStream);
			stream.close();
			
			stage.removeEventListener(Event.ENTER_FRAME, handleFrame);
		}
		
		/**
		 * 	@private
		 */
		private function handleFrame(event:Event):void {
			render();
		}
		
		/**
		 * 	@public
		 */
		public function render():void {
			
			if (!data) {
				return;
			}
				
			data.draw(video);
			
			// upload the texture
			tex.uploadFromBitmapData(data);
		
			context.setRenderToTexture(bufferRender);
			context.clear(0,0,0,1);
			context.setBlendFactors(Context3DBlendFactor.ONE, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);
			draw(tex);
			
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
			
			var screenX:Number	= 2048 / stage.stageWidth;
			var screenY:Number	= 2048 / stage.stageHeight;
			var ratio:Number	= Math.min(stage.stageWidth / data.width, stage.stageHeight / data.height);
			
			context.setRenderToBackBuffer();
			context.clear(0, 0, 0, 1);
			
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
		private function draw(a:Texture):void {

			context.setBlendFactors(Context3DBlendFactor.ONE, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);
			context.setProgram(blitProg);
			context.setTextureAt(0, a);
			context.setTextureAt(1, null);
			context.drawTriangles(index);
			
		}
		
		/**
		 * 	@private
		 */
		private function drawTransform(texture:Texture, matrix:Vector.<Number>):void {
			
			// set blending?
			context.setBlendFactors(Context3DBlendFactor.ONE, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);
			
			context.setProgram(transform);
			context.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 0, matrix);
			context.setTextureAt(0, texture);
			context.setTextureAt(1, null);
			context.drawTriangles(index);
		}
	}
}