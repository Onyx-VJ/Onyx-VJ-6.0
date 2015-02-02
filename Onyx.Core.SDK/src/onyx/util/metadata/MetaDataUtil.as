package onyx.util.metadata {
	
	public final class MetaDataUtil {
		
		public static const MERGED:uint				= 0x01;
		public static const NAMED_OBJECT:uint		= 0x02;
		public static const NAMED_OBJECT_ID:uint	= 0x03;
		
		/**
		 * 	@public
		 */
		public static function Merge(metadata:Array, fields:Object):Object {
			
			const returnObj:Object	= {};
			
			// add the metdata, delete the name since it's stored as the key
			for each (var node:Object in metadata) {
				
				var name:String	= node.name;
				var type:int	= fields[name];
				if (!type) {
					continue;
				}
				
				switch (type) {
					case MERGED:
						
						// loop through the parameter keys
						var param:Object = {};
						for each (var key:Object in node.value) {
							param[key.key]	= key.value;
						}
						
						returnObj[name]	= param;
						
						break;
					
					case NAMED_OBJECT:
						
						// loop through the parameter keys
						param = {};
						for each (key in node.value) {
							param[key.key]	= key.value;
						}
						
						if (!returnObj[name]) {
							returnObj[name] = [];
						}
						
						returnObj[name].unshift(param);
						break;
				}
			}
			
			return returnObj;
		}
	}
}