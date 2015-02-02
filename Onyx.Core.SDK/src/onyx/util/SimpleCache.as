package onyx.util {

	final public class SimpleCache {
		
		/**
		 * 	@public
		 */
		public static function Register(createFunction:Function, destroyFunction:Function):SimpleCache {
			const cache:SimpleCache = new SimpleCache();
			cache.create			= createFunction;
			cache.destroy			= destroyFunction;
			return cache;
		}
		
		/**
		 * 	@private
		 */
		private var refCount:int;
		
		/**
		 * 	@private
		 */
		private var data:Object;
		
		private var create:Function;
		private var destroy:Function;
		
		/**
		 * 	@public
		 */
		public function register(... args:Array):* {
			
			if (!data) {
				data = create.apply(null, args);
			}
			refCount++;
			
			return data;
		}
		
		/**
		 * 	@public
		 */
		public function release():void {
			if (--refCount === 0) {
				destroy(data);
				data = null;
			}
		}
	}
}