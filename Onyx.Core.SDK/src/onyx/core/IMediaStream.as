package onyx.core {
	
	import flash.events.*;
	
	[Compiler(Link)]
	
	public interface IMediaStream extends IEventDispatcher {
		
		function get currentFPS():int;
		function get metadata():Object;
		function seek(time:Number):void;
		function close():void;
		function resume():void;
		
	}
}