package onyx.core {
	
	import flash.events.*;
	
	/**
	 * 	This class dispatches messages dispatched from the Onyx core
	 */
	public final class Console {
		
		/**
		 * 	@public
		 */
		public static const VERBOSE:int				= CONSOLE::VERBOSE;

		/**
		 * 	@public
		 */
		public static const DEBUG:int				= CONSOLE::DEBUG;
		
		/**
		 * 	@public
		 */
		public static const INFO:uint				= CONSOLE::INFO;
		
		/**
		 * 	@public
		 */
		public static const MESSAGE:uint			= CONSOLE::MESSAGE;
		
		/**
		 * 	@public
		 */
		public static const WARNING:uint			= CONSOLE::WARNING;
		
		/**
		 * 	@public
		 */
		public static const ERROR:uint				= CONSOLE::ERROR;
		
		/**
		 * 	@private
		 */
		private static const LISTENERS:Vector.<Function> = new Vector.<Function>(); 
		
		/**
		 * 	@private
		 */
		public static function RegisterListener(callback:Function):void {

			LISTENERS.fixed = false;
			LISTENERS.push(callback);
			LISTENERS.fixed	= true;

		};
		
		/**
		 * 	@private
		 */
		public static function Unregister(callback:Function):void {
			const index:int	= LISTENERS.indexOf(callback);
			
			CONFIG::DEBUG {
				if (index === -1) {
					throw new Error('LISTENER NOT CHILD.');
				}
			}

			LISTENERS.splice(index, 1);
			
		};
		
		/**
		 * 	@public
		 * 	Returns a bunch of tabs based on length
		 */
		public static function Format(input:String, length:uint = 8, tabSize:uint = 8):String {
			var count:int = Math.floor(input.length / tabSize);
			while (++count < length) {
				input = input +'\t';
			}
			return input;
		}
		
		/**
		 *	@public
		 */
		public static function LogError(... args:Array):void {
			var str:String = args.join(' ') + '\n';
			for each (var fn:Function in LISTENERS) {
				fn(ERROR, str);
			}
			
			CONFIG::DEBUG { throw new Error(str.substr(0, str.length - 1)); };
		};
		
		/**
		 * 	@public
		 */
		CONFIG::DEBUG public static function Debug(... args:Array):void {
			args.unshift(DEBUG);
			Log.apply(null, args);
		}
		
		/**
		 * 	@public
		 */
		public static function LogEvent(e:Event):void {
			Log(MESSAGE, e);
		}

		/**
		 *	@public
		 */
		public static function Log(type:int, ... args:Array):void {
			var str:String = args.join(' ') + '\n';
			for each (var fn:Function in LISTENERS) {
				fn(type, str);
			}
			
			CONFIG::DEBUG {
				
				str = str.substr(0, -1);
				
				switch (type) {
					case DEBUG:
						str = 'DEBUG:\t\t' + str;
						break;
					case INFO:
						str = 'INFO:\t\t' + str;
						break;
					case MESSAGE:
						str = 'MESSAGE:\t' + str;
						break;
					case WARNING:
						str = 'WARNING:\t' + str;
						break;
					case ERROR:
						str = 'ERROR:\t' + str;
						break;
				}
				
				trace(str);
			};
		};
	}
}