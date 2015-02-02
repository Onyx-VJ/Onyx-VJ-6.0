package onyx.module.keyboard {
	
	import flash.display.*;
	import flash.events.*;
	import flash.ui.*;
	
	import onyx.core.*;
	import onyx.event.*;
	import onyx.parameter.*;
	import onyx.plugin.*;
	
	[PluginInfo(
		id				= 'Onyx.Interface.Keyboard',
		name			= 'Onyx.Interface.Keyboard',
		version			= '1.0',
		vendor			= 'Daniel Hai',
		description 	= 'Keyboard Interface',
		ui				= 'onyx.module::KeyboardInterfaceUI'
	)]
	
	final public class KeyboardInterface extends PluginModule implements IPluginModuleInterface {
		
		/**
		 * 	@private
		 * 	Last 2 bytes are keycode
		 */
		public static const SHIFT:uint						= 0x00000100;
		
		/**
		 * 	@private
		 * 	Last 2 bytes are keycode
		 */
		public static const ALT:uint						= 0x00000200;
		
		/**
		 * 	@private
		 * 	Last 2 bytes are keycode
		 */
		public static const CONTROL:uint					= 0x00000400;
		
		/**
		 * 	@public
		 */
		public static const MODIFIER_MASK:uint				= 0x00000F00;
		
		/**
		 * 	@private
		 */
		private const bindings:Object						= {};
		
		/**
		 * 	@private
		 */
		private const MESSAGE:InterfaceMessage				= new InterfaceMessage();
		
		/**
		 * 	@private
		 */
		private const MESSAGE_EVENT:InterfaceMessageEvent	= new InterfaceMessageEvent(MESSAGE);
		
		/**
		 * 	@private
		 */
		private const dispatchers:Vector.<IEventDispatcher>	= new Vector.<IEventDispatcher>();
		
		/**
		 * 	@public
		 * 	Initializes the modules
		 */
		public function initialize():PluginStatus {
			
			// create bindings here
			var settings:Object = this.plugin.info.settings;
			if (settings) {
				for each (var binding:Object in settings.bindings) {
					var plugin:IPluginDefinition = Onyx.GetPlugin(binding.id);
					if (plugin) {
						if (binding.key is String) {
							bindMacro(String(binding.key).charCodeAt(0), plugin, binding.data);
						} else {
							bindMacro(uint(binding.key), plugin, binding.data);
						}
					} else {
						Console.LogError('cannot find: ', binding.id);
					}
				}
			}
			
			// return ok
			return PluginStatus.OK;
		}
		
		/**
		 * 	@public
		 */
		public function formatMessage(key:uint):String {
			
			var str:String = ''; 
			
			if (key & KeyboardInterface.CONTROL) {
				str += 'CTRL+';
			}
			if (key & KeyboardInterface.ALT) {
				str += 'ALT+';
			}
			if (key & KeyboardInterface.SHIFT) {
				str += 'SHFT+';
			}
			
			return str + String.fromCharCode(key & 0xFF);
		}
		
		/**
		 * 	@public
		 */
		public function start():void {

			// we are the origin!
			MESSAGE.origin	= this;

		}
		
		/**
		 * 	@public
		 */
		public function addDispatcher(i:IEventDispatcher):void {
			
			// add listeners
			i.addEventListener(KeyboardEvent.KEY_DOWN,	handleKey);
			i.addEventListener(KeyboardEvent.KEY_UP,	handleKey);
			
			// push the dispatcher
			dispatchers.push(i);

		}

		/**
		 * 	@private
		 * 	Handle keyboard everything
		 */
		private function handleKey(event:KeyboardEvent):void {
			
			// if the charcode is a modifier, don't do anything
			var key:uint				= event.keyCode;
			switch (key) {
				case Keyboard.ALTERNATE:
				case Keyboard.CONTROL:
				case Keyboard.COMMAND:
				case Keyboard.SHIFT:
					return;
			}
			
			const down:Boolean	= event.type === KeyboardEvent.KEY_DOWN; 
			
			// add bit masks for ctrl, alt, shift
			if (event.altKey)			{	key |= ALT; }
			if (event.shiftKey)			{	key |= SHIFT; }
			if (event.ctrlKey)			{	key |= CONTROL; }
			
			// set the code
			MESSAGE.key					= key;
			
			// the value will be 0 or 1 depending on if it's up or down
			MESSAGE.value				= down ? 1 : 0;
			
			// dispatch the message
			if (Onyx.dispatchEvent(MESSAGE_EVENT)) {
				
				var binding:KeyboardInterfaceBinding = bindings[key];
				if (!binding) {
					return;
				}
				
				// execute!
				binding.exec(down);
				
			};
		}
		
		/**
		 * 	@private
		 */
		private function bindMacro(key:uint, definition:IPluginDefinition, data:*):void {
			bindings[key] = new KeyboardMacroBinding(definition, data);
		}
		
		/**
		 * 	@private
		 */
		private function bindParameter(key:uint, parameter:IParameterExecutable):void {
			bindings[key] = new KeyboardParameterBinding(parameter);
		}
		
		/**
		 * 	@public
		 * 	Keyboard does not support parameter (except execution ones)
		 */
		public function bind(key:uint, data:*):void {
			
			// can bind?
			if (!canBind(data)) {
				return;
			}
			
			if (data is IParameter) {
				bindParameter(key, data);
			} else if (data is IPluginDefinition && data.type === Plugin.MACRO) {
				bindMacro(key, data, null);	
			}
		}
		
		/**
		 * 	@public
		 */
		public function unbind(key:uint):void {
		}
		
		/**
		 * 	@public
		 */
		public function getParameterBinding(parameter:IParameter):Boolean {
			return false;
		}

		/**
		 * 	@public
		 * 	Keyboard can only bind on executable items
		 */
		public function canBind(data:*):Boolean {
			return (data is IParameterExecutable) || data is IPluginMacro;
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
		public function stop():void {}
		
		/**
		 * 	@public
		 */
		override public function dispose():void {
			
			while (dispatchers.length) {
				var i:IEventDispatcher = dispatchers.pop();
				
				// add listeners
				i.removeEventListener(KeyboardEvent.KEY_DOWN,	handleKey);
				i.removeEventListener(KeyboardEvent.KEY_UP,	handleKey);

			}
		}

	}
}