package onyx.core {
	
	import flash.events.*;
	import flash.utils.ByteArray;
	import flash.utils.IDataInput;
	import flash.utils.IDataOutput;
	
	[Compiler(Link)]
	
	[Event(name='close',			type='flash.events.Event')]
	[Event(name='complete',			type='flash.events.Event')]
	[Event(name='ioError',			type='flash.events.IOErrorEvent')]
	[Event(name='outputProgress',	type='flash.events.OutputProgressEvent')]
	[Event(name='progress',			type='flash.events.ProgressEvent')]
	
	public interface IFileStream extends IEventDispatcher, IDataInput, IDataOutput {

		function get position():Number;
		function set position(value:Number):void;

		function get file():IFileReference;

		function close():void;
		function truncate():void;

	}
}