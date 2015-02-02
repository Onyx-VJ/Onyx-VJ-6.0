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
	
	// TODO, make this time based rather than frame based
	
	[Parameter(type='channelCPU',	id='boundChannel',	target='boundChannel')]
	[Parameter(type='int',			id='delay',			target='delay',	reset='30',	clamp='1,96')]
	[Parameter(type='int',			id='steps',			target='steps',	reset='6',	clamp='1,12')]
	[Parameter(type='blendMode',	id='blend',			target='blend', reset='Onyx.Display.Blend.Lighten::CPU')]
	
	final public class MultiChannelDelay extends PluginPatchCPU {
		
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
		parameter var delay:uint					= 30;
		
		/**
		 * 	@parameter
		 */
		parameter var steps:uint					= 6;
		
		/**
		 * 	@private
		 */
		parameter var blend:IPluginBlendCPU			= Onyx.CreateInstance('Onyx.Display.Blend.Lighten::CPU') as IPluginBlendCPU;
		
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
			
			if (invalidParameters.blend) {
				blend.initialize(context);
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
			
			if (frames.length === delay) {
				
				// we are rendering to this
				var target:DisplaySurface	= context.target;
				var size:Number				= frames.length / steps;
				
				for (var count:int = 0; count < steps; ++count) {
					var frame:SharedBufferFrame = frames[int(count * size)];
					if (count === 0) {
						context.copyPixels(frame.surface);
					} else {
						blend.render(target, target, frame.surface);
					}
					
				}
				
			}
			return true;
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