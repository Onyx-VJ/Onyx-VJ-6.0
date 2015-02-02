package onyx.patch.cpu {
	
	import com.danielhai.gpu.*;
	
	import flash.display.*;
	import flash.display3D.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.utils.*;
	
	import onyx.core.*;
	import onyx.display.*;
	import onyx.event.*;
	import onyx.plugin.*;
	import onyx.util.*;
	
	use namespace parameter;
	
	[Parameter(type='status',		id='status',		target='status',		name='status')]
	[Parameter(type='channelCPU',	id='targetChannel',	target='targetChannel',	name='channel')]
	[Parameter(type='function',		id='start',			target='start',			name='record start')]
	[Parameter(type='function',		id='stop',			target='stop',			name='record stop')]
	[Parameter(type='function',		id='saveFrames',	target='saveFrames',	name='save frames')]
	
	/**
	 * 	@public
	 */
	public final class GPUSpriteRecorder extends PluginPatchGPU {
		
		/**
		 * 	@private
		 */
		parameter const status:EventDispatcher	= new EventDispatcher();

		/**
		 * 	@private
		 */
		parameter var targetChannel:IChannel;
		
		/**
		 * 	@private
		 */
		private var listenChannel:IChannelCPU;
		
		/**
		 * 	@private
		 */
		private var contextCPU:IDisplayContextCPU;
		
		/**
		 * 	@private
		 */
		private var buffer:GPUSpriteBuffer;
		
		/**
		 * 	@private
		 */
		private const spriteBatch:Vector.<GPUSpriteSheetBatch>	= new Vector.<GPUSpriteSheetBatch>();
		
		/**
		 * 	@private
		 */
		private const sprites:Vector.<GPUSprite>				= new Vector.<GPUSprite>();
		
		/**
		 * 	@private
		 */
		private const modelViewMatrix:Matrix3D					= new Matrix3D();
		
		/**
		 * 	@private
		 */
		private var sheet:GPUSpriteSheet;
		
		/**
		 * 	@public
		 */
		override public function initialize(context:IDisplayContextGPU, channel:IChannelGPU, path:IFileReference, content:Object):PluginStatus {
			
			// set our size to the context size
			dimensions.width 		= context.width;
			dimensions.height		= context.height;
			
			// store the cpu context too
			contextCPU				= Onyx.GetDisplays()[0].getContext() as IDisplayContextCPU;
			
			// when the gpu context is destroyed .....
			context.addEventListener(OnyxEvent.GPU_CONTEXT_CREATE, handleContext);
			
			var screenX:Number	= 2.0 / context.width;
			var screenY:Number	= -2.0 / context.height;
			
			modelViewMatrix.rawData	= Vector.<Number>([
				
				screenX,	0.0,		0.0,	screenX - 0.875,
				0.0,		screenY,	0.0,	0.88 - screenY,
				0.0,		0.0,		1.0,	0.0,
				0.0,		0.0,		0.0,	1.0
				
			]);
			
			// success
			return super.initialize(context, channel, path, content);
		}
		
		/**
		 * 	@private
		 */
		private function handleContext(e:Event):void {
			
			// invalidate the textures and stuff
			for each (var batch:GPUSpriteSheetBatch in spriteBatch) {
				batch.initializeContext(context);
			}
		}
		
		/**
		 * 	@parameter
		 */
		parameter function start():void {
			
			stop();
			
			// listen!
			listenChannel = targetChannel as IChannelCPU;
			if (listenChannel) {
				
				// listen
				listenChannel.addEventListener(OnyxEvent.CHANNEL_RENDER_CPU, handleRender);
				
				// create a new buffer
				buffer		= new GPUSpriteBuffer(0.25);
				buffer.initialize(contextCPU);
			}
		}
		
		/**
		 * 	@private
		 */
		parameter function saveFrames():void {
			
			var count:int = 0;
			
			// invalidate the textures and stuff
			for each (var batch:GPUSpriteSheetBatch in spriteBatch) {
				var data:BitmapData = batch.bitmapData;
				var bytes:ByteArray = data.encode(data.rect, new PNGEncoderOptions());
				
				FileSystem.Write(FileSystem.GetFileReference('/onyx/data/test/' + (count++) + '.png'), bytes, new Callback(trace));
				
			} 
		}
		
		/**
		 * 	@private
		 */
		private function handleRender(e:OnyxEvent):void {
			
			// is it complete?
			if (buffer.addFrame(listenChannel)) {
				
				// stop listening
				stop();

			}
		} 
		
		/**
		 * 	@parameter
		 */
		parameter function stop(createSheet:Boolean = true):void {
			
			if (createSheet && buffer) {
				
				// batch
				var batch:GPUSpriteSheetBatch = new GPUSpriteSheetBatch(buffer.createSheet());
				spriteBatch.push(batch);
				
				if (context.isValid()) {
					batch.initializeContext(context);
				}
				
				var count:int = 5000;
				while (count--) {
	
					// create some sprites
					batch.createChild(Math.random() * batch.numSprites);
					
				}
			
				buffer = null;
			}
			
			if (listenChannel) {
				listenChannel.removeEventListener(OnyxEvent.CHANNEL_RENDER_CPU, handleRender);
			}
		}
		
		/**
		 * 	@public
		 */
		override protected function validate(invalidParameters:Object):void {
		}
		
		/**
		 * 	@public
		 */
		override public function update(time:Number):Boolean {
			return spriteBatch.length > 0;
		}
		
		/**
		 * 	@public
		 */
		override public function render(context:IDisplayContextGPU):Boolean {

			context.setBlendFactor(Context3DBlendFactor.SOURCE_ALPHA, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);
			context.clear(Color.CLEAR);
			
			for each (var batch:GPUSpriteSheetBatch in spriteBatch) {
				batch.render(context, modelViewMatrix);
			}

			return false;
		}
		
		/**
		 * 	@public
		 */
		override public function dispose():void {
			
			// when the gpu context is destroyed .....
			context.removeEventListener(OnyxEvent.GPU_CONTEXT_CREATE, handleContext);
			
			// clear
			stop(false);
			
			// dispose
			super.dispose();
		}
	}
}