package onyx.playmode {
	
	import flash.utils.*;
	
	import onyx.core.*;
	import onyx.display.*;
	import onyx.plugin.*;
	
	use namespace parameter;
	
	[PluginInfo(
		id			= 'Onyx.PlayMode.Paused',
		name		= 'Onyx.PlayMode.Paused',
		version		= '1.0',
		vendor		= 'Daniel Hai',
		description = 'Paused Playback',
		icon		= 'onyx.playmode::PlayModePausedIcon'
	)]
	
	/**
	 * 	@public
	 */
	final public class PlayModePaused extends PluginBase implements IPluginPlayMode {
		
		/**
		 * 	@private
		 */
		private var layer:IDisplayLayer;
		
		/**
		 * 	@private
		 */
		private var info:LayerTime;
		
		/**
		 * 	@public
		 */
		public function initialize(layer:IDisplayLayer):PluginStatus {

			this.layer	= layer;
			this.info	= layer.getTimeInfo();
			
			// ok
			return PluginStatus.OK;
		}
		
		/**
		 * 	@private
		 * 	This is called in the context of the layer
		 */
		public function update():Number {
			
			// return the tiime
			return Math.max(Math.min(info.actualTime / info.totalTime, 1), 0);
		}
	}
}