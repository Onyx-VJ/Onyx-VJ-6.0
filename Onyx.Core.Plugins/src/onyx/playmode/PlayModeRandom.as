package onyx.playmode {
	
	import flash.utils.*;
	
	import onyx.core.*;
	import onyx.display.*;
	import onyx.plugin.*;
	
	use namespace parameter;
	
	[PluginInfo(
		id			= 'Onyx.PlayMode.Random',
		name		= 'Onyx.PlayMode.Random',
		version		= '1.0',
		vendor		= 'Daniel Hai',
		description = 'Random Playback',
		icon		= 'onyx.playmode::PlayModeRandomIcon'
	)]
	
	/**
	 * 	@public
	 */
	final public class PlayModeRandom extends PluginBase implements IPluginPlayMode {
		
		/**
		 * 	@private
		 */
		private var layer:IDisplayLayer;
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

			const val:Number = Math.random();
			
			// return the time
			info.actualTime = val * info.totalTime;
			
			// return the time
			return val;
		}
	}
}