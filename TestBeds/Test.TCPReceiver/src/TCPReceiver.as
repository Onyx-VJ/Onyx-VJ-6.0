package
{
	import flash.display.*;
	import flash.events.Event;
	import flash.events.ServerSocketConnectEvent;
	import flash.net.ServerSocket;
	import flash.net.Socket;
	import flash.text.TextField;
	import flash.utils.*;
	
	[SWF(width='1024', height='768', frameRate='30')]
	public class TCPReceiver extends Sprite
	{
		
		private const data:BitmapData		= new BitmapData(640,480,true,0);
		private const socket:ServerSocket	= new ServerSocket();
		private const clients:Vector.<Socket>	= new Vector.<Socket>();
		private const text:TextField			= addChild(new TextField()) as TextField;
		
		private const buffer:ByteArray		= new ByteArray();
		
		public function TCPReceiver()
		{
			text.width = 1024;
			text.height	= 768;
			stage.nativeWindow.activate();
			
			socket.addEventListener(ServerSocketConnectEvent.CONNECT, handleConnection);
			socket.bind(6473, '127.0.0.1');
			socket.listen();
			
			stage.nativeWindow.addEventListener(Event.CLOSING, function(e:Event):void {
				socket.close();
			});
			addChild(new Bitmap(data));
		}
		
		private function handleConnection(event:ServerSocketConnectEvent):void {
			text.appendText(event.toString() + '\n');
			clients.push(event.socket);
			
			addEventListener(Event.ENTER_FRAME, handleClient);
			// socket.addEventListener(
		}
		
		private function handleClient(event:Event):void 
		{
			var start:int = getTimer();
			var socket:Socket= clients[0];
			if (socket.connected) {
				// text.appendText(socket.bytesAvailable + '\n');
				
				if (socket.bytesAvailable >= 640 * 480 * 4) {
					socket.readBytes(buffer);
					buffer.position = 0;
					data.lock();
					data.setPixels(data.rect, buffer);
					data.unlock();
				}
			}
		}
	}
}