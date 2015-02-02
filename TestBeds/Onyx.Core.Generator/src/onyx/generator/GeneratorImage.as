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
		id			= 'Onyx.Generator.Image',
		name		= 'Image',
		vendor		= 'Daniel Hai',
		version		= '1.0',
		description = 'Image Generator',
		depends		= 'Onyx.GPU.Host'
	)]
	
	[Parameter(name='smoothing',	target='smoothing',		type='boolean')]
	[Parameter(name='scale',		target='matrix',		type='matrix/scale')]
	[Parameter(name='translate',	target='matrix',		type='matrix/translate')]
	final public class GeneratorImage extends PluginGenerator implements IPluginGenerator {
		
		/**
		 * 	@private
		 */
		private static const cache:SharedCache	= new SharedCache();

		/**
		 * 	@private
		 */
		private var imageData:BitmapData;

		/**
		 * 	@private
		 */
		parameter var smoothing:Boolean		= true;

		/**
		 * 	@private
		 */
		private var surface:SurfaceCPU;
		
		/**
		 * 	@private
		 */
		private var newFrame:Boolean = true;
		
		/**
		 * 	@public
		 */
		override public function initialize(layer:IDisplayLayer, context:ContextBase):int {

			// store the context
			this.context	= context;
			
			// store the bitmap
			this.imageData	= content as BitmapData; // cache.register(file.path, content) as BitmapData;
			this.surface	= SurfaceCPU.fromBitmapData(this.imageData);
			
			// we're not sharing
			if (!imageData) {
				return Plugin.INITIALIZE_FAILURE;
			}
			
			// invalidate
			invalid			= true;

			// success
			return super.initialize(layer, context);
		}
		
		/**
		 * 	@public
		 */
		public function get width():int {
			return imageData ? imageData.width : 0;
		}
		
		/**
		 * 	@public
		 */
		public function get height():int {
			return imageData ? imageData.height : 0;
		}
		
		/**
		 * 	@public
		 */
		public function update(time:Number):Boolean {
			
			// don't do anything -- since there is no time for images
			return newFrame;
		}
		
		/**
		 * 	@public
		 */
		public function render(surface:SurfaceCPU):Boolean {
			
			// draw the image data
			surface.fillRect(surface.rect, 0);
			surface.draw(imageData);
			
			// valid!
			invalid = false;

			// return
			return true;
		}

		/**
		 * 	@public
		 */
		override public function dispose():void {
			
			// relase the image
			if (imageData) {
				cache.release(file.path);
			}
			
			super.dispose();
		}
	}
}