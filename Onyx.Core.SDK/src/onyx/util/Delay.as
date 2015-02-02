package onyx.util {
	
	import flash.events.TimerEvent;
	import flash.utils.*;
	
	import onyx.core.*;
	
	public final class Delay {
		
		/**
		 * 	@public
		 */
		private static const TIMER:Timer	= new Timer(1);
		
		/**
		 * 	@private
		 */
		private static const delays:Array	= [];
		
		/**
		 * 	@public
		 */
		public static function create(time:int, callback:Callback):void {
			
			CONFIG::DEBUG { 
				if (!callback) {
					throw new Error('CALLBACK NOT VALID');
				}
			}
			
			const delay:Delay	= new Delay();
			delay.time			= getTimer() + time;
			delay.callback		= callback;
			
			// push it real good
			delays.push(delay);
			delays.sortOn('time');
			
			// start?
			if (delays.length === 1) {
				TIMER.addEventListener(TimerEvent.TIMER, handleTimer);
				TIMER.start();
			}
		}
		
		/**
		 * 	@private
		 */
		private static function handleTimer(event:TimerEvent):void {
			const time:int = getTimer();
			
			var index:int;
			
			for each (var delay:Delay in delays) {
				
				if (delay.time > time) {
					break;
				}
				
				++index;
				
				// remove from the list
				delays.splice(0, 1);
				
				// execute the callback
				delay.callback.exec();
				
			}
			
			// nothing left
			if (delays.length === 0) {

				TIMER.removeEventListener(TimerEvent.TIMER, handleTimer);
				TIMER.stop();

			}
		}
		
		/**
		 * 	@private
		 */
		public var time:int;
		
		/**
		 * 	@private
		 */
		private var callback:Callback;
		
		/**
		 *	@public 
		 */
		CONFIG::GC public function Delay():void {
			GC.watch(this);
		}
	}
}