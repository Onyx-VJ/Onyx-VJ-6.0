package onyx.parameter {
	
	import flash.events.*;
	
	import onyx.core.*;
	
	[Event(name='Parameter.Change', type='onyx.event.ParameterEvent')]
	
	public interface IParameter extends ISerializable, IEventDispatcher {
		
		/**
		 * 	@public
		 * 	Returns the id
		 */
		function get id():String;
		
		/**
		 * 	@public
		 * 	Get name
		 */
		function get name():String;

		/**
		 * 	@public
		 * 	Get metadata
		 */
		function get info():*;
		
		/**
		 * 	@public
		 * 	gets the type
		 */
		function get type():String;
		
		/**
		 * 	@public
		 * 	Gets value
		 */
		function get value():*;
		
		/**
		 * 	@public
		 * 	Sets value
		 */
		function set value(v:*):void;
		
		/**
		 * 	@public
		 * 	Resets the value
		 */
		function reset():void;
		
		/**
		 * 	@public
		 */
		function lock(value:Boolean):void;
		
		/**
		 * 	@public
		 */
		function isBindable():Boolean;
		
		/**
		 * 	@public
		 * 	Sets value
		 */
		function isHidden():Boolean;
		
		/**
		 * 	@public
		 */
		function bindInterface(binding:InterfaceBinding):void;
		
		/**
		 * 	@public
		 */
		function getBoundInterface():InterfaceBinding;
		
		/**
		 * 	@public
		 */
		function toString():String;
		
	}
}