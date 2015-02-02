package onyx.module.recording {
	
	import flash.display.*;
	import flash.events.*;
	import flash.utils.*;
	
	import onyx.core.*;
	import onyx.display.*;
	import onyx.event.*;
	import onyx.plugin.*;
	import onyx.service.*;
	import onyx.util.*;
	
	[PluginInfo(
		id				= 'Onyx.Service.RecordingService',
		name			= 'Onyx.Service.RecordingService',
		version			= '1.0',
		vendor			= 'Daniel Hai',
		description 	= 'Recording Service'
	)]
	
	final public class RecordingService extends PluginModule implements IPluginModule, IRecordService {
		
		
		/**
		 * 	@private
		 */
		private const size:Dimensions		= new Dimensions(112,63);
		
		/**
		 * 	@private
		 */
		private var recording:IChannelCPU;
		
		/**
		 * 	@private
		 */
		private var frames:Array		= [];
		
		/**
		 * 	@private
		 */
		private var time:String;
		
		/**
		 * 	@private
		 */
		private var index:int;
		
		/**
		 * 	@private
		 */
		private var current:RecordFrame;
		
		/**
		 * 	@public
		 * 	Initializes the modules
		 */
		public function initialize():PluginStatus {
			
			// ok?
			return PluginStatus.OK;
		}
		
		/**
		 * 	@public
		 */
		public function record(value:Boolean):void {
			
			if (!recording && value && !frames.length) {
				var display:IDisplay = Onyx.GetDisplay(0);
				display.getChannels();
				recording = Onyx.GetDisplay(0).getChannels()[Plugin.CPU] as IChannelCPU;
				if (recording) {
					recording.addEventListener(OnyxEvent.CHANNEL_RENDER_CPU, handleRecord);
				}
				
				time = String(new Date().time);
				
			} else if (recording && !value) {

				saveNext();
				
				recording.removeEventListener(OnyxEvent.CHANNEL_RENDER_CPU, handleRecord);
				recording = null;
			}
		}
		
		/**
		 * 	@private
		 */
		private function saveNext():void {
			
			if (current || !frames.length) {
				return;
			}
			
			current						= frames.pop();
			
			var stream:IFileStream		= FileSystem.CreateFileStream(FileSystem.GetFileReference('/onyx/data/' + this.id + '/' + time + '/' + current.index + '.jpg'), FileSystem.WRITE);
			stream.addEventListener(OutputProgressEvent.OUTPUT_PROGRESS, handleStream);
			stream.writeBytes(current.bytes);
			
			current.bytes.length = 0;
			current.bytes = null;
			
			Console.Log(CONSOLE::MESSAGE, 'Encoding', stream.file.path);
		}
		
		/**
		 * 	@private
		 */
		private function handleStream(e:OutputProgressEvent):void {
			if (e.bytesPending === 0) {
				
				var stream:IFileStream = e.currentTarget as IFileStream;
				Console.Log(CONSOLE::MESSAGE, 'Finished', stream.file.path);
				stream.removeEventListener(OutputProgressEvent.OUTPUT_PROGRESS,	handleStream);
				stream.close();
				
				current = null;
				
				// save next
				saveNext();	
			}
		}
		
		/**
		 * 	@private
		 */
		private function handleRecord(e:OnyxEvent):void {
			
			var surface:DisplaySurface	= recording.surface;
			var frame:RecordFrame		= new RecordFrame();
			frame.index					= index++;
			frame.bytes					= surface.encode(CONST_RECT, new JPEGEncoderOptions(80));
			frames.push(frame);
			
			// save next
			saveNext();	

		}
		
		/**
		 * 	@public
		 */
		public function start():void {
		}
		
		/**
		 * 	@public
		 */
		public function stop():void {
		}
	}
}
import flash.utils.ByteArray;

final class RecordFrame {
	
	public var index:int;
	public var bytes:ByteArray;
	
}