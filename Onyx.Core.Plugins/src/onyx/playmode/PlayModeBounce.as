package onyx.playmode {

	import flash.net.drm.VoucherAccessInfo;
	import flash.utils.*;
	
	import onyx.*;
	import onyx.core.*;
	import onyx.display.*;
	import onyx.plugin.*;
	
	use namespace parameter;
	
	[PluginInfo(
		id			= 'Onyx.PlayMode.Bounce',
		name		= 'Onyx.PlayMode.Bounce',
		version		= '1.0',
		vendor		= 'Daniel Hai',
		description = 'Bounce Playback',
		icon		= 'onyx.playmode::PlayModeBounceIcon'
	)]
	
	/**
	 * 	@public
	 */
	final public class PlayModeBounce extends PluginBase implements IPluginPlayMode {

		/**
		 * 	@private
		 */
		private var layer:IDisplayLayer;
		
		/**
		 * 	@private
		 */
		private var info:LayerTime;
		
		/**
		 * 	@private
		 */
		private var lastUpdate:int		= TimeStamp;
		
		/**
		 * 	@public
		 */
		public function initialize(layer:IDisplayLayer):PluginStatus {
			this.layer	= layer;
			this.info	= layer.getTimeInfo();
			
			return PluginStatus.OK;
		}

		/**
		 * 	@private
		 * 	This is called in the context of the layer
		 */
		public function update():Number {
			
			var totalTime:int		= info.totalTime;
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
					info.actualTime = (end) + (time % end);
					layer.setParameterValue('playDirection', layer.getParameterValue('playDirection') * -1);
				}

			} else if (time <= (start)) {
				
				info.actualTime = start - time;
				layer.setParameterValue('playDirection', layer.getParameterValue('playDirection') * -1);
			}
			
			lastUpdate	= TimeStamp;
			
			// return the tiime
			return Math.max(Math.min(info.actualTime / totalTime, 1), 0);
		};
	}
}