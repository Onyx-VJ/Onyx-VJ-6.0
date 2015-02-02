package onyx.core {
	
	import onyx.plugin.*;
	
	public interface ISerializable {
		
		/**
		 * 	@public
		 * 	Unserializes an object from JSON
		 * 
		 * 	@returns	true for successful, false for unsuccessful
		 */
		function unserialize(token:*):void;
		
		/**
		 * 	@public
		 * 	Serializes an object to JSON
		 */
		function serialize(options:uint = 0xFFFFFFFF):Object;

	}
}