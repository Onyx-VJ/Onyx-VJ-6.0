package
{
	import flash.display.Sprite;
	import flash.events.NetStatusEvent;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	
	[SWF(width='1024', height='768', frameRate='60')]
	public class RTMPTest extends Sprite {
		
		private const conn:NetConnection	= new NetConnection();
		private var stream:NetStream;
		private var video:Video;
		
		public function RTMPTest() {
			
			conn.addEventListener(NetStatusEvent.NET_STATUS, handleStatus);
			conn.connect('rtmp://localhost/live');
			
			stage.nativeWindow.activate();
			
		}
		
		private function handleStatus(event:NetStatusEvent):void {
			trace(event.info.code);
			switch (event.info.code) {
				case 'NetConnection.Connect.Success':
					
					stream = new NetStream(conn);
					stream.client = this;
					stream.bufferTime = 0;
					stream.play('livestream');
					
					break;
			}
		}
		
		/**
		 * 	@public
		 */
		public function onMetaData(info:Object):void {
			video = new Video(info.width, info.height);
			video.attachNetStream(stream);
			addChild(video);
			trace(info);
		}
	}
}