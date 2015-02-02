package onyx.device.capture {
	
	import onyx.core.*;
	import onyx.device.*;
	
	public final class CaptureDeviceReference implements IFileReference {
		
		/**
		 * 	@private
		 */
		private var _name:String;
		
		/**
		 * 	@private
		 */
		private var parentProtocol:IPluginProtocol;
		
		/**
		 * 	@private
		 */
		internal var preferences:Object;
		
		/**
		 * 	@private
		 */
		internal var index:String;
		
		/**
		 * 	@public
		 */
		public function CaptureDeviceReference(protocol:CaptureDevice, name:String, index:String, preferences:Object):void {
			
			// capture://
			this._name				= name;
			this.parentProtocol		= protocol;
			this.preferences		= preferences;
			
		}
		
		/**
		 * 	@public
		 */
		public function get name():String {
			return _name;
		}
		
		/**
		 * 	@public
		 */
		public function get extension():String {
			return '';
		}
		
		/**
		 * 	@public
		 */
		public function get isDirectory():Boolean {
			return false;
		}
		
		/**
		 * 	@public
		 */
		public function get exists():Boolean {
			return true;
		}
		
		/**
		 * 	@public
		 */
		public function resolve(path:String):IFileReference {
			return null;
		}
		
		/**
		 * 	@public
		 */
		public function get nativePath():String {
			return path;
		}
		
		/**
		 * 	@public
		 */
		public function get protocol():IPluginProtocol {
			return parentProtocol;
		}
		
		/**
		 * 	@public
		 */
		public function getParent():IFileReference {
			return null;
		}
		
		/**
		 * 	@public
		 */
		public function createDirectory():void {
			throw new Error('Cannot create remote directory!');
		}
		
		/**
		 * 	@public
		 */
		public function get dateModified():Number {
			return 0;
		}
		
		/**
		 * 	@public
		 */
		public function get path():String {
			return 'capture://' + _name;
		}
		
		CONFIG::DEBUG public function toString():String {
			return '[CaptureDeviceRef: ' + _name + ']';
		}
	}
}