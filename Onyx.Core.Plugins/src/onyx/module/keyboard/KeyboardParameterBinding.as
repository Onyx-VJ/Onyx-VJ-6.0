package onyx.module.keyboard {
	
	import flash.display.*;
	
	import onyx.core.*;
	import onyx.parameter.*;
	
	final public class KeyboardParameterBinding extends KeyboardInterfaceBinding {
		
		/**
		 * 	@public
		 */
		public var parameter:IParameterExecutable;
		
		/**
		 * 	@public
		 */
		public function KeyboardParameterBinding(parameter:IParameterExecutable):void {
			this.parameter	= parameter;
		}
		
		/**
		 * 	@public
		 */
		override public function exec(value:Boolean):void {
			if (value) {
				parameter.execute();
			}
		}
	}
}