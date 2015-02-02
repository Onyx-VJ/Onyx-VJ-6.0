package onyx.cache {
	
	import flash.display.*;
	
	import onyx.core.*;
	import onyx.util.*;
	
	public final class BitmapCache implements ISharedCache {
		
		/**
		 * 	@private
		 */
		private const cache:Object	= {};
		
		/**
		 * 	@private
		 */
		public function create(width:int, height:int, transparent:Boolean):BitmapData {
			return new BitmapData(width, height, transparent);
		}
		
		/**
		 * 	@private
		 */
		public function destroy(data:BitmapData):void {
			data.dispose();
		}

		/**
		 * 	@public
		 */
		public function retrieve(width:uint, height:uint, transparent:Boolean):* {
			var hash:uint			= (transparent ? 0xF0000000 : 0) | (width & 0x00000FFF) << 12 | (width & 0x00000FFF);
			var cache:SharedCache	= this.cache[hash];
			if (!cache) {
				
				cache				= new SharedCache();
				cache.data			= create(width, height, transparent);
				
				// store it
				this.cache[hash]	= cache;
			}
			
			++cache.count;
			
			// return
			return cache.data;
		}
		
		/**
		 * 	@public
		 */
		public function release(width:int, height:int, transparent:Boolean):* {

			var hash:uint			= (transparent ? 0xF0000000 : 0) | (width & 0x00000FFF) << 12 | (width & 0x00000FFF);
			var cache:SharedCache	= this.cache[hash];
			if (!cache) {
				throw new Error('NO BITMAP CACHE!');
			}
			if (--cache.count === 0) {
				
				destroy(cache.data);
				delete this.cache[hash];
			}
			
			return null;
		}
	}
}