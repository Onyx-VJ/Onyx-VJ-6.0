package onyx.util {
	
	public final class ObjectUtil {
		
		/**
		 * 	@public
		 */
		public static function Clone(o:Object, token:Object = null):Object {
			var ret:Object = JSON.parse(JSON.stringify(o));
			if (token) {
				Merge(token, ret);
			}
			return ret;
		}
		
		/**
		 * 	@public
		 */
		public static function Merge(source:Object, dest:Object):void {
			for (var i:String in source) {
				dest[i] = source[i];
			}
		} 
	}
}