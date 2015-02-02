package onyx.macro {

	import onyx.core.*;
	import onyx.plugin.*;
	
	use namespace parameter;
	
	[PluginInfo(
		id			= 'Onyx.Macro.Example',
		name		= 'Onyx.Macro.Example',
		version		= '1.0',
		vendor		= 'Daniel Hai',
		description = 'Example Macro'
	)]
	
	public final class ExampleMacro extends PluginBase implements IPluginMacro {
		
		/**
		 * 	@public
		 */
		public function initialize(data:Object):PluginStatus {
			return PluginStatus.OK;
		}
		
		/**
		 * 	@public
		 */
		public function repeat():void {}
		
		/**
		 * 	@public
		 */
		override public function dispose():void {
			super.dispose();

		}
	}
}