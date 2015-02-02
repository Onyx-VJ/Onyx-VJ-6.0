package onyx.patch.cpu {
	
	import com.danielhai.cpu.*;
	
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.text.*;
	
	import onyx.core.*;
	import onyx.display.*;
	import onyx.event.*;
	import onyx.parameter.*;
	import onyx.plugin.*;
	
	use namespace parameter;
	
	[Parameter(type='channelCPU',	id='targetChannel',	target='targetChannel')]
	[Parameter(type='number',		id='maxFrames',		target='maxFrames', 		clamp='100,500')]
	[Parameter(type='number',		id='skipFrames',	target='frameSkip',			clamp='0,5')]
	[Parameter(type='function',		id='start',			target='start')]
	[Parameter(type='function',		id='stop',			target='stop')]
	[Parameter(type='function',		id='clear',			target='clear')]
	
	final public class StopMotion extends PluginPatchTransformGPU {

		/**
		 * 	@private
		 */
		private var currentFrame:int;
		
		/**
		 * 	@private
		 */
		parameter const buffer:ChannelBuffer	= new ChannelBuffer(); 
		
		/**
		 * 	@parameter
		 */
		parameter var targetChannel:IChannelCPU;
		
		/**
		 * 	@private
		 */
		private var contextCPU:IDisplayContextCPU;
		
		/**
		 * 	@private
		 */
		private const frames:Array	= [];
		
		/**
		 * 	@private
		 */
		parameter var maxFrames:uint			= 300;
		
		/**
		 * 	@private
		 */
		parameter var frameSkip:uint			= 1;
		
		/**
		 * 	@private
		 */
		parameter var frameCount:uint			= 0;
		
		/**
		 * 	@private
		 */
		private var tx:DisplayTexture;

		/**
		 * 	@public
		 */
		override public function initialize(context:IDisplayContextGPU, channel:IChannelGPU, path:IFileReference, content:Object):PluginStatus {
			
			// set our size to the context size
			dimensions.width 		= context.width;
			dimensions.height		= context.height;
			
			tx						= context.requestTexture(context.width, context.height, false);
			contextCPU				= Onyx.GetDisplays()[0].getContext() as IDisplayContextCPU;
			
			// initialize buffer
			buffer.initialize(contextCPU);
			
			// success
			return super.initialize(context, channel, path, content);
		}
		
		/**
		 * 	@public
		 */
		private function handleFrame():void {
			
			if ((frameCount++) % (frameSkip + 1) === 0) {
				return;
			}
			
			// add the frame
			if (frames.push(buffer.requestFrame()) > maxFrames) {
				
				stop();
				
			} 
		}
		
		/**
		 * 	@public
		 */
		public function start():void {
			if (!targetChannel) {
				return;
			}
			clear();
			buffer.attach(targetChannel, handleFrame);
				
		}
		
		/**
		 * 	@public
		 */
		public function stop():void {
			buffer.attach(null, handleFrame);
		}
		
		/**
		 * 	@public
		 */
		public function clear():void {
			buffer.releaseFrames(frames.splice(0, frames.length));
		}
		
		/**
		 * 	@public
		 */
		override public function getTotalTime():int {
			return frames.length * 30;
		}
		
		/**
		 * 	@public
		 */
		override public function update(time:Number):Boolean {
			
			if (!frames.length) {
				return invalid || false;
			}			
			
			var newFrame:int = time * (frames.length - 1);
			if (newFrame !== currentFrame) {
				currentFrame	=  newFrame;
				return true;
			}
			
			return true;
		}
		
		/**
		 * 	@public
		 */
		override public function render(context:IDisplayContextGPU):Boolean {
			
			var frame:SharedBufferFrame = frames[currentFrame];
			if (frame) {
				tx.upload(frame.surface);
				context.clear(Color.CLEAR);
				context.blitTransform(tx, matrix);
				return true;
			} else {
				return false;
			}
		}
		
		/**
		 * 	@public
		 */
		override public function dispose():void {
			
			// release the texture
			context.releaseTexture(tx);
			
			// clear
			clear();
			
			// attach null
			buffer.attach(null, handleFrame);
			
			// dispose
			super.dispose();

		}
	}
}