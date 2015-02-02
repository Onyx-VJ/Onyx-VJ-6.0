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
			id			= 'Onyx.Generator.SWFMovie',
			name		= 'SWFMovie',
			vendor		= 'Daniel Hai',
			version		= '1.0',
			description = 'SWFMovie Generator'
	)]
	
	[Parameter(name='smoothing',	target='smoothing',						type='boolean')]
	[Parameter(name='scale',		target='matrix',						type='matrix/scale')]
	[Parameter(name='translate',	target='matrix',						type='matrix/translate')]
	final public class GeneratorSWFMovie extends PluginGenerator implements IPluginGenerator {
		
		/**
		 * 	@private
		 */
		private static const cache:SharedCache	= new SharedCache();
		
		/**
		 * 	@private
		 */
		private var movie:MovieClip;
		
		/**
		 * 	@private
		 */
		parameter var smoothing:Boolean			= true;
		
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
		 * 	@private
		 */
		private const renderMatrix:Matrix	= new Matrix();
		private const contentMatrix:Matrix	= new Matrix();
		
		/**
		 * 	@public
		 */
		override public function initialize(layer:IDisplayLayer, context:ContextBase):int {
			
			movie			= cache.retrieve(file.path, MovieClip) || cache.register(file.path, content) as MovieClip;
			
			// we're not sharing
			if (!movie) {
				return Plugin.INITIALIZE_FAILURE;
			}
			
			// set up info
			info					= movie.loaderInfo;
			totalTime				= movie.totalFrames / info.frameRate * 1000;
			
			// stop
			movie.stop();
			
			// success
			return super.initialize(layer, context);
		}
		
		/**
		 * 	@public
		 */
		public function get width():int {
			return info.width;
		}
		
		/**
		 * 	@public
		 */
		public function get height():int {
			return info.height;
		}
		
		/**
		 * 	@private
		 */
		public function update(time:Number):Boolean {

			frame				= ((movie.totalFrames - 1) * time) + 1;
			return invalid = invalid || (lastFrame !== frame);
		}
		
		/**
		 * 	@public
		 */
		override public function invalidate():void {
//			
//			// render matrix
//			renderMatrix.a	= contentMatrix.a;
//			renderMatrix.b	= 0;
//			renderMatrix.c	= 0;
//			renderMatrix.d	= contentMatrix.d;
//			
//			// offset center
//			renderMatrix.tx	= contentMatrix.tx + content.width * -0.5;
//			renderMatrix.ty	= contentMatrix.ty + content.height * -0.5;
//			
//			renderMatrix.concat(matrix);
//			
//			renderMatrix.tx	+= content.width * 0.5 * contentMatrix.a;
//			renderMatrix.ty	+= content.height * 0.5 * contentMatrix.d;
//			
//			// offset center
//			// renderMatrix.tx	+= content.width * .5 * contentMatrix.a;
//			// renderMatrix.ty	+= content.height * .5 * contentMatrix.d;
			
			invalid = true;
		}
		
		/**
		 * 	@public
		 */
		public function render(surface:SurfaceCPU):Boolean {
			
			// store last frame
			lastFrame		= frame;
			
			// stop
			movie.gotoAndStop(frame);
			
			// fill nothing
			surface.fillRect(context.rect, 0);
			
			// set matrix
			surface.draw(movie, null, null, null, null, true);
			
			// valid!
			invalid = false;
			
			// return
			return true;
		}
		
		/**
		 * 	@public
		 */
		override public function dispose():void {
			
			// release
			cache.release(file.path);
			
			// dispose
			super.dispose();

		}
	}
}