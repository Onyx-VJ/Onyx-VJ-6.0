package onyx.util {
	
	import flash.utils.*;
	
	import onyx.core.*;

	final public class SharedCache {
		
		/**
		 * 	@private
		 */
		private static const MANAGERS:Object = {};
		
		/**
		 * 	@public
		 */
		public static function registerType(type:String, manager:ISharedCache):void {
			MANAGERS[type] = manager;
		}
		
		/**
		 * 	@public
		 */
		public static function release(type:String, ... args:Array):* {
			return MANAGERS[type]['release'].apply(null, args);
		}

		/**
		 * 	@public
		 */
		public static function get(type:String, ... args:Array):* {
			return MANAGERS[type]['retrieve'].apply(null, args);
		}
		
		/**
		 * 	@public
		 */
		public var data:*;
		
		/**
		 * 	@public
		 */
		public var count:int;
		
	}
}

final class ShareCachePair {
}