package onyxui.state {
	
	import flash.data.EncryptedLocalStore;
	import flash.display.*;
	import flash.events.*;
	import flash.filesystem.*;
	import flash.net.*;
	import flash.utils.*;
	
	import onyx.core.*;
	import onyx.display.*;
	import onyx.event.OnyxEvent;
	import onyx.plugin.*;
	import onyx.util.*;
	import onyx.util.algo.*;

	use namespace onyx_ns;
	
	public final class InitState implements IState {
		
		/**
		 * 	@private
		 */
		private var library:File;
		
		/**
		 * 	@private
		 */
		private var files:Vector.<IFileReference>;
		
		/**
		 * 	@private
		 */
		private var stage:Stage;
		
		/**
		 * 	@private
		 */
		private var settings:Object;
		
		/**
		 * 	@private
		 */
		private var pluginSettings:Object	= {};
		
		/**
		 * 	@private
		 */
		private var plugins:Vector.<IPluginDefinition>	= new Vector.<IPluginDefinition>();
		
		/**
		 * 	@private
		 */
		private var callback:Callback;
		
		/**
		 * 	@private
		 */
		private var definitions:Array;
		
		/**
		 * 	@private
		 */
		private var copyResources:Vector.<File>;
		
		/**
		 * 	@private
		 */
		private var log:IFileStream;
		
		/**
		 * 	@private
		 */
		private var logTypes:Vector.<String>	= Vector.<String>([
			'VERBOSE', 'DEBUG', 'INFO', '\t', 'WARNING', 'ERROR'
		]);
		
		/**
		 * 	@public
		 */
		public function initialize(callback:Callback, data:Object):void {
			
			// callback!
			this.callback	= callback;
			
			// regiter resource mapping by default, so we can query all our local files
			FileSystem.RegisterFileMap('/onyx-app', File.applicationDirectory.nativePath, Onyx.GetPlugin('Onyx.Protocol.FileSystem'), PluginDomain);
			
			try {
				
				for each (var mapping:Object in data.mappings) {
					FileSystem.RegisterFileMap('/' + mapping.mapping, mapping.path, Onyx.GetPlugin('Onyx.Protocol.FileSystem'), PluginDomain);
				}

			} catch (e:Error) {
				Console.Log(CONSOLE::MESSAGE, 'A file mapping is defined but does not exist!\nPlease make sure your onyx-path contains valid mappings');
			}
			
			CONFIG::DEBUG {
				return beginStartupProcess();
			}
			
			// get the application crap
			FileSystem.Query(FileSystem.GetFileReference('/onyx-app'), new Callback(handleMappings), null, true);
		}
		
		/**
		 * 	@private
		 */
		private function handleMappings(files:Vector.<IFileReference>):void {
			
			var target:IFileReference;
			var copyResources:Array = [];
			for each (var file:IFileReference in files) {
				// make sure it's two levels deep at least
				if (file.path.indexOf('/', 10) > 0) {
					target = FileSystem.GetFileReference(file.path.substr(9));
					if (target && target is File && (!target.exists || target.dateModified < file.dateModified)) {
						copyResources.push(file);
					}
				}
			}
			
			// copy resources?
			if (copyResources.length) {
				this.copyResources = Vector.<File>(copyResources);
				copyNext();
			} else {
				beginStartupProcess();
			}
		}
		
		/**
		 * 	@private
		 */
		private function copyNext(e:Event = null):void {
			
			if (e) {
				file = e.currentTarget as File;
				file.removeEventListener(Event.COMPLETE,		copyNext);
				file.removeEventListener(IOErrorEvent.IO_ERROR, copyNext);
			}
			
			var file:File	= copyResources.shift();
			if (file) {
				var repl:RegExp	= new RegExp('\\\\', 'g');
				var path:String = file.nativePath.replace(File.applicationDirectory.nativePath, '');
				path = path.replace(repl, '/');
				
				var target:IFileReference	= FileSystem.GetFileReference(path);
				file.addEventListener(Event.COMPLETE,			copyNext);
				file.addEventListener(IOErrorEvent.IO_ERROR,	copyNext);
				Console.Log(CONSOLE::MESSAGE, 'Copying: ' + target.path);
				file.copyToAsync(target as File, true);
				
			} else {
				
				beginStartupProcess();
				
			}
		}
		
		/**
		 * 	@private
		 */
		private function beginStartupProcess():void {
			
			log = FileSystem.CreateFileStream(FileSystem.GetFileReference('/onyx/logs/startup.log'), FileSystem.UPDATE);
			log.position = 0;
			log.truncate();

			// register
			Console.RegisterListener(updateLog);
			
			// send message
			
			Console.Log(CONSOLE::MESSAGE, 'Onyx v5.00.00');
			Console.Log(CONSOLE::MESSAGE, 'copyright © 2003-' + new Date().fullYear + ' by Daniel Hai');
			Console.Log(CONSOLE::MESSAGE, '');
			
			// settings
			Console.Log(CONSOLE::MESSAGE, 'Loading Settings');
			
			// load settings
			FileSystem.ReadFile(FileSystem.GetFileReference('/onyx/core/Onyx.Core.conf'), new Callback(handleSettings));
		}
		
		/**
		 * 	@private
		 */
		private function updateLog(type:int, ... args:Array):void {
			log.writeUTFBytes(logTypes[type] + '\t' + args.join(' ') + '\r\n');
		}
		
		/**
		 * 	@private
		 */
		private function handleSettings(data:Object, ref:IFileReference):void {
			
			// store settings
			settings = data;
			
			// create the displays
			loadPlugins();
			
		}
		
		/**
		 * 	@private
		 */
		private function loadPlugins():void {
			
			const extensions:Object = Onyx.GetPluginExtensions();
			extensions['conf']		= true;
			const ext:Array	= [];
			for (var i:String in extensions) {
				ext.push('*.' + i);
			}
			
			Console.Log(CONSOLE::MESSAGE, '');
			Console.Log(CONSOLE::MESSAGE, 'Scanning plugins');
			Console.Log(CONSOLE::MESSAGE, '');
			
			// query the plugins
			FileSystem.Query(
				FileSystem.GetFileReference('/onyx/plugins'),
				new Callback(handlePlugins),
				new Callback(function(extensions:Object, ref:IFileReference):Boolean {
					
					// test for a disable, if true, then exclude all those folders
					if (!ref.isDirectory) {
						var shortName:String = ref.name.substr(0, ref.name.length - ref.extension.length - 1);
						if (settings['Startup.Disable'][shortName]) {
							return false;
						}
					}
					
					return ref.isDirectory || extensions[ref.extension] !== undefined;
				}, [extensions]),
				true
			);

		}

		/**
		 * 	@private
		 */
		private function handlePlugins(files:Vector.<IFileReference>):void {

			// err, no plugins?
			if (!files.length) {
				return Console.LogError('No Plugins Found!?!?!?!?');
			}
			
			this.files = files;
			
			for each (var file:IFileReference in files) {
				if (!file.isDirectory) {
					Console.Log(CONSOLE::DEBUG, 'Reading:', file.name);
					FileSystem.ReadFile(file, new Callback(handleRegistration));
				}
			}
		}
		
		/**
		 * 	@private
		 * 	Re-scan is called after a pluginhost is registered
		 */
		private function rescan():void {
			
		}
		
		/**
		 * 	@private
		 */
		private function handleRegistration(data:Object, file:IFileReference):void {
			
			switch (file.extension) {
				case 'conf':

					// store the setting
					pluginSettings[file.name.substr(0, -5)] = data;
					
					break;
				default:
					
					// load the plugin
					loadPlugin(data, file);
					
					break;
			}

			
			// remove the file from the list
			files.splice(files.indexOf(file), 1);
			if (!files.length) {
				return registerPlugins();
			}
		}
		
		/**
		 * 	@private
		 */
		private function loadPlugin(data:Object, file:IFileReference):void {
			
			Onyx.CreatePluginDefinitions(file.extension, data, handlePluginCreation, file);

		}
		
		/**
		 * 	@private
		 */
		private function handlePluginCreation(plugins:Vector.<IPluginDefinition>):void {
			
			if (plugins) {
				for (var count:int = plugins.length - 1; count >= 0; --count) {
					var plugin:IPluginDefinition = plugins[count];
					if (plugin.type === Plugin.HOST) {
						
						plugins = plugins.splice(plugins.indexOf(plugin), 1);
						
						// register the host
						registerPluginHost(plugin);
					}
				}
				this.plugins = this.plugins.concat(plugins);
			}
		}
		
		/**
		 * 	@private
		 */
		private function registerPluginHost(definition:IPluginDefinition):Boolean {
			
			var settings:Object = pluginSettings[definition.id];
			
			// prelook ahead based on the token
			if (settings && (settings.enabled === false)) {
				return false;
			}
			
			// unserialize setting?
			if (pluginSettings[definition.id]) {
				definition.unserialize(pluginSettings[definition.id]);
			}

			return true;
		}
		
		/**
		 * 	@private
		 */
		private function registerPlugins():void {
			
			// we need to test dependencies
			const tree:DependencyTree	= new DependencyTree();
			const hash:Object			= {};
			
			// 
			for each (var i:String in this.settings['Startup.Disable']) {
				if (!pluginSettings[i]) {
					pluginSettings[i] = {};
				}
				
				pluginSettings[i].enabled = false;
			}
			
			for each (var definition:IPluginDefinition in plugins) {

				var settings:Object = pluginSettings[definition.id];
				
				// prelook ahead based on the token
				if (settings && (settings.enabled === false)) {
					continue;
				}
				
				// unserialize setting?
				if (pluginSettings[definition.id]) {
					definition.unserialize(pluginSettings[definition.id]);
				}
				
				// is it enabled?
				if (definition.enabled) {
					hash[definition.id] = definition;
				}
			}
			
			// loop through again, test dependencies, if it's ok, add the node
			for each (definition in hash) {
				
				var dependencies:String = definition.dependencies;
				var add:Boolean = true;
				
				if (dependencies) {
					var ids:Array	= dependencies.split(',');
					
					for each (var id:String in ids) {
						if (!id) {
							continue;
						}
						
						// exists in startup?  if not remove this plugin from the list
						if (!hash[id]) {
							Console.Log(CONSOLE::WARNING, 'Skipping: ', definition.id, '[' + id + ']');
							delete hash[definition.id];
							add = false;
							break;
						}
					}
				}
				
				if (add) {
					tree.addNode(definition);
				}
			}
			
			for each (definition in hash) {
				
				dependencies = definition.dependencies;
				if (!dependencies) {
					continue;
				}
				
				ids = dependencies.split(',');
				for each (id in ids) {
					if (!id) {
						continue;
					}
					tree.addEdge(definition, hash[id]);
				}
			}
			
			var sorted:Array	= tree.sort();
			if (!sorted) {
				Console.LogError('Circular dependencies detected!');
			}
			
			// do it in reverse
			this.definitions	= sorted.reverse();
			
			// register!
			registerDefinition();

		}
		
		/**
		 * 	@private
		 */
		private function registerDefinition():void {
			
			var definition:IPluginDefinition = definitions.pop();
			if (!definition) {
				
				// start!
				startModules();
				
			} else {
				
				// register the plugin
				Onyx.RegisterPlugin(definition);
				
				// immediate
				CONFIG::DEBUG {
					// Delay.create(5, new Callback(registerDefinition));
					return registerDefinition();
				}
				
				// release mode slow
				CONFIG::RELEASE {
					Delay.create(5, new Callback(registerDefinition));
				}
			}
		} 
		
		/**
		 * 	@private
		 */
		private function startModules():void {
			
			// start
			Onyx.StartModules(pluginSettings, new Callback(startOnyx));
			
		}
		
		/**
		 * 	@private
		 */
		private function startOnyx():void {
			
			// start!
			Onyx.Start(settings);
			
			// callback
			complete();
			
		}
		
		/**
		 * 	@private
		 */
		private function complete():void {
			
			Console.Log(CONSOLE::MESSAGE, 'Make art ... ');
			
			// delay
			CONFIG::DEBUG {
				Delay.create(1500, new Callback(delayComplete));
			}
			
			CONFIG::RELEASE {
				Delay.create(1500, new Callback(delayComplete));
			}
			
			Onyx.StartDisplays();
		}
		
		/**
		 * 	@private
		 */
		private function delayComplete():void {
			
			// callback
			callback.exec(settings);
			
			// remove
			settings = null;
			callback = null;
			
			// register
			Console.Unregister(updateLog);
			
			// close the log
			log.close();
			
			// dispatch
			Onyx.dispatchEvent(new OnyxEvent(OnyxEvent.ONYX_INITIALIZE_COMPLETE));

		}
		
		/**
		 * 	@public
		 */
		public function dispose():void {
		}
	}
}