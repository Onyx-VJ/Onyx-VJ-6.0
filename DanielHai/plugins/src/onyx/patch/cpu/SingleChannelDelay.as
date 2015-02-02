package onyx.patch.cpu {
	
	import com.danielhai.cpu.ChannelBuffer;
	import com.danielhai.cpu.SharedBufferFrame;
	
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
	
	// TODO, make this time based rather than frame based
	
	[Parameter(type='channelCPU',	id='boundChannel',	target='boundChannel')]
	[Parameter(type='int',			id='delay',			target='delay',	reset='48',	clamp='1,96')]
	
	final public class SingleChannelDelay extends PluginPatchTransformCPU {
		
		/**
		 * 	@private
		 */
		parameter var boundChannel:IChannel;
		
		/**
		 * 	@private
		 */
		private var buffer:ChannelBuffer			= new ChannelBuffer();
		
		/**
		 * 	@private
		 */
		private const frames:Array					= [];
		
		/**
		 * 	@parameter
		 */
		parameter var delay:uint					= 48;
		
		/**
		 * 	@public
		 */
		override public function initialize(context:IDisplayContextCPU, channel:IChannelCPU, path:IFileReference, content:Object):PluginStatus {
			
			// set our size to the context size
			dimensions.width 		= context.width;
			dimensions.height		= context.height;
			
			// initialize buffer
			buffer.initialize(context);
			
			// success
			return super.initialize(context, channel, path, content);
		}
		
		/**
		 * 	@public
		 */
		override public function getTotalTime():int {
			return 0;
		}
		
		/**
		 * 	@private
		 * 	Called when the target channel executes
		 */
		private function handleFrame():void {
			
			if (frames.push(buffer.requestFrame()) > delay) {
				
				// release all the extra frames
				buffer.releaseFrames(frames.splice(0, frames.length - delay));
				
			}
		}
		
		/**
		 * 	@public
		 */
		override protected function validate(invalidParameters:Object):void {
			
			super.validate(invalidParameters);
			if (invalidParameters.boundChannel) {
				buffer.attach(boundChannel as IChannelCPU, handleFrame);
			}
			
		}
		
		/**
		 * 	@public
		 */
		override public function update(time:Number):Boolean {
			
			// only render on full
			return invalid || (frames.length === delay);
		}
		
		/**
		 * 	@public
		 */
		override public function render(context:IDisplayContextCPU):Boolean {
			
			const frame:SharedBufferFrame	= frames[0];
			if (frame) {
				if (renderMatrix) {
					context.clear();
					context.draw(frame.surface, renderMatrix);
				} else {
					context.copyPixels(frame.surface);
				}
				return true;
			}
			
			return false;
		}
				
		/**
		 * 	@public
		 */
		override public function dispose():void {
			
			// attach null
			buffer.attach(null, handleFrame);
			
			// release all the frames
			buffer.releaseFrames(frames.splice(0, frames.length));
			
			// dispose
			super.dispose();
			
		}
	}
}