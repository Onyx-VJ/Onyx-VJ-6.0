package onyx.host {

	import flash.utils.*;
	
	import onyx.core.*;
	import onyx.event.*;
	import onyx.plugin.*;
	import onyx.util.*;
	
	/**
	 *	@private 
	 */
	final internal class OnyxModuleManager {
		
		/**
		 * 	@public
		 */
		internal const running:Object	= {};
		
		/**
		 * 	@internal
		 */
		internal const modules:Vector.<IPluginModule>	= new Vector.<IPluginModule>();
		
		/**
		 * 	@internal
		 */
		internal var waiting:Array						= [];
		
		/**
		 * 	@private
		 */
		private var callback:Callback;
		
		/**
		 * 	@public
		 */
		internal function start(settings:Object, callback:Callback):void {
			
			this.callback	= callback;
			
			// need to load individual
			const plugins:Vector.<IPluginDefinition>	= Onyx.EnumeratePlugins(Plugin.MODULE).concat(Onyx.EnumeratePlugins(Plugin.INTERFACE));
			
			// message
			Console.Log(CONSOLE::MESSAGE, '');
			Console.Log(CONSOLE::MESSAGE, 'Initializing Modules ... ');
			Console.Log(CONSOLE::MESSAGE, '');
			
			CONFIG::DEBUG {
				Debug.object(settings);
			}
			
			for each (var plugin:IPluginDefinition in plugins) {
				var instance:IPluginModule = plugin.createInstance() as IPluginModule;
				
				if (instance) {
					var token:Object = settings[plugin.id];
					if (token) {
						instance.unserialize(token);
					}
					var status:PluginStatus = instance.initialize();
					switch (status) {
						case PluginStatus.ASYNC:
							
							instance.addEventListener(PluginStatusEvent.STATUS,			handleInstance);
							waiting.push(instance);
							
							break;
						default:
							handlePlugin(instance, status);
							break;
					}
				}
			}
			
			// check
			checkStart();
		}
		
		/**
		 * 	@private
		 */
		private function handlePlugin(instance:IPlugin, status:PluginStatus):void {
			
			Console.Log(CONSOLE::MESSAGE, instance.id + ': ' + status.message);
			switch (status) {
				case PluginStatus.OK:
					running[instance.id] = instance;
					modules.push(instance);
					break;
				default:
					Console.LogError(instance.id, status.message);
					instance.dispose();
			}
		}
		
		/**
		 * 	@private
		 */
		private function checkStart():void {

			trace('WAITING', waiting);
			if (waiting.length) {
				return;
			}
			
			for each (var module:IPluginModule in running) {
				
				CONFIG::DEBUG {
					module.start();
				}
				
				CONFIG::RELEASE {
					try {
						module.start();
					} catch (e:Error) {
						Console.LogError('Error starting module:', module.id + ':', e.message);
					}
				}
			}
			
			waiting = null;
			callback.exec();
		}
		
		/**
		 * 	@private
		 */
		private function handleInstance(e:PluginStatusEvent):void {
			var instance:IPlugin = e.currentTarget as IPlugin;
			instance.removeEventListener(PluginStatusEvent.STATUS, handleInstance);
			
			var index:int = waiting.indexOf(instance);
			if (index >= 0) {
				waiting.splice(index, 1);
			}
			
			handlePlugin(instance, e.status);
			
			// start?
			checkStart();
		}
		
		/**
		 * 	@public
		 */
		internal function stop():void {
			
			for each (var module:IPluginModule in running) {
				
				CONFIG::DEBUG {
					Console.Log(CONSOLE::DEBUG, 'Stopping:', module.id);
				}
				
				delete running[module.id];
				
				module.stop();
				module.dispose();

			}
		} 
	}
}