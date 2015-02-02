package onyx.util.tween {
	
	import flash.events.*;
	import flash.utils.*;
	
	import mx.effects.Tween;
	
	import onyx.core.*;
	import onyx.plugin.*;
	
	/**
	 * 		Custom Tween Class
	 */
	public class Tween {
		
		/**
		 * 	@private
		 */
		private static const TWEENS:Array		= [];
		
		/**
		 * 	@private
		 */
		private static const TARGETS:Dictionary	= new Dictionary(true);
		
		/**
		 * 	@private
		 */
		private static const TIMER:Timer		= new Timer(1);
		
		/**
		 * 	@private
		 */
		private static var invalid:Boolean;
		
		/**
		 * 	@public
		 * 	Create the most primitive tween
		 */
		public static function Create(time:int, method:Function, data:* = null):void {
			
			var tween:TweenInternal = new TweenInternal();
			tween.time				= time;
			tween.target			= method;
			tween.data				= data;
			tween.startTime			= getTimer();
			tween.endTime			= time + tween.startTime;
			
			TWEENS.push(tween);
			
			invalid	= true;
			
			// store TimeStamp + time;
			if (!TIMER.running) {
				TIMER.addEventListener(TimerEvent.TIMER, handleTimer);
				TIMER.start();
			}
		}
		
		/**
		 * 	@private
		 */
		private static function handleTimer(event:Event):void {
			
			if (invalid) {
				TWEENS.sortOn('endTime', Array.NUMERIC | Array.DESCENDING);
				invalid = false;
			}

			var time:int		= getTimer();
			var popIndex:int	= -1;
			var len:int			= TWEENS.length;
			for (var count:int = 0; count < len; ++count) {
				var tween:TweenInternal	= TWEENS[count];
				
				var ratio:Number		= Math.max(Math.min((time - tween.startTime) / tween.time, 1), 0);
				tween.target(ratio, time - tween.startTime, tween.time);
				if (popIndex === -1 && ratio >= 1) {
					popIndex = count;
				}
			}
			
			if (popIndex >= 0) {

				TWEENS.splice(popIndex, TWEENS.length);
				if (TWEENS.length === 0) {
					TIMER.stop();
				}
			}
		}
		
		/**
		 * 	@public
		 */
		public var time:int;
		
		/**
		 * 	@private
		 */
		public var startTime:int;
		
		/**
		 * 	@private
		 */
		public var endTime:int;
		
		/**
		 * 	@private
		 */
		public var target:Function;
	}
}

import onyx.util.tween.Tween;

final class TweenInternal extends Tween {

	/**
	 * 	@public
	 */
	public var data:Object;

} 