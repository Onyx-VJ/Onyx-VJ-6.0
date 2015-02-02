package onyx.host.swf {
	
	import onyx.core.*;
	import onyx.event.*;
	import onyx.parameter.*;
	import onyx.plugin.*;
	
	use namespace parameter;
	
	public final class PluginSWFParameterDispatcher extends PluginSWFParameter implements IParameterDispatcher {
		
		/**
		 * 	@public
		 */
		override public function isBindable():Boolean {
			return false;
		}
		
		/**
		 * 	@public
		 */
		public function dispatch(... args:Array):void {
			dispatchEvent(new LogEvent(args.join(' ') + '\n'));
		}
		
		/**
		 * 	@public
		 */
		override public function unserialize(token:*):void {}
		
		/**
		 * 	@public
		 */
		override public function serialize(options:uint = 0xFFFFFFFF):Object {
			return null;
		}
	}
}