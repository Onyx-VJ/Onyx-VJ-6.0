package onyx.util {
	
	final public class StringUtil {
		
		/**
		 * 	@public
		 */
		public static function padBefore(str:String, length:uint = 2, char:String = '0'):String {
			while (str.length < length) {
				str = char + str;
			}
			return str;
		}
	}
}