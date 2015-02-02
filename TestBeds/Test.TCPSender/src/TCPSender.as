package
{
	import flash.display.*;
	import flash.events.Event;
	import flash.net.Socket;
	import flash.text.TextField;
	import flash.utils.ByteArray;
	
	[SWF(width='1024', height='768', frameRate='30')]
	public class TCPSender extends Sprite
	{
		
		private const data:BitmapData		= new BitmapData(640,480,false,0);
		private const socket:Socket			= new Socket();
		private const text:TextField		= addChild(new TextField()) as TextField;
		
		public function TCPSender()
		{
			text.width = 1024;
			text.height	= 768;
			stage.nativeWindow.activate();
			
			socket.addEventListener(Event.CONNECT, handleConnection);
			socket.addEventListener(Event.CLOSE, closing);
			socket.connect('127.0.0.1', 6473);
			
			stage.nativeWindow.addEventListener(Event.CLOSING, closing);
			
			addChild(new Bitmap(data));
		}
		
		private function closing(event:Event):void {
			
			removeEventListener(Event.ENTER_FRAME, handleClient);
			if (socket.connected) {
				socket.close();
			}
			
		}
		
		private function handleConnection(event:Event):void {
			
			text.appendText(event.toString() + '\n');
			
			addEventListener(Event.ENTER_FRAME, handleClient);
		}
		
		private function handleClient(event:Event):void 
		{
			data.fillRect(data.rect, Math.random() * 0xFFFFFF);
			var bytes:ByteArray = data.getPixels(data.rect);
			socket.writeBytes(bytes);
			socket.flush();
			
			trace(socket.bytesAvailable);
		}
	}
}