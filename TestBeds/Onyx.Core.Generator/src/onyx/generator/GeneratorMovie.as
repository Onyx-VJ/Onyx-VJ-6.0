package onyx.generator {
	
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.media.*;
	import flash.net.*;
	
	import onyx.*;
	import onyx.core.*;
	import onyx.display.*;
	import onyx.filesystem.*;
	import onyx.media.MediaStream;
	import onyx.plugin.*;
	
	use namespace parameter;
	
	[PluginInfo(
		id			= 'Onyx.Generator.Movie',
		name		= 'Onyx.Generator.Movie',
		vendor		= 'Daniel Hai',
		version		= '1.0',
		description = 'Movie Generator'
	)]
	
	[Parameter(name='smoothing',	target='smoothing',				type='boolean')]
	[Parameter(name='volume',		target='soundTransform/volume',	type='number', clamp='0,1', reset='1')]
	
	final public class GeneratorMovie extends PluginGenerator implements IPluginGenerator {
		
		/**
		 * 	@private
		 */
		private static const STREAM_INITIALIZING:uint	= 0;
		
		/**
		 * 	@private
		 */
		private static const STREAM_READY:uint 			= 0x01;
		
		/**
		 * 	@private
		 */
		parameter const soundTransform:SoundTransform = new SoundTransform();
		
		/**
		 * 	@private
		 */
		private var stream:MediaStream;
		
		/**
		 * 	@private
		 */
		private var metadata:Object;
		
		/**
		 * 	@private
		 */
		private var videoWidth:int;
		
		/**
		 * 	@private
		 */
		private var videoHeight:int;
		
		/**
		 * 	@private
		 */
		private var video:Video;
		
		/**
		 * 	@private
		 */
		private var state:uint;
		
		/**
		 * 	@private
		 */
		private var lastUpdate:int;
		
		/**
		 * 	@private
		 */
		parameter var smoothing:Boolean	= true;
		
		/**
		 * 	@public
		 */
		override public function initialize(layer:IDisplayLayer, context:ContextBase):int {
			
			stream		= content as MediaStream;
			trace('MOVIE INIT', content, stream, content is IMediaStream);
			if (!stream) {
				return Plugin.INITIALIZE_FAILURE;
			}
			
			// add
			stream.addEventListener(NetStatusEvent.NET_STATUS, handleStatus);
			
			// get metadata
			metadata				= stream.metadata;
			videoWidth				= metadata.width;
			videoHeight				= metadata.height;
			totalTime				= metadata.duration * 1000;
			
			video					= new Video(videoWidth, videoHeight);
			video.attachNetStream(stream);
			video.smoothing			= true;
			
			stream.soundTransform	= soundTransform;
			stream.inBufferSeek		= true;
			stream.bufferTime		= 30;
			
			trace(stream.bufferTime, stream.bufferLength);
			
			// ?
			stream.resume();

			// resume
			// stream.resume();
			
			// set matrix
			// context.setMatrix(matrix, videoWidth, videoHeight);

			// success
			return super.initialize(layer, context);
		}
		
		/**
		 * 	@override
		 */
		override public function invalidate():void {
			
			stream.soundTransform = soundTransform;
			
			invalid = false;
		}
		
		/**
		 * 	@public
		 */
		public function get width():int {
			return videoWidth;
		}
		
		/**
		 * 	@public
		 */
		public function get height():int {
			return videoHeight;
		}

		/**
		 * 	@public
		 */
		private function handleStatus(event:NetStatusEvent):void {
			
			// trace(event.info.code);
			
//			
//			switch (event.info.code) {
//				case 'NetStream.Play.Complete':
//					stream.seek(0);
//					break;
//			}

		}
		
		/**
		 * 	@private
		 */
		private function startStream():void {
			
			// ok here we need to listen for crap
			// stream
		}
		
		/**
		 * 	@private
		 */
		private function frame(event:Event):void {
			
			if (stream.currentFPS > 0) {
				state = STREAM_READY;
				context.stage.removeEventListener(Event.ENTER_FRAME, frame);
			}
		}
		
		/**
		 * 	@public
		 */
		public function update(time:Number):Boolean {
			
			// crap this don't work
			// stream.seek(time * totalTime / 1000);
			
			return true; // = invalid || (state === STREAM_READY && (TimeStamp - lastUpdate) > stream.currentFPS);
		}

		/**
		 * 	@public
		 */
		public function render(surface:SurfaceCPU):Boolean {
			
			surface.fillRect(surface.rect, 0x00);
			surface.draw(video, null, null, null, null, true);
			
			// store last update time
			lastUpdate 		= TimeStamp;
			
			invalid = false;
			return true;
		}
		
		/**
		 * 	@public
		 */
		override public function dispose():void {
			
			if (stream) {
				stream.removeEventListener(NetStatusEvent.NET_STATUS, handleStatus);
				stream.close();
			}
			
			super.dispose();
		}
	}
}