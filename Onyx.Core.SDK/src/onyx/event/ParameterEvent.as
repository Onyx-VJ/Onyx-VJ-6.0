package onyx.event {
	
	import flash.events.*;
	
	import onyx.parameter.*;
	
	final public class ParameterEvent extends Event {
		
		/**
		 * 	@public
		 */
		public static const VALUE_CHANGE:String	= 'Parameter.Change';
		
		/**
		 * 	@public
		 */
		public static const BINDING_UPDATE:String	= 'Parameter.Binding.Update';
		
		/**
		 * 	@public
		 */
		public var parameter:IParameter;
		
		/**
		 * 	@public
		 */
		public function ParameterEvent(type:String, parameter:IParameter):void {
			
			this.parameter		= parameter;
			
			// do the constructor
			super(type, false, true);
		}
		
		/**
		 * 	@public
		 */
		override public function clone():Event {
			return new ParameterEvent(type, parameter);
		}
		
		/**
		 * 
		 */
		CONFIG::DEBUG override public function toString():String {
			return '[ParameterEvent: ' + parameter + ']';
		}
	}
}