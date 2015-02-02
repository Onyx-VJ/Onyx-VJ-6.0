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
		id					= 'Onyx.Generator.Image',
		name				= 'Image',
		vendor				= 'Daniel Hai',
		version				= '1.0',
		description 		= 'Image Generator',
		defaultFileTypes	= 'png;jpg;jpeg;gif',
		cacheContent		= 'true'
	)]
	final public class GeneratorImage extends PluginGeneratorTransformCPU implements IPluginGeneratorCPU {

		/**
		 * 	@private
		 */
		private var bitmap:BitmapData;
		
		/**
		 * 	@private
		 */
		private var newFrame:Boolean = true;
		
		/**
		 * 	@private
		 */
		private var content:LoaderInfo;
	
		/**
		 * 	@public
		 */
		override public function initialize(context:IDisplayContextCPU, channel:IChannelCPU, path:IFileReference, content:Object):PluginStatus {
			
			this.content		= content as LoaderInfo;
			
			var bitmap:Bitmap	= (content.content as Bitmap);
			if (!bitmap) {
				return new PluginStatus('Loaded Content is not a Bitmap!');
			}
			
			this.bitmap			= bitmap.bitmapData;
			
			// save dimensions
			dimensions.width	= bitmap.width;
			dimensions.height	= bitmap.height;
			
			// success
			return super.initialize(context, channel, path, content);
		}
		
		/**
		 * 	@public
		 */
		public function get width():int {
			return dimensions.width;
		}
		
		/**
		 * 	@public
		 */
		public function get height():int {
			return dimensions.height;
		}
		
		/**
		 * 	@public
		 */
		public function getTotalTime():int {
			return 0;
		}
		
		/**
		 * 	@public
		 */
		public function update(time:Number):Boolean {
			
			// don't do anything -- since there is no time for images
			return invalid;
		}
		
		/**
		 * 	@public
		 */
		public function render(context:IDisplayContextCPU):Boolean {
			
			context.clear();
			context.draw(bitmap, renderMatrix, null, null, null, smoothing);

			// return
			return true;
		}
	}
}