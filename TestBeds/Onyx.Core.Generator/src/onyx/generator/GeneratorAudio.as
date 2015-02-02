package onyx.generator {
	
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.media.*;
	
	import onyx.*;
	import onyx.core.*;
	import onyx.display.*;
	import onyx.plugin.*;
	
	use namespace parameter;
	
	[PluginInfo(
		id			= 'Onyx.Generator.Audio',
		name		= 'Capture',
		vendor		= 'Daniel Hai',
		version		= '1.0',
		description = 'Capture Generator'
	)]

	/**
	 *	@public 
	 */
	final public class GeneratorCapture extends PluginGenerator implements IPluginGenerator {
		
		/**
		 * 	@public
		 */
		override public function initialize(layer:Layer, context:ContextCPU, content:Object):int {

			// return
			return Plugin.INITIALIZE_SUCCESS;
		}

		/**
		 * 	@public
		 */
		public function update(time:Number):void {
		}
		
		/**
		 * 	@public
		 */
		public function render(surface:SurfaceCPU):void {
			
			surface.fillRect(context.rect, 0);
			
		}
		
		/**
		 * 	@public
		 */
		override public function get path():String {
			return camera.name;
		}
		
		/**
		 * 	@public
		 */
		public function serialize():Object {
			return null;
		}
		
		/**
		 * 	@public
		 */
		override public function dispose():void {
			
			super.dispose();
			
			// TODO, SHARE THE VIDEO OBJECTS
			video.attachCamera(null);
			video = null;
			camera = null;
			
		}
	}
}