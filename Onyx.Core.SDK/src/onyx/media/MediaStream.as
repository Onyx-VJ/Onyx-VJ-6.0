package onyx.media {
	
	import flash.events.*;
	import flash.net.*;
	
	import onyx.core.*;

	final public class MediaStream extends NetStream {
		
		/**
		 * 	@private
		 */
		private static function createDefaultConnection():NetConnection {
			const conn:NetConnection = new NetConnection();
			conn.connect(null);
			return conn;
		}
		
		/**
		 * 	@public 
		 */
		public static const HTTP:NetConnection	= createDefaultConnection();
		
		/**
		 * 	@private
		 */
		public var metadata:Object;
		
		/**
		 * 	@public
		 */
		public var path:String;
		
		/**
		 * 	@public
		 */
		public function MediaStream(conn:NetConnection = null):void {
			super(conn || HTTP);
			this.addEventListener(AsyncErrorEvent.ASYNC_ERROR, handleError);
		}
		
		/**
		 * 	@private
		 */
		private function handleError(event:AsyncErrorEvent):void {
			// trace(event);
		}
		
		/**
		 * 	@public
		 */
		public function load(path:String):void {
			super.play(this.path = path);
		}
		
		// load
		CONFIG::DEBUG {
			override public function play(...parameters):void {
				throw new Error('USE LOAD INSTEAD');
			}
		}
		
		/**
		 * 	@public
		 */
		public function onPlayStatus(info:Object):void {
			dispatchEvent(new NetStatusEvent(NetStatusEvent.NET_STATUS, false, false, { code: 'NetStream.Play.Complete' }));
		}
		
		/**
		 * 	@public
		 */
		public function onMetaData(info:Object):void {
			
			this.metadata = info || {};
			dispatchEvent(new NetStatusEvent(NetStatusEvent.NET_STATUS, false, false, { code: 'NetStream.Play.Metadata' }));
		}
		
		/**
		 * 	@public
		 */
		public function onXMPData(info:Object):void {
			// this.metadata = info || {};
			dispatchEvent(new NetStatusEvent(NetStatusEvent.NET_STATUS, false, false, { code: 'NetStream.Play.XMPData' }));
		}
	}
}