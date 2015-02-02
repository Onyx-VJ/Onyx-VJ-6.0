package tests.net {
	
	import flash.events.NetStatusEvent;
	import flash.net.*;

	public class Stream extends NetStream {
		
		private static const DEFAULT_CONNECTION:NetConnection	= createDefault();
		
		private static function createDefault():NetConnection {
			const conn:NetConnection = new NetConnection();
			conn.connect(null);
			return conn;
		}
		
		public var metadata:Object;
		
		/**
		 * 	@public
		 */
		public function onMetaData(info:Object):void {
			
			metadata = info;
			dispatchEvent(new NetStatusEvent(NetStatusEvent.NET_STATUS, false, false, {
				code:	'NetStream.Play.Metadata'
			}));
		}
		
		/**
		 * 	@public
		 */
		public function onPlayStatus(info:Object):void {
			dispatchEvent(new NetStatusEvent(NetStatusEvent.NET_STATUS, false, false, info));
		}
		
		/**
		 * 	@public
		 */
		public function Stream():void {
			super(DEFAULT_CONNECTION);
		}
	}
}