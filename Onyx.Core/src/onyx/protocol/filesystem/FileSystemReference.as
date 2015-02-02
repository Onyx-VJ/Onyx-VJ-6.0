package onyx.protocol.filesystem {
	
	import flash.filesystem.*;
	
	import onyx.core.*;
	import onyx.util.*;
	
	final internal class FileSystemReference extends File implements IFileReference {
		
		/**
		 * 	@private
		 */
		internal var parentProtocol:FileSystemProtocol;
		
		/**
		 * 	@public
		 */
		public function FileSystemReference(protocol:FileSystemProtocol, path:String):void {
			
			// store parent protocol
			this.parentProtocol	= protocol;
			
			// we are a file
			super(protocol.root + protocol.normalize(path));
	
		}
		
		/**
		 * 	@public
		 */
		public function get protocol():IPluginProtocol {
			return this.parentProtocol;
		}
		
		/**
		 * 	@public
		 */
		public function resolve(path:String):IFileReference {
			return new FileSystemReference(parentProtocol, parentProtocol.getRelativePath(resolvePath(path).nativePath));
		}
		
		/**
		 * 	@public
		 */
		public function get path():String {
			return parentProtocol.mapping + parentProtocol.getRelativePath(nativePath);
		}
		
		/**
		 * 	@public
		 */
		CONFIG::DEBUG override public function toString():String {
			return isDirectory ? '[Folder:' + this.path + ']' : '[File:' + this.path + ']';
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
		public function get dateModified():Number {
			try {
				return modificationDate ? modificationDate.time : creationDate.time;
			} catch (e:Error) {
			}
			return 0;
		}
		
		/**
		 * 	@public
		 * 	Returns the parent
		 */
		public function getParent():IFileReference {
			
			var parentPath:String	= parentProtocol.normalize(parent.nativePath);
			if (parentPath.length < parentProtocol.root.length) {
				return null;
			}
			return new FileSystemReference(parentProtocol, parentProtocol.getRelativePath(parent.nativePath));
		}
	}
}