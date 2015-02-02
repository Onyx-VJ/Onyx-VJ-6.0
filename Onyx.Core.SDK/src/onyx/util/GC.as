/**
 *	@private 
 */
package onyx.util {
	
	import flash.system.*;
	import flash.utils.*;
	
	import onyx.core.*;
	
	final public class GC {

		CONFIG::DEBUG {
			
			/**
			 * 	@private
			 */
			private static const DEFINITION:Object	= {};
			private static const WATCHERS:Dictionary	= new Dictionary(true);
			
			/**
			 * 	@public
			 */
			public static function watch(obj:Object):void {
				const c:Class			= Object(obj).constructor;
				const hash:GCHash		= DEFINITION[c] || (DEFINITION[c] = new GCHash(c));
				hash.dict[obj]			= hash.iter++;
			}
			
			/**
			 * 	@public
			 */
			public static function watchListener(obj:Object, type:String, fn:Function):void {
				const dict:Dictionary	= WATCHERS[obj] || (WATCHERS[obj] = new Dictionary());
				dict[type]	= fn;
			}
			
			/**
			 * 	@public
			 */
			public static function log():void {
				
				// gc
				System.gc();
				
				const out:Array	= [];
				
				for each (var hash:GCHash in DEFINITION) {
					
					var count:int = 0;
					for each (var obj:Object in hash.dict) {
						++count;
					}
					
					out.push([hash.def, hash.iter, count].join(' '));
				}
				
				out.sort();
				Console.Log(CONSOLE::DEBUG, out.join('\n'));
			}

		}
	}
}

import flash.utils.*;

final class GCHash {
	
	public const dict:Dictionary	= new Dictionary(true);
	public var iter:int;
	public var def:Class;
	
	public function GCHash(c:Class):void {
		def = c;
	}
}
