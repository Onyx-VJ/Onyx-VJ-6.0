package onyx.ui.window.browser {
	
	import flash.events.*;
	import flash.text.*;
	
	import onyx.core.*;
	import onyx.plugin.*;
	import onyx.ui.component.*;
	import onyx.ui.core.*;
	
	use namespace skinPart;
	
	final public class UIProtocolControl extends UIObject {
		
		/**
		 * 	@public
		 */
		public var protocol:IPluginProtocol;
		
		/**
		 * 	@private
		 */
		skinPart var skin:UISkin;
		
		/**
		 * 	@private
		 */
		skinPart var label:UITextField;
		
		/**
		 * 	@public
		 */
		public function UIProtocolControl(name:String, protocol:IPluginProtocol = null):void {
			
			this.protocol					= protocol;
			
		}
	}
}