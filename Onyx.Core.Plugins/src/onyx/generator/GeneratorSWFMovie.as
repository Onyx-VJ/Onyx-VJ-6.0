package onyx.generator {

	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.media.*;
	
	import onyx.*;
	import onyx.core.*;
	import onyx.display.*;
	import onyx.plugin.*;
	import onyx.util.*;
	
	use namespace parameter;
	
	[PluginInfo(
		id					= 'Onyx.Generator.SWFMovie',
		name				= 'SWFMovie',
		vendor				= 'Daniel Hai',
		version				= '1.0',
		description 		= 'SWFMovie Generator',
		defaultFileTypes	= 'swf',
		cacheContent		= 'true'
	)]
	
	final public class GeneratorSWFMovie extends PluginGeneratorTransformCPU implements IPluginGeneratorCPU {


		/**
		 * 	@private
		 */
		private var movie:MovieClip;
		
		/**
		 * 	@private
		 */
		private var frame:int					= 1;
		
		/**
		 * 	@private
		 */
		private var lastFrame:int;
		
		/**
		 * 	@private
		 */
		private var info:LoaderInfo;

		/**
		 * 	@public
		 */
		override public function initialize(context:IDisplayContextCPU, channel:IChannelCPU, file:IFileReference, content:Object):PluginStatus {
			
			this.info			= content as LoaderInfo;
			if (!info) {
				return new PluginStatus('Not LoaderInfo');
			}
			
			movie				= info.content as MovieClip;
			
			// we're not sharing
			if (!movie) {
				return new PluginStatus('No movie!');
			}
			
			// store the dimensions
			dimensions.width		= info.width;
			dimensions.height		= info.height;
			
			// stop
			movie.stop();
			
			// success
			return super.initialize(context, channel, file, content);
		}
		
		/**
		 * 	@public
		 */
		public function getTotalTime():int {
			return movie.totalFrames / info.frameRate * 1000;
		}
		
		/**
		 * 	@private
		 */
		public function update(time:Number):Boolean {

			frame = ((movie.totalFrames - 1) * time);
			
			return (lastFrame !== frame) || invalid;
		}
		
		/**
		 * 	@public
		 */
		public function render(context:IDisplayContextCPU):Boolean {

			// store last frame
			lastFrame		= frame;
			
			// stop
			movie.gotoAndStop(frame);
			
			// fill nothing
			context.clear();
			
			// transform
			context.draw(movie, renderMatrix, null, null, null, smoothing);
			
			// return
			return true;
		}
	}
}