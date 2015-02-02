package onyx.device.capture {
	
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.media.*;
	
	import onyx.*;
	import onyx.core.*;
	import onyx.display.*;
	import onyx.plugin.*;
	import onyx.util.*;
	import onyx.util.encoding.Serialize;
	
	use namespace parameter;
	
	[PluginInfo(
		id					= 'Onyx.Generator.Capture',
		name				= 'Image',
		vendor				= 'Daniel Hai',
		version				= '1.0',
		description 		= 'Capture Generator',
		depends				= 'Onyx.Device.Capture'
	)]
	
	final public class CaptureGenerator extends PluginGeneratorTransformCPU implements IPluginGeneratorCPU {
		
		/**
		 * 	@private
		 */
		private var camera:Camera;
		
		/**
		 * 	@private
		 */
		private var video:Video;
		
		/**
		 * 	@private
		 */
		private var halfH:Boolean	= true;
		
		/**
		 * 	@public
		 */
		override public function initialize(context:IDisplayContextCPU, channel:IChannelCPU, path:IFileReference, content:Object):PluginStatus {
			
			var capture:CaptureDeviceReference	= path as CaptureDeviceReference;
			if (!capture) {
				return new PluginStatus('ERROR!');
			}
			
			camera = Camera.getCamera(capture.index);
			if (!camera) {
				return new PluginStatus('Camera Invalid');
			}
			
			var settings:Object = capture.preferences;
			
			camera.setMotionLevel(100, 0);
			camera.setQuality(0, 100);
			camera.setCursor(false);
			camera.setMode(settings.width || 320, settings.height || 240, settings.frameRate || 30);
			
			// store the dimensions
			dimensions.width		= camera.width * (halfH ? 0.5 : 1);
			dimensions.height		= camera.height * (halfH ? 0.5 : 1);
			
			video			= new Video(dimensions.width, dimensions.height);
			video.attachCamera(camera);
			video.smoothing = true;
			
			// initializing
			Console.Log(CONSOLE::MESSAGE, 'Initializing Capture', camera.name, camera.width + 'x' + camera.height);
			
			// success
			return super.initialize(context, channel, path, content);
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
		public function get width():Number {
			return camera.width;
		}
		
		/**
		 * 	@public
		 */
		public function get height():Number {
			return camera.height;
		}
		
		/**
		 * 	@public
		 */
		public function update(time:Number):Boolean {
			// always update
			return true;
		}
		
		/**
		 * 	@public
		 */
		public function render(context:IDisplayContextCPU):Boolean {
			
			context.clear();
			context.draw(video, renderMatrix, null, null, null, true);
			
			// return
			return true;
		}
		
		/**
		 * 	@public
		 */
		override public function dispose():void {
			
			video.attachCamera(null);
			video = null;
			
			super.dispose();
		}
	}
}