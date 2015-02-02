package ikelos.core {

	public final class Debug {length

		CONFIG::DEBUG {

			/**
			 * 	@public
			 */
			public static function Log( ... args:Array):void {
				if (callback !== null) {
					callback.apply(null, args);
				}
			}

			/**
			 * 	@private
			 */
			private static var callback:Function;
			
			/**
			 * 	@public
			 */
			public static function setCallback(callback:Function):void {
				Debug.callback = callback;
			}
		}
	}
}
