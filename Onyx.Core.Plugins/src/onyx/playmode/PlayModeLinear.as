package onyx.playmode {

	import flash.events.*;
	import flash.utils.*;
	
	import onyx.core.*;
	import onyx.display.*;
	import onyx.event.*;
	import onyx.plugin.*;
	
	[PluginInfo(
		id			= 'Onyx.PlayMode.Linear',
		name		= 'Onyx.PlayMode.Linear',
		version		= '1.0',
		vendor		= 'Daniel Hai',
		description = 'Linear Playback',
		icon		= 'onyx.playmode::PlayModeLinearIcon'
	)]
	
	/**
	 * 	@public
	 */
	final public class PlayModeLinear extends PluginBase implements IPluginPlayMode {
		
		/**
		 * 	@private
		 */
		private var layer:IDisplayLayer;
		
		/**
		 * 	@private
		 */
		private var info:LayerTime;
		
		/**
		 *	@private
		 */
		private var lastUpdate:int				= TimeStamp;
		
		/**
		 * 	@public
		 */
		public function initialize(layer:IDisplayLayer):PluginStatus {

			this.layer	= layer;
			this.info	= layer.getTimeInfo();
			
			if (!info) {
				return new PluginStatus('No time information');
			}
			
			if (!layer.hasParameter('playDirection')) {
				return new PluginStatus('Layer has no playDirection!');
			}
			
			// get parameter
			layer.getParameter('playDirection').addEventListener(ParameterEvent.VALUE_CHANGE, invalidateTime);
			
			// get
			return PluginStatus.OK;
		}
		
		/**
		 * 	@private
		 */
		private function invalidateTime(e:Event):void {
			lastUpdate = TimeStamp;
		}

		/**
		 * 	@private
		 * 	This is called in the context of the layer
		 */
		public function update():Number {
			
			var totalTime:int = info.totalTime;
			if (totalTime === 0) {
				return 0;
			}
			
			var start:int			= info.playStart	* totalTime;
			var end:int				= info.playEnd		* totalTime;
			var frameRate:Number	= info.playSpeed	* info.playDirection;
			
			var time:int			= Math.max(Math.min(info.actualTime, end), start);
			info.actualTime		= time + ((TimeStamp - lastUpdate) * frameRate);
			
			// if framerate is greater than 0, check for over bounds
			if (frameRate > 0) {
				
				if (time >= end) {
					info.actualTime = time % end + start;
				}

			} else if (time <= start) {
				
				info.actualTime = end + (start - time);
				
			}
			
			lastUpdate	= TimeStamp;
			
			// return the tiime
			return Math.max(Math.min(info.actualTime / totalTime, 1), 0);
		};
		
		/**
		 * 	@public
		 */
		override public function dispose():void {
			
			layer.getParameter('playDirection').removeEventListener(ParameterEvent.VALUE_CHANGE, invalidateTime);
			
			// dispose
			super.dispose();
			
		}
	}
}