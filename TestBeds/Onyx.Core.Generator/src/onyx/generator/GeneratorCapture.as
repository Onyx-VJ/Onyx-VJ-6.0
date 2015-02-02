package onyx.generator {
	
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.media.*;
	
	import onyx.core.*;
	import onyx.display.*;
	import onyx.event.*;
	import onyx.filesystem.*;
	import onyx.plugin.*;
	
	use namespace parameter;
	use namespace onyx_ns;
	
	[PluginInfo(
		id			= 'Onyx.Generator.Capture',
		name		= 'Capture',
		vendor		= 'Daniel Hai',
		version		= '1.0',
		description = 'Capture Generator',
		flags		= 'FRAMERATE_FULL'
	)]
	
	[Parameter(name='smoothing',		target='smoothing', 	type='boolean')]
	[Parameter(name='scale',			target='matrix',		type='matrix/scale')]
	[Parameter(name='translate',		target='matrix',		type='matrix/translate')]

	/**
	 * 	@public
	 */
	final public class GeneratorCapture extends PluginGenerator implements IPluginGenerator {

		/**
		 * 	@private
		 */
		private var camera:Camera;
		private var video:Video;
		private var lastUpdate:int;
		
		/**
		 * 	@private
		 */
		parameter var smoothing:Boolean;
		
		/**
		 * 	@private
		 */
		private const renderMatrix:Matrix	= new Matrix();
		private const contentMatrix:Matrix	= new Matrix();
		
		/**
		 * 	@public
		 */
		override public function setup(file:IFileReference, content:Object):void {
			
			// set up
			super.setup(file, content);
			
		}
		
		/**
		 * 	@public
		 */
		override public function initialize(layer:IDisplayLayer, context:ContextCPU):int {
			
			camera		= content as Camera;
			if (!camera) {
				return Plugin.INITIALIZE_FAILURE;
			}
			
			try {
				
				var settings:Object	= plugin.data[camera.name] || {};
				var width:int		= settings.width		|| context.width;
				var height:int		= settings.height		|| context.height;
				var frameRate:int	= settings.frameRate	|| 30;	

				camera.setMode(width, height, frameRate);
				camera.setMotionLevel(0, 250);
				camera.setQuality(0, 100);
				camera.addEventListener(ActivityEvent.ACTIVITY, dispatchEvent);
				
				Console.Log(Console.DEBUG, 'Capturing', camera.name, ':', camera.width + 'x' + camera.height);
				
				// camera.setMode(640, 480, 15, false);
				video			= new Video(camera.width, camera.height);
				
				// set matrix
				context.setMatrix(contentMatrix, camera.width, camera.height);
				
				// attach the camera
				video.attachCamera(camera);
				video.smoothing	= true;
				
			} catch (e:Error) {
				
				CONFIG::DEBUG {
					throw e;	
				}
				
				CONFIG::RELEASE {
					Console.Log(Console.ERROR, 'Capturing Camera Failed.', e.message);
				}
				
				return Plugin.INITIALIZE_FAILURE;
			}
			
			// return
			return Plugin.INITIALIZE_SUCCESS;
		}
		
		/**
		 * 	@public
		 */
		public function get width():int {
			return camera ? camera.width : 0;
		}
		
		/**
		 * 	@public
		 */
		public function get height():int {
			return camera ? camera.height : 0;
		}
		
		/**
		 * 	@public
		 */
		override public function unserialize(token:Object):Boolean {
			return super.unserialize(token);
		}
		
		/**
		 * 	@public
		 */
		override public function invalidate():void {
			
			invalid = true;
			if (!content) {
				return;
			}
			
			// render matrix
			renderMatrix.a	= 1;
			renderMatrix.b	= 0;
			renderMatrix.c	= 0;
			renderMatrix.d	= 1;

			// offset center
			renderMatrix.tx	= content.width * -0.5;
			renderMatrix.ty	= content.height * -0.5;
			
			renderMatrix.concat(matrix);
			renderMatrix.concat(contentMatrix);
			
			// offset center
			renderMatrix.tx	+= content.width * .5 * contentMatrix.a;
			renderMatrix.ty	+= content.height * .5 * contentMatrix.d;
		}

		/**
		 * 	@public
		 */
		public function update(time:Number):void {
			invalid	= true;
		}
		
		/**
		 * 	@public
		 */
		public function render(surface:SurfaceCPU):void {
			
			surface.fillRect(context.rect, 0);
			surface.draw(video, renderMatrix, null, null, null, true);
			
			// update
			lastUpdate = TimeStamp;
		}
		
		/**
		 * 	@public
		 */
		override public function dispose():void {
			
			if (camera) {
				camera.removeEventListener(ActivityEvent.ACTIVITY, dispatchEvent);
				camera = null;
			}
			
			// TODO, SHARE THE VIDEO OBJECTS
			if (video) {
				video.attachCamera(null);
				video = null;
			}
			camera = null;
			
			// dispose
			super.dispose();
			
		}
	}
}