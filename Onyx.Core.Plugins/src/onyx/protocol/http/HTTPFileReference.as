package onyx.protocol.http {
	
	import onyx.core.*;
	
	final internal class HTTPFileReference implements IFileReference {
		
		/**
		 * 	@private
		 */
		private var _path:String;
		
		/**
		 * 	@private
		 */
		private var parent:HTTPProtocol;
		
		/**
		 * 	@private
		 */
		public function HTTPFileReference(parent:HTTPProtocol, path:String):void {
			this.parent	= parent;
			this._path	= path;
		}
		
		/**
		 * 	@public
		 */
		public function get protocol():IPluginProtocol {
			return parent;
		}
		
		/**
		 * 	@public
		 */
		public function get nativePath():String {
			return _path;
		}
		
		/**
		 * 	@public
		 */
		public function resolve(path:String):IFileReference {
			return new HTTPFileReference(parent, _path + path);
		}
		
		/**
		 * 	@public
		 */
		public function get isDirectory():Boolean {
			
			var name:String	= this.name;
			
			//TODO
			return name.indexOf('.') === -1;
		}
		
		/**
		 * 	@public
		 */
		public function get name():String {
			
			const index:int	= _path.lastIndexOf('/');
			return index >= 0 ? _path.substr(index + 1) : _path;
		}
		
		/**
		 * 	@public
		 */
		public function getParent():IFileReference {
			return new HTTPFileReference(parent, _path);
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
		public function get path():String {
			return _path;
		}
		
		/**
		 * 	@public
		 */
		public function get extension():String {
			const index:int	= _path.lastIndexOf('.');
			return index !== -1 ? _path.substr(index + 1) : '';
		}
		
		/**
		 * 	@public
		 */
		public function getGenerator():IPluginDefinition {
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
		public function toString():String {
			return '[HTTP: ' + _path + ']';
		}
	}
}