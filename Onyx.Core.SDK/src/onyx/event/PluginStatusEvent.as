package onyx.event {
	
	import flash.events.*;
	
	import onyx.plugin.*;
	
	public final class PluginStatusEvent extends Event {
		
		/**
		 * 	@public
		 */
		public static const STATUS:String	= 'Plugin.Status';
		
		/**
		 * 	@public
		 */
		public var status:PluginStatus;
		
		/**
		 * 	@constructor
		 */
		public function PluginStatusEvent(type:String, status:PluginStatus):void  {
			
			this.status	= status;
			super(type);
		}
		
		/**
		 * 	@public
		 */
		override public function clone():Event {
			return new PluginStatusEvent(type, status);
		}
	}
}