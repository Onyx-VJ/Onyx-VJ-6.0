package onyx.device.capture {
	
	import flash.events.*;
	import flash.media.*;
	import flash.system.*;
	
	import onyx.core.*;
	import onyx.display.*;
	import onyx.plugin.*;
	import onyx.util.*;
	
	[PluginInfo(
		id			= 'Onyx.Device.Capture',
		name		= 'Capture Devices',
		version		= '1.0',
		vendor		= 'Daniel Hai',
		description = 'Capture protocol',
		protocol	= 'capture'
	)]
	final public class CaptureDevice extends PluginBase implements IPluginProtocol {
		
		/**
		 * 	@private
		 */
		private var devices:Object;
		
		/**
		 * 	@public
		 * 	Queries directory
		 */
		public function query(path:IFileReference, callback:Callback, filter:Callback = null):void {
			
			if (!devices) {
				devices = buildDevices();
			}
			
			var returnDevices:Vector.<IFileReference>	= new Vector.<IFileReference>();
			for each (var device:CaptureDeviceReference in devices) {
				returnDevices.push(device);
			}
			
			// callback
			callback.exec(returnDevices);
		}
		
		/**
		 * 	@private
		 */
		private function buildDevices():Object {
			
			var data:Object			= this.plugin.info.settings;
			var defaultData:Object	= data['default'] || {
				width:		320,
				height:		240,
				frameRate:	15
			}
			
			var names:Array		= Camera.names;
			var devices:Object	= {};
			for (var count:int = 0; count < names.length; ++count) {
				var name:String	= names[count];
				devices[names] = new CaptureDeviceReference(this, name, String(count), data[name] || defaultData);
			}
			
			// lose the memory, cause we don't need it anymore
			delete this.plugin.info.settings;
			
			return devices;
		}
		
		/**
		 * 	@public
		 */
		public function load(reference:IFileReference, callback:Callback):void {
			
			if (!devices) {
				devices = buildDevices();
			}
			
			if (devices[reference.name]) {
				
				// no content, everything lives in the file reference
				callback.exec(reference, null, Onyx.CreateInstance('Onyx.Generator.Capture'));
			}
		}
		
		/**
		 * 	@public
		 */
		public function getFileReference(path:String):IFileReference {
			if (!devices) {
				devices = buildDevices();
			}
			
			return devices[path];
		}
	}
}