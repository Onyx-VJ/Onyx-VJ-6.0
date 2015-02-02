package {
	
	import flash.display.*;
	import flash.events.*;
	import flash.media.*;
	import flash.net.*;
	import flash.utils.*;
	
	[SWF(frameRate='30', width='1280', height='360', backgroundColor='0x666666')]
	final public class StreamingFLVTest extends Sprite {
		
		private static function createConnection():NetConnection {
			const conn:NetConnection = new NetConnection();
			conn.connect(null);
			return conn;
		}
		
		private var videoBytes:ByteArray;
		
		private const stream:NetStream			= new NetStream(createConnection());
		private const video:Video				= new Video(640, 360);
		private const videoTags:Vector.<FLVTag>	= new Vector.<FLVTag>();
		private const initTags:Vector.<FLVTag>	= new Vector.<FLVTag>();
		private var current:int					= 0;
		private var offset:uint;
		private var startTime:uint;
		private var lastTag:FLVTag;
		public var frameRate:Number				= 1.0;
		private const loader:URLLoader			= new URLLoader();
		private const bitmap:BitmapData			= new BitmapData(640, 360);
		
		public function StreamingFLVTest() {
			
			stage.scaleMode	= StageScaleMode.NO_SCALE;
			stage.align		= StageAlign.TOP_LEFT;
			stage.nativeWindow.activate();
			
			video.attachNetStream(stream);
			addChild(video);
			addChild(new Bitmap(bitmap));
		
			loader.dataFormat		= URLLoaderDataFormat.BINARY;
			loader.addEventListener(Event.COMPLETE, handleLoader);
			loader.load(new URLRequest('videoplayback_1.flv'));
			
		}
		
		private function handleLoader(e:Event):void {
			loader.removeEventListener(Event.COMPLETE, handleLoader);
			
			videoBytes = (loader.data as ByteArray);
			
			init();
		}
		
		private function init():void {
			
			// stream.checkPolicyFile = true;
			stream.client = { onMetaData: function(info:Object):void {
				
				for (var i:String in info) {
					trace(i, info[i]);
				}
				
			}};
			
			var reader:FLVTagReader		= new FLVTagReader();
			var tags:Vector.<FLVTag>	= reader.analyze(videoBytes);
			var bytes:ByteArray			= new ByteArray();
			bytes.endian				= Endian.BIG_ENDIAN;
			var lastKey:FLVTag;
			
			for each (var tag:FLVTag in tags) {
				
				if (tag.type === FLVTag.VIDEO) {
					
					switch (tag.flags) {
						case FLVTag.FLAG_KEYFRAME:
							
							lastKey = tag;
							videoTags.push(tag);
							
							break;
					}
					
				} else {
					initTags.push(tag);
				}
				
			}
			
			loadKeyFrame();
		}
		
		/**
		 * 	@private
		 */
		private function writeFLVHeader(bytes:ByteArray, writeMeta:Boolean = false):void {
			
			bytes.writeUTFBytes('FLV');
			bytes.writeByte(1);
			bytes.writeByte(1);
			bytes.writeUnsignedInt(9);
			
			// k now add other tags
			if (writeMeta) {
				for each (var tag:FLVTag in initTags) {
					addMeta(tag);
				}
			}
		}
		
		/**
		 * 	@private
		 */
		private function loadKeyFrame():void {
			
			stream.addEventListener(NetStatusEvent.NET_STATUS, function(e:NetStatusEvent):void {
				
				switch (e.info.code) {
					case 'NetStream.Video.DimensionChange':
						
						for (var i:String in e.info) {
							trace(i, e.info[i]);
						}
						
						break;
				}
				trace(e.info.code);
			});
			stream.play(null);
			
			addFrame(videoTags[current], true);
			
			addEventListener(Event.ENTER_FRAME, handleRandomFrame);
		}
		
		/**
		 * 	@private
		 */
		private function addMeta(tag:FLVTag):void {
			
			const bytes:ByteArray	= new ByteArray();
			bytes.endian			= Endian.BIG_ENDIAN;
			
			// write last tag length
			bytes.writeUnsignedInt(lastTag ? lastTag.length : 0);
			
			// write the tag
			bytes.writeBytes(videoBytes, tag.position, tag.length);
			
			// append
			stream.appendBytes(bytes);
			
			// lasttag
			lastTag					= tag;
		}
		
		/**
		 * 	@private
		 */
		private function addFrame(tag:FLVTag, reset:Boolean = false):void {

			const bytes:ByteArray	= new ByteArray();
			bytes.endian			= Endian.BIG_ENDIAN;
			
			var timeOffset:uint		= 8;	// the timestamp 
			
			if (reset) {
				
				trace('reset', true);
				
				// last tag is nothing
				lastTag			= null;	
				
				// current time is now
				startTime		= getTimer();
				
				// send a reset
				stream.appendBytesAction(NetStreamAppendBytesAction.RESET_BEGIN);
				
				// write out header
				writeFLVHeader(bytes);
				
				// our header is a little further 
				timeOffset	+= bytes.length;

			}
			
			// write last tag length
			bytes.writeUnsignedInt(lastTag ? lastTag.length : 0);
			
			// write the tag
			bytes.writeBytes(videoBytes, tag.position, tag.length);
			
			var time:uint	= getTimer() - startTime;
			bytes.position = timeOffset;
			
			// write the current timestamp
			bytes.writeByte((time & 0xFF0000) >> 16);
			bytes.writeByte((time & 0x00FF00) >> 8);
			bytes.writeByte((time & 0x0000FF) >> 0);
			
			// append
			stream.appendBytes(bytes);
			
			// store tag
			lastTag = tag;
			
		}
		
		private function handleRandomFrame(e:Event):void {
			
			var start:int = getTimer();
			
			if (--current < 0) {
				current = videoTags.length - 1;
			}

			// add current frame
			addFrame(videoTags[current]);
			
			try {
				
				bitmap.lock();
				bitmap.draw(video);
				bitmap.unlock();
				
			} catch (e:Error) {
				trace(e);
			}
			
		}
		
		/**
		 * 	@private
		 */
		private function pad(input:String, length:uint = 8):String {
			while (input.length < length) {
				input = '0' + input;
			}
			return input;
		}
	}
}