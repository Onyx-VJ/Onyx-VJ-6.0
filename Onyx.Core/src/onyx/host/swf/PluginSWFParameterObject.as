package onyx.host.swf {
	
	import flash.events.Event;
	
	import onyx.core.*;
	import onyx.event.*;
	import onyx.parameter.*;
	
	use namespace parameter;
	use namespace onyx_ns;
	
	[Event(name='change', type='flash.events.Event')]
	
	final public class PluginSWFParameterObject extends PluginSWFParameter implements IParameterObject {
		
		/**
		 * 	@private
		 */
		private const children:Vector.<IParameter>	= new Vector.<IParameter>();

		/**
		 * 	@public
		 */
		override public function initialize(target:Object, property:String, parameterType:String, definition:PluginSWFDefinition):void {
			
			super.initialize(target, property, parameterType, definition);
			
			target		= this.value;
			
			var def:Vector.<PluginSWFDefinition>	= definition.children;
			
			children.length			= def.length;
			children.fixed			= true;
			
			for (var count:int = 0; count < def.length; ++count) {
				
				var parameter:IParameter = PluginSWFHost.CreateParameter(target, def[count]);
				parameter.addEventListener(ParameterEvent.VALUE_CHANGE, childChanged);
				
				children[count] = parameter;
			}
		}
		
		/**
		 * 	@private
		 */
		private function childChanged(e:ParameterEvent):void {
			dispatchEvent(new ParameterEvent(ParameterEvent.VALUE_CHANGE, this));
		}
		
		/**
		 * 	@public
		 */
		override public function serialize(options:uint = 0xFFFFFFFF):Object {
			const serialized:Object = {};
			for each (var parameter:Parameter in children) {
				serialized[parameter.id] = parameter.serialize(options);
			} 
			return serialized;
		}
		
		/**
		 * 	@public
		 */
		override public function reset():void {
			for each (var param:IParameter in children) {
				param.reset();
			}
		}
		
		/**
		 * 	@public
		 */
		override public function unserialize(token:*):void {
			
			for each (var parameter:Parameter in children) {
				var val:Object	= token[parameter.id];
				if (val) {
					parameter.unserialize(val);
				}
			}
		}
		
		/**
		 * 	@public
		 */
		override public function set value(v:*):void {
			throw new Error('CANNOT SET OBJECT VALUE DIRECTLY');
		}
		
		/**
		 * 	@public
		 */
		public function getChildParameters():Vector.<IParameter> {
			return children;
		}
		
		/**
		 * 	@public
		 */
		override public function dispose():void {
			
			// remove children
			for each (var param:Parameter in children) {
				parameter.unbind(childChanged);
			}
			
			// kill children
			children.splice(0, children.length);
			
			// dispose
			super.dispose();
		}
		
		/**
		 * 	@public
		 */
		CONFIG::DEBUG override public function toString():String {
			return '[ParameterObject ' + property + ':' + type + ']\n';
		};
	}
}