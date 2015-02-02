package onyx.host.gl {
	
	import flash.events.*;
	
	import onyx.core.InterfaceBinding;
	import onyx.event.*;
	import onyx.parameter.*;
	
	/**
	 * 	@internal
	 */
	internal class PluginGLParameter extends EventDispatcher implements IParameter {
		
		/**
		 * 	@public
		 */
		public var start:int;
		
		/**
		 * 	@public
		 */
		public var end:int;
		
		/**
		 * 	@private
		 * 	This is the target data
		 */
		public var data:Vector.<Number>;
		
		/**
		 * 	@protected
		 */
		protected var metadata:PluginGLParameterDef;
		protected var locked:Boolean;
		
		/**
		 *	@public
		 */
		public function PluginGLParameter(def:PluginGLParameterDef, data:Vector.<Number>):void {
			this.metadata		= def;
			this.start			= def.index;
			this.end			= def.length + def.index;
			this.data			= data;
			
			CONFIG::DEBUG { Debug.object(def); }
		}
		
		/**
		 * 	@public
		 */
		public function lock(value:Boolean):void {
			locked = value;
		}
		
		/**
		 * 	@public
		 */
		public function isBindable():Boolean {
			return false;
		}
		
		/**
		 * 	@public
		 */
		final public function getBoundInterface():InterfaceBinding {
			return null;
		}
		
		/**
		 * 	@public
		 */
		final public function bindInterface(binding:InterfaceBinding):void {}
		
		/**
		 * 	@public
		 */
		public function get info():* {
			return metadata;
		}
		
		/**
		 * 	@public
		 */
		public function isHidden():Boolean {
			return false;
		}
		
		/**
		 * 	@public
		 */
		public function reset():void {
		}
		
		/**
		 * 	@public
		 */
		public function unserialize(token:*):void {
		}
		
		/**
		 * 	@public
		 */
		public function serialize(options:uint = 0xFFFFFFFF):Object {
			return {};
		}
		
		/**
		 * 	@public
		 */
		public function get type():String {
			return metadata.type;
		}
		
		public function get id():String {
			return metadata.id;
		}
		
		public function get name():String {
			return metadata.name || metadata.id;
		}
		
		/**
		 * 	@public
		 */
		public function set value(value:*):void {
			const v:Vector.<Number> = value as Vector.<Number>;
			const length:int		= end - start;
			
			CONFIG::DEBUG {
				if (length !== v.length) {
					throw new Error('INVALID VECTOR LENGTH! ' + length + ':' + start + ',' + end + ',' + v.length);
				}
			}
			
			for (var count:int = 0; count < length; ++count) {
				data[start + count] = v[count];
			}
			
			// dispatch a change event
			dispatchEvent(new ParameterEvent(ParameterEvent.VALUE_CHANGE, this));
		}
		
		/**
		 * 	@public
		 */
		public function getDisplayValue():String {
			return value;
		}
		
		/**
		 * 	@public
		 */
		public function get value():* {
			return data.slice(start, end);
		}
	}
}