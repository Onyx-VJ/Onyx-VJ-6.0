package onyx.generator {
	
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.media.*;
	import flash.net.*;
	
	import onyx.*;
	import onyx.core.*;
	import onyx.display.*;
	import onyx.media.MediaStream;
	import onyx.parameter.IParameter;
	import onyx.plugin.*;
	
	use namespace parameter;
	
	[PluginInfo(
		id					= 'Onyx.Generator.Movie',
		name				= 'Onyx.Generator.Movie',
		vendor				= 'Daniel Hai',
		version				= '1.0',
		description 		= 'Movie Generator',
		defaultFileTypes	= 'flv;f4v'
	)]
	
	final public class GeneratorMovie extends PluginGeneratorTransformCPU implements IPluginGeneratorCPU {
		
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
		private var content:IMediaStream;
		
		/**
		 * 	@public
		 */
		override public function initialize(context:IDisplayContextCPU, channel:IChannelCPU, path:IFileReference, content:Object):PluginStatus {
			
			this.content	= content as IMediaStream;
			if (!stream) {
				return new PluginStatus('No Stream');
			}
			
			// add
			stream.addEventListener(NetStatusEvent.NET_STATUS, handleStatus);
			
			// get metadata
			metadata				= stream.metadata;
			videoWidth				= metadata.width;
			videoHeight				= metadata.height;
			
			video					= new Video(videoWidth, videoHeight);
			// video.addEventListener(Event.VIDEO_FRAME, handleFrame);
			video.attachNetStream(stream);
			video.smoothing			= true;
			
			stream.soundTransform	= soundTransform;
			stream.inBufferSeek		= true;
			stream.bufferTime		= 30;
						
			// ?
			stream.resume();

			// resume
			// stream.resume();
			
			// set matrix
			// context.setMatrix(matrix, videoWidth, videoHeight);

			// success
			return super.initialize(context, channel, file, content);
		}
		
		
		/**
		 * 	@public
		 */
		public function getTotalTime():int {
			return metadata.duration ? metadata.duration * 1000 : 0; 
		}
		
		/**
		 * 	@public
		 */
		public function get width():Number {
			return videoWidth;
		}
		
		/**
		 * 	@public
		 */
		public function get height():Number {
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
//				context.stage.removeEventListener(Event.ENTER_FRAME, frame);
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
		public function render(context:IDisplayContextCPU):Boolean {
			
			context.clear();
			context.draw(video, renderMatrix, null, null, null, smoothing);
			
			// store last update time
			lastUpdate 		= TimeStamp;
			
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