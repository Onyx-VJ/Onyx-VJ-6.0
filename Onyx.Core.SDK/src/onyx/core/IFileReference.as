package onyx.core {
	
	[Compiler(Link)]
	
	/**
	 * 	@public
	 */
	public interface IFileReference {
		
		/**
		 * 	@public
		 * 	Returns the parent protocol
		 */
		function get protocol():IPluginProtocol;
		
		/**
		 * 	@public
		 * 	Returns the name of the file
		 */
		function get name():String;
		
		/**
		 * 	@public
		 * 	Returns relative path to the file
		 */
		function get path():String;
		
		/**
		 * 	@public
		 * 	Returns the absolute path to this file
		 */
		function get nativePath():String;
		
		/**
		 * 	@public
		 * 	Returns extension
		 */
		function get extension():String;
		
		/**
		 * 	@public
		 * 	Returns whether the file is a directory or not
		 */
		function get isDirectory():Boolean;
		
		/**
		 * 	@public
		 * 	Returns the parent fiel reference
		 */
		function getParent():IFileReference;
		
		/**
		 * 	@public
		 * 	Returns the parent fiel reference
		 */
		function resolve(relative:String):IFileReference;
		
		/**
		 * 	@public
		 */
		function get exists():Boolean;
		
		/**
		 * 	@public
		 */
		function get dateModified():Number;
		
		/**
		 * 	@public
		 */
		function createDirectory():void;

	}
}