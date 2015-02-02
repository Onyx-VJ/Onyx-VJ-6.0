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
	
	[Parameter(type='channelCPU',	id='targetChannel',	target='targetChannel',	name='channel')]
	[Parameter(type='function',		id='start',			target='start',			name='record start')]
	[Parameter(type='function',		id='stop',			target='stop',			name='record stop')]
	[Parameter(type='function',		id='clear',			target='clear',			name='clear')]
	[Parameter(type='number',		id='maxFrames',		target='maxFrames',		reset='300', clamp='1,500')]
	[Parameter(type='blendMode',	id='blend',			target='blend')]
	
	/**
	 * 	@public
	 */
	public final class LoopMachine extends PluginPatchCPU {
		
		/**
		 * 	@private
		 */
		private static const STATE_PLAYBACK:int		= 0;
		private static const STATE_RECORDING:int	= 1;
		private static const STATE_OVERLAY:int		= 2;
		
		/**
		 * 	@private
		 */
		parameter var blend:IPluginBlendCPU		= Onyx.CreateInstance('Onyx.Display.Blend.Lighten::CPU') as IPluginBlendCPU;
		
		/**
		 * 	@private
		 */
		parameter var maxFrames:int				= 300;
		
		/**
		 * 	@private
		 */
		private var state:int					= STATE_PLAYBACK;
		
		/**
		 * 	@private
		 */
		parameter var targetChannel:IChannelCPU;
		
		/**
		 * 	@private
		 */
		private var currentFrame:int;
		
		/**
		 * 	@private
		 */
		private const frames:Array				= [];

		/**
		 * 	@public
		 */
		override public function initialize(context:IDisplayContextCPU, channel:IChannelCPU, path:IFileReference, content:Object):PluginStatus {
			
			// set our size to the context size
			dimensions.width 		= context.width;
			dimensions.height		= context.height;
			
			// success
			return super.initialize(context, channel, path, content);
		}
		
		/**
		 * 	@parameter
		 */
		parameter function start():void {
			
			// record!
			currentFrame = 0;

		}
		
		/**
		 * 	@private
		 */
		private function handleRender(e:OnyxEvent):void {
		} 
		
		/**
		 * 	@parameter
		 */
		parameter function stop(createSheet:Boolean = true):void {
			state = STATE_PLAYBACK;
		}
		
		/**
		 * 	@public
		 */
		override protected function validate(invalidParameters:Object):void {
			if (invalidParameters.blend && blend) {
				blend.initialize(context);
			}
		}
		
		/**
		 * 	@public
		 */
		override public function update(time:Number):Boolean {
			return true;
		}
		
		/**
		 * 	@public
		 */
		override public function render(context:IDisplayContextCPU):Boolean {
			var frame:DisplaySurface	= frames[currentFrame];
			if (frame) {
				context.copyPixels(frame);	
				return true;
			}
			return false;
		}
		
		/**
		 * 	@public
		 */
		override public function dispose():void {
			
			// clear
			stop(false);
			
			// dispose
			super.dispose();
			
		}
	}
}