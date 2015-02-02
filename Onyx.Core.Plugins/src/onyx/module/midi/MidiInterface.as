package onyx.module.midi {
	
	import flash.desktop.*;
	import flash.events.*;
	import flash.filesystem.*;
	
	import onyx.core.*;
	import onyx.event.*;
	import onyx.parameter.*;
	import onyx.plugin.*;
	
	use namespace parameter;
	
	[PluginInfo(
		id				= 'Onyx.Interface.Midi',
		name			= 'Onyx.Interface.Midi',
		version			= '1.0',
		vendor			= 'Daniel Hai',
		description 	= 'Midi Interface'
	)]

	[Parameter(id='inputDevice', type='string', name='input device')]

	final public class MidiInterface extends PluginModule implements IPluginModuleInterface {
		
		/**
		 * 	@public
		 */
		public static const NOTE_OFF:int                  = 0x80;//128
		
		/**
		 * 	@public
		 */
		public static const NOTE_ON:int                   = 0x90;//144
		
		/**
		 * 	@public
		 */
		public static const POLYPHONIC_KEY_PRESSURE:int   = 0xa0;//160
		
		/**
		 * 	@public
		 */
		public static const CONTROL_CHANGE:int            = 0xb0;//176
		
		/**
		 * 	@public
		 */
		public static const PROGRAM_CHANGE:int            = 0xc0;//192
		
		/**
		 * 	@public
		 */
		public static const KEY_PRESSURE:int              = 0xd0;//208
		
		/**
		 * 	@public
		 */
		public static const PITCH_WHEEL:int               = 0xe0;//224
		
		/**
		 * 	@private
		 */
		private const MESSAGE:InterfaceMessage				= new InterfaceMessage();
		
		/**
		 * 	@private
		 */
		private const MESSAGE_EVENT:InterfaceMessageEvent	= new InterfaceMessageEvent(MESSAGE);
		
		/**
		 * 	@private
		 */
		private static const STATE_INITIALIZING:uint		= 0x00000000;
		
		/**
		 * 	@private
		 */
		private static const STATE_LISTENING:uint 			= 0x00000001;
		
		/**
		 * 	@private
		 */
		private var process:NativeProcess;
		
		/**
		 * 	@private
		 */
		private var processInfo:NativeProcessStartupInfo;
		
		private var closed:Boolean;
		
		/**
		 * 	@private
		 */
		private var state:uint								= STATE_INITIALIZING;
		
		/**
		 * 	@private
		 */
		private const input:Vector.<String>					= new Vector.<String>();
		
		/**
		 * 	@private
		 */
		private const bindings:Object						= {};
		
		/**
		 * 	@private	
		 */
		parameter var inputDevice:String;
		
		/**
		 * 	@public
		 */
		public function formatMessage(key:uint):String {
			
			switch ((key & 0xFF00) >> 8) {
				case CONTROL_CHANGE:
					return 'Control Change:'	+ (key & 0xFF).toString();
				case PITCH_WHEEL:
					return 'Pitch Wheel:'		+ (key & 0xFF).toString();
				case PROGRAM_CHANGE:
					return 'Program Change:'	+ (key & 0xFF).toString();
				case KEY_PRESSURE:
					return 'Key Pressure:'		+ (key & 0xFF).toString();
					
			}
			
			return 'Unknown:' + key.toString(16);
		}
		
		/**
		 * 	@public
		 * 	Initializes the modules
		 */
		public function initialize():PluginStatus {
			
			var target:File						= new File(FileSystem.GetFileReference('/onyx/data/Onyx.Interface.Midi/MidiPipe.exe').nativePath);
			if (!target.exists) {
				return new PluginStatus('Midi Executable not found');
			}
			
			// start the executable
			processInfo							= new NativeProcessStartupInfo();
			processInfo.executable				= target;
			
			process								= new NativeProcess();
			process.addEventListener(Event.STANDARD_INPUT_CLOSE,			handleClose);
			process.addEventListener(Event.STANDARD_ERROR_CLOSE,			handleClose);
			process.addEventListener(Event.STANDARD_OUTPUT_CLOSE,			handleClose);
			process.addEventListener(ProgressEvent.STANDARD_OUTPUT_DATA,	onOutputData);
			process.addEventListener(ProgressEvent.STANDARD_ERROR_DATA,		onErrorData);
			process.addEventListener(NativeProcessExitEvent.EXIT,			onExit);
			process.addEventListener(IOErrorEvent.STANDARD_OUTPUT_IO_ERROR,	onIOError);
			process.addEventListener(IOErrorEvent.STANDARD_ERROR_IO_ERROR,	onIOError);
			process.start(processInfo);
			
			// store origin
			MESSAGE.origin = this;
			
			// send command
			sendCommand('list');
			
			// ok
			return PluginStatus.ASYNC;
		}
		
		/**
		 * 	@private
		 */
		private function handleCreate(e:OnyxEvent):void {
			// trace(e);
		}
		
		/**
		 * 	@public
		 */
		public function get priority():int {
			return 0;
		}
		
		/**
		 * 	@public
		 */
		public function start():void {
	
			Console.Log(CONSOLE::MESSAGE,		'Midi Module Starting');

			// Console.Log(CONSOLE::DEBUG,		'Input Devices: \t' + input.join('\n\t') + '\n');
			// Console.Log(CONSOLE::DEBUG,		'Output Devices: \t' + output.join('\n\t') + '\n');
		}
		
		/**
		 * 	@private
		 */
		private function handleClose(e:Event):void {
			closed = true;
			// Console.LogError(e);
		}
		
		/**
		 * 	@private
		 */
		private function onOutputData(event:ProgressEvent):void {
			
			var data:String = process.standardOutput.readUTFBytes(process.standardOutput.bytesAvailable);
			if (data.length > 5) {
				var tokens:Array	 = data.split('\n');
				for each (var token:String in tokens) {
					switch (token.substr(0, 4)) {
//						case '--OT':
//							output.push(token.substr(5));
//							break;
						case '--IN':
							input.push(token.substr(5));
							break;
						case '--OK':
							return finishCommand();
						default:

							// this is a midi message
							if (token.charCodeAt(0) === 33) {
								
								// parse tokens
								parseMessage(token);

							}
					}
				}
			}
		}
		
		/**
		 * 	@private
		 */
		private function parseMessage(token:String):void {
			
			var i:int			= token.indexOf(' ');
			var p1:uint 		= uint('0x' + token.substr(1, i - 1));
			
			var data2:uint		= (p1 & 0x00FF0000) >> 16;
			var data1:uint		= (p1 & 0x0000FF00) >> 8;
			var status:uint		= (p1 & 0x000000FF);
			var key:uint		= ((status & 0xFF) << 8) | data1 & 0xFF;
			
			MESSAGE.key			= key;
			
			// status
			switch (status & 0xF0) {
				case CONTROL_CHANGE:
					MESSAGE.value	= (data2 & 0x0000FF) / 127;
					break;
				case NOTE_ON:
					MESSAGE.value	= 1.0;
					break;
				case NOTE_OFF:
					MESSAGE.value	= 0.0;
					break;
				case PITCH_WHEEL:
					MESSAGE.value	= (data2 & 0x0000FF) / 127;
					break;
			}
			
			// dispatch
			if (Onyx.dispatchEvent(MESSAGE_EVENT)) {
				
				var binding:IMidiBinding = bindings[key];
				if (!binding) {
					return;
				}
				
				// execute!
				binding.exec(MESSAGE.value);

			}
		}
		
		/**
		 * 	@private
		 */
		private function finishCommand():void {
			
			// initializing
			switch (state) {
				case STATE_INITIALIZING:

					// we're ok
					dispatchEvent(new PluginStatusEvent(PluginStatusEvent.STATUS, PluginStatus.OK));
					
					if (input.length > 0) {
						sendCommand('inpt', input[0]);
					}
					
					// listen
					state = STATE_LISTENING;

					break;
			}
		}
		
		private function sendCommand(command:String, ... args:Array):void {
			
			if (closed) {
				return;
			}
			
			// write bytes
			process.standardInput.writeUTFBytes(command + (args.length ? ' ' + args.join(' ') : '') + '\n');
			
			trace('sending', command, args);
		}
		
		private function onErrorData(event:ProgressEvent):void {
			trace("ERROR -", process.standardError.readUTFBytes(process.standardError.bytesAvailable)); 
		}
		
		private function onExit(event:NativeProcessExitEvent):void {
			trace("Process exited with ", event.exitCode);
		}
		
		private function onIOError(event:IOErrorEvent):void {
			trace(event.toString());
		}
		
		/**
		 * 	@public
		 */
		public function stop():void {
			
			if (process) {
				
				sendCommand('exit');
				
				process.removeEventListener(ProgressEvent.STANDARD_OUTPUT_DATA,		onOutputData);
				process.removeEventListener(ProgressEvent.STANDARD_ERROR_DATA,		onErrorData);
				process.removeEventListener(NativeProcessExitEvent.EXIT,			onExit);
				process.removeEventListener(IOErrorEvent.STANDARD_OUTPUT_IO_ERROR,	onIOError);
				process.removeEventListener(IOErrorEvent.STANDARD_ERROR_IO_ERROR,	onIOError);
				process.exit();
			}
			
		}
		
		
		/**
		 * 	@public
		 * 	Keyboard does not support parameter binding
		 */
		public function bind(key:uint, data:*):void {
			
			// already has a binding
			if (bindings[key]) {
				bindings[key].dispose();
			}
			
			if (data is IParameterNumeric) {
				bindings[key] = new MidiNumericBinding(data);
			} else if (data is IParameterIterator) {
				bindings[key] = new MidiIteratorBinding(data);
			}
		}
		
		/**
		 * 	@public
		 */
		public function unbind(key:uint):void {
			
			if (bindings[key]) {
				var binding:IMidiBinding = bindings[key]; 
				delete bindings[key];
				binding.dispose();
			}
		}
		
		/**
		 * 	@public
		 * 	Keyboard can only bind on executable items
		 */
		public function canBind(data:*):Boolean {
			return (data is IParameterNumeric || data is IParameterIterator);
		}
		
		/**
		 * 	@public
		 */
		public function addDispatcher(i:IEventDispatcher):void {
			
			// this is useless, since there is only one midi module
			// keyboard has to attach to stage, so there are multiple stages
			
		}
	}
}

final class NumericBinding {
	
	public function exec():void {
		
	}
}