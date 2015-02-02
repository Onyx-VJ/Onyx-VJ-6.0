/**
 * 	Provides simple bridge access to display/layers/etc via osc
 * 
 * 
 * 
 *	i Integer: two’s complement int32
 *	f Float: IEEE float32
 *	s NULL-terminated ASCII string
 *	b Blob, (aka byte array) with size
 *	T True: No bytes are allocated in the argument data.
 *	F False: No bytes are allocated in the argument data.
 *	N Null:  (aka nil, None, etc). No bytes are allocated in 
 *	the argument data.
 *	I Impulse: (aka “bang”), used for event triggers. No 
 *	bytes are allocated in the argument data. This type 
 *	was named “Infinitum” in OSC 1.0 optional types.
 *	t Timetag:  an OSC timetag in NTP format, encoded in 
 *	the data section
 * 
 * 
 * 
 *	/ONYX/DISPLAY/0/
 * 	/ONYX/DISPLAY/0/LAYERS/0/
 * 	/ONYX/DISPLAY/0/LAYERS/0/FILTERS/0 move (index)
 * 	/ONYX/DISPLAY/0/LAYERS/0	ADD Onyx.Plugin.Filter.ID
 * 	/ONYX/DISPLAY/0/LAYERS/0/FILTERS/0/alpha	SET 1.0
 * 
 * 	/
 * 
 */
package onyx.module.bridge {
	
	import onyx.core.*;
	import onyx.event.*;
	import onyx.plugin.*;
	
	[PluginInfo(
		id			= 'Onyx.Module.Bridge',
		name		= 'Onyx.Module.Bridge',
		version		= '1.0',
		vendor		= 'Daniel Hai',
		description = 'Bridge Module'
	)]

	final public class BridgeModule extends PluginModule implements IPluginModule {
		
		/**
		 * 	@private
		 */
		private const namespaces:Object	= {};
		
		/**
		 * 	@public
		 * 	Initializes the modules
		 */
		public function initialize():PluginStatus {
			
			// add listener
			Onyx.addEventListener(OnyxEvent.DISPLAY_CREATE, handleCreate);
			
			// ok
			return PluginStatus.OK;
		}
		
		/**
		 * 	@private
		 */
		private function createDisplay(display:IDisplay):void {
			
			var id:String = '/DISPLAY/' + display.index;

		}
		
		/**
		 * 	@private
		 */
		private function handleCreate(e:OnyxEvent):void {
			createDisplay(e.data as IDisplay);
		}
		
		/**
		 * 	@public
		 */
		public function get priority():int {
			return 0;
		}
		
		/**
		 * 	@public
		 */
		public function start():void {
//			var displays:Vector.<IDisplay> = Onyx.GetDisplays();
//			trace(displays);
		}
		
		/**
		 * 	@public
		 */
		public function stop():void {
		}
	}
}