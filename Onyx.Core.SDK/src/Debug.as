package {
	
	[Compiler(action='Exclude')]
	
	import flash.utils.*;
	
	import onyx.core.*;
	import onyx.util.encoding.*;

	final public class Debug {
		
		/**
		 * 	@public
		 * 	Enumerates through an object
		 */
		CONFIG::DEBUG public static function object(target:Object, ... args:Array):void {
			trace(args.join(' ') + '\n' + Serialize.toJSON(target, true));
		}
		
		/**
		 * 	@public
		 * 	Enumerates through an object
		 */
		CONFIG::DEBUG public static function type(target:Object):void {
			trace(describeType(target));
		}
		
		/**
		 * 	@public
		 * 	Enumerates through an object
		 */
		CONFIG::DEBUG public static function out(... args:Array):void {
			Console.Log(CONSOLE::DEBUG, args.join('\t'));
		}
		
		/**
		 * 	@public
		 * 	Enumerates through an object
		 */
		CONFIG::DEBUG public static function stack():void {
			try {
				throw new Error('stacktrace');
			} catch (e:Error) {
				trace(e.getStackTrace());
			}
		}
	}
}