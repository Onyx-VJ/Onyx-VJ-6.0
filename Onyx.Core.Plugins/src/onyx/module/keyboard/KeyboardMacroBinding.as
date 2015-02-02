package onyx.module.keyboard {
	
	import flash.display.*;
	
	import onyx.core.*;
	import onyx.parameter.*;
	import onyx.plugin.PluginStatus;
	
	final public class KeyboardMacroBinding extends KeyboardInterfaceBinding {
		
		/**
		 * 	@public
		 */
		public var definition:IPluginDefinition;
		
		/**
		 * 	@public
		 */
		public var data:Object;
		
		/**
		 * 	@private
		 */
		private var macro:IPluginMacro;
		
		/**
		 * 	@public
		 */
		public function KeyboardMacroBinding(definition:IPluginDefinition, data:Object):void {
			this.definition	= definition;
			this.data		= data;
		}
		
		/**
		 * 	@public
		 */
		override public function exec(value:Boolean):void {
			
			if (value) {
				
				var status:PluginStatus;
				
				if (!macro) {
					macro = definition.createInstance() as IPluginMacro;
					if (!macro || (status = macro.initialize(data)) !== PluginStatus.OK) {
						Console.LogError('Error initializing macro', definition.id, status.message);
					}
				} else {
					macro.repeat();
				}

			} else if (macro) {
				macro.dispose();
				macro = null;
			}
		}
	}
}