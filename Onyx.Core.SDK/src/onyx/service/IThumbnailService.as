
package onyx.service {
	
	import flash.display.*;
	
	import onyx.core.*;
	import onyx.util.*;
	
	/**
	 *	@private 
	 */
	public interface IThumbnailService extends IPluginModule {

		/**
		 * 	@public
		 * 	Reads a thumbnail
		 */
		function readThumbnail(type:String, file:IFileReference, callback:Callback):void;
		
		/**
		 * 	@public
		 * 	Saves a thumbnail based on a file path
		 */
		function saveThumbnail(type:String, file:IFileReference, data:BitmapData):void;

	}
}