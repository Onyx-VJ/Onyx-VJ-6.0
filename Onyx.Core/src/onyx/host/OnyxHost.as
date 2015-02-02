package onyx.host {
	
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.system.*;
	import flash.text.Font;
	import flash.utils.*;
	
	import onyx.cache.*;
	import onyx.core.*;
	import onyx.display.*;
	import onyx.event.*;
	import onyx.host.gl.*;
	import onyx.host.swf.*;
	import onyx.parameter.*;
	import onyx.plugin.*;
	import onyx.util.*;
	import onyx.util.encoding.*;
	
	import onyxui.assets.*;
	
	use namespace onyx_ns;
	
	/**
	 * 	@private
	 */
	public class OnyxHost extends EventDispatcher {
		
		/**
		 * 	@private
		 */
		onyx_ns const plugins:Object									= {};
		
		/**
		 * 	@private
		 * 	TODO: Make sure these are externalized -- should be loaded before initialization begins
		 */
		onyx_ns const pluginHosts:Object								= {};
		
		/**
		 * 	@private
		 */
		onyx_ns const pluginTypes:Vector.<Vector.<IPluginDefinition>>	= new Vector.<Vector.<IPluginDefinition>>(0x1D, true);
		
		/**
		 * 	@protected
		 */
		protected const modules:OnyxModuleManager						= new OnyxModuleManager();
		
		/**
		 * 	@protected
		 */
		protected var stage:Stage;
		
		/**
		 * 	@protected
		 */
		protected var settings:Object									= {};
		
		/**
		 * 	@protected
		 */
		protected var generatorFileTypes:Object							= {};
		
		/**
		 * 	@protected
		 */
		protected var cache:Object										= {};
		
		/**
		 * 	@protected
		 */
		protected const displays:Vector.<IDisplay>						= new Vector.<IDisplay>(0, true);
		
		/**
		 * 	@protected
		 */
		protected const channels:Object									= {
			0x00:	[],		// plugin.cpu
			0x01:	[]		// plugin.gpu
		}
		
		/**
		 * 	@public
		 */
		final public function GetDefaultGenerator(file:IFileReference):IPluginDefinition {
			return generatorFileTypes[file.extension];
		}
		
		/**
		 * 	@public
		 */
		public function OnyxHost():void {
			
			for (var count:int = 0; count < pluginTypes.length; count++) {
				pluginTypes[count] = new Vector.<IPluginDefinition>();
			}
			
			// set fixed
			pluginTypes.fixed		= true;
			
		}
		
		/**
		 * 	@public
		 */
		final public function RegisterChannel(channel:IChannel):void {
			
			if (channel is IChannelCPU) {
				
				// add
				channels[Plugin.CPU].push(channel);
				channels[Plugin.CPU].sortOn('name');
				
			}
			
			if (channel is IChannelGPU) {
				
				// push the channel
				channels[Plugin.GPU].push(channel);
				channels[Plugin.GPU].sortOn('name');
				
			}
		}
		
		/**
		 * 	@public
		 */
		final public function UnRegisterChannel(channel:IChannel):void {
			
			if (channel is IChannelCPU) {
				
				var arr:Array	= channels[Plugin.CPU];
				var index:int	= arr.indexOf(channel);
				if (index >= 0) {
					arr.splice(index, 1);
				}
				
			}
			
			if (channel is IChannelGPU) {
				
				arr		= channels[Plugin.GPU];
				index	= arr.indexOf(channel);
				if (index >= 0) {
					arr.splice(index, 1);
				}
			}
		}
		
		/**
		 * 	@public
		 */
		final public function GetChannels(type:uint):* {
			switch (type) {
				case Plugin.GPU:
					return Vector.<IChannelGPU>(channels[type]);
				case Plugin.CPU:
					return Vector.<IChannelCPU>(channels[type]);
			}
			return null;
		}
		
		/**
		 * 	@public
		 */
		final public function CreateDisplay(token:Object):IDisplay {
			
			var plugin:IPluginDefinition	= GetPlugin(token.id);
			if (!plugin) {
				return null;
			}
			
			var display:IDisplay			= plugin.createInstance() as IDisplay;
			display.unserialize(token);
			
			displays.fixed	= false;
			displays.push(display);
			displays.fixed	= true;
			
			// return
			return display;
		}
		
		/**
		 * 	@public
		 */
		final public function GetModules():Vector.<IPluginModule> {
			return modules.modules;
		}
		
		/**
		 * 	@public
		 */
		final public function GetPluginHost(type:String):IPluginHost {
			return pluginHosts[type.toLowerCase()];
		}
		
		/**
		 * 	@public
		 */
		final public function GetPluginExtensions():Object {
			
			const ret:Object = {};
			for (var i:String in pluginHosts) {
				ret[i] = true;
			}
			
			return ret;
		}
		
		/**
		 * 	@public
		 */
		public function CreatePluginDefinitions(extension:String, data:Object, callback:Function, file:IFileReference = null):void {
			const host:IPluginHost	= pluginHosts[extension.toLowerCase()];
			if (!host) {
				Console.LogError('Unknown host type');
				callback(null);
				return;
			}
			
			host.createDefinitions(data, file, callback);
		}
		
		/**
		 * 	@public
		 */
		public function GetScreens():Vector.<Rectangle> {
			return Vector.<Rectangle>([new Rectangle(0,0, stage.stageWidth, stage.stageHeight)]); 
		}
		
		/**
		 * 	@public
		 * 	
		 */	
		final public function RegisterPlugin(plugin:IPluginDefinition):void {
			
			if (plugins[plugin.id]) {
				return Console.Log(CONSOLE::WARNING, plugin.id, 'already exists!  Alternate skipped.');
			}
			
			// output
			Console.Log(CONSOLE::MESSAGE, plugin.id, 'registered');
			
			switch (plugin.type) {
				case Plugin.HOST:
					
					// register the host, but don't save it
					return RegisterPluginHost(plugin.info.fileType, plugin.createInstance() as IPluginHost);
					
				case Plugin.PROTOCOL:
					
					// if it has the protocol metadata, register it as a protocol
					if (plugin.info['protocol']) {
						
						var protocol:IPluginProtocol = plugin.createInstance() as IPluginProtocol;
						FileSystem.RegisterProtocol(plugin.info['protocol'], protocol);
						
					}
					
					break;
				case Plugin.GENERATOR:
					
					// do we need to associate this generator with a filetype?
					var fileTypes:Array = plugin.info.defaultFileTypes ? String(plugin.info.defaultFileTypes).split(';') : null;
					if (fileTypes) {
						for each (var type:String in fileTypes) {
							if (type) {
								
								CONFIG::DEBUG {
									Console.Log(CONSOLE::DEBUG, 'Registering Generator: ', type, ':', plugin.id);
								}
								
								// we need to test here for re-usable information
								
								// store the generator type!
								generatorFileTypes[type] = plugin;
								
							}
						}
					}
					
					break;
			}
			
			// save the plugin
			plugins[plugin.id]	= plugin;
			pluginTypes[plugin.type].push(plugin);
		}
		
		/**
		 * 	@public
		 */
		final public function GetModule(id:String):IPluginModule {
			return modules.running[id];
		}
		
		/**
		 * 	@public
		 */
		public function RegisterPluginHost(extension:String, host:IPluginHost):void {
			
			CONFIG::DEBUG {
				if (pluginHosts[extension.toLowerCase()]) {
					return Console.LogError('Host for extension: ' + extension + ' already exists.');
				}
			}
			
			if (!host) {
				return Console.LogError('Dependency host not found');
			}
			
			var status:PluginStatus = host.initialize();
			if (status !== PluginStatus.OK) {
				return Console.LogError('Host initialization error: ' + status.message);
			}
			
			// store the host
			pluginHosts[extension.toLowerCase()] = host;
			
			// registering the host
			Console.Log(CONSOLE::DEBUG, 'Registering: ', host);
		}
		
		/**
		 * 	@public
		 */
		public function GetRenderMode():String {
			return settings.mode;
		}
		
		/**
		 * 	@public
		 */
		final public function get frameRate():Number {
			return stage.frameRate;
		}
		
		/**
		 *	@public
		 */
		final public function GetDisplay(index:int):IDisplay {
			return displays[index];
		}
		
		/**
		 * 	@public
		 */
		final public function EnumeratePlugins(type:uint):Vector.<IPluginDefinition> {
			return pluginTypes[type];
		}
		
		/**
		 * 	@public
		 */
		final public function SetOrigin(stage:Stage):void {
			
			// we should override this when the onyx window is created
			
			this.stage	= stage;

		}
		
		/**
		 * 	@public
		 */
		final public function Initialize(info:LoaderInfo):void {
			
			// register a cache for bitmaps
			// todo: this should be a plugin
			SharedCache.registerType('BitmapData', new BitmapCache());
			
			// register the pixel font
			// todo: this should be a plugin too
			Font.registerFont(UIAssetPixelFont);
			
			// register the plugin host
			RegisterPluginHost('swf', new PluginSWFHost());
			
			// create definitions from the loader
			CreatePluginDefinitions('swf', info, function(plugins:Vector.<IPluginDefinition>):void {
				for each (var plugin:IPluginDefinition in plugins) {
					RegisterPlugin(plugin);
				}
			});
		}
		
		/**
		 * 	@public
		 */
		public function CreateWindow(type:String, chrome:String, mode:String, resizable:Boolean = false, minimizable:Boolean = false, maximizable:Boolean = false, closable:Boolean = true):IDisplayWindow {
			return null;
		}
		
		/**
		 * 	@public
		 */	
		final public function StartModules(settings:Object, callback:Callback):void {
			
			modules.start(settings, callback);
			
		}
		
		/**
		 * 	@public
		 */
		final public function Start(settings:Object):void {
			
			const screens:Vector.<Rectangle>	= GetScreens();
			
			// now create the displays
			for each (var token:Object in settings['Startup.Displays']) {
				
				if (!token.display) {
					return Console.LogError('Could not find display type in settings!');
				}
				
				// create window
				var windowToken:Object		= token.window;
				if (windowToken.screen === undefined) {
					return Console.LogError('Screen index not defined');
				}
				
				// we don't want to create a window, we're going to use the origin
				if (windowToken.screen === 'default') {
					return createLocalDisplay(token, GetOriginWindow());
				}
				
				// we're creating a new window, so kill it
				
				// check for fallback
				if (windowToken.screen >= screens.length) {
					if (!token.fallback) {
						return Console.LogError('Fallback not defined');	
					}
					windowToken = token.fallback;
				}
				
				var window:IDisplayWindow	= CreateWindow(windowToken.type, windowToken.systemChrome, windowToken.renderMode, false, false, false, false);
				var fullScreen:Boolean		= windowToken.fullScreen !== undefined ? windowToken.fullScreen : false;
				var bounds:Rectangle		= screens[windowToken.screen];
				window.alwaysInFront		= windowToken.alwaysInFront === undefined ? true : windowToken.alwaysInFront;
				
				if (fullScreen) {
					
					// calculate left/right/bottom/top
					window.bounds				= screens[windowToken.screen];
					window.fullScreen			= true;
					
				} else {
					
					var win:Rectangle			= bounds.clone();
					if (windowToken.width) {
						win.width	= windowToken.width; 
					}
					if (windowToken.height) {
						win.height	= windowToken.height; 
					}
					if (windowToken.right !== undefined) {
						win.x		= bounds.width - win.width;
					}
					if (windowToken.bottom !== undefined) {
						win.y		= bounds.height - win.height;
					}
					if (windowToken.left !== undefined) {
						win.x		= windowToken.left;
					}
					if (windowToken.top !== undefined) {
						win.y		= windowToken.top;
					}
					
					window.bounds				= win;
					window.fullScreen			= false;
				}
				
				// activate
				window.activate();
				
				// create 
				createLocalDisplay(token, window);
				
			}
			
			// STARTING
			Console.Log(CONSOLE::DEBUG, 'Starting Onyx ...');
			
		}
		
		private function createLocalDisplay(token:Object, window:IDisplayWindow):void {
			
			// first see if we can create the display
			var display:IDisplay = CreateDisplay(token.display);
			if (!display) {
				return Console.LogError('Unable to create display!');
			}
			
			// dispatch
			dispatchEvent(new OnyxEvent(OnyxEvent.DISPLAY_CREATE, display));
			
			var status:PluginStatus = display.initialize(window, token.display.parameters.x, token.display.parameters.y, token.display.parameters.width, token.display.parameters.height);
			if (status !== PluginStatus.OK) {
				return Console.LogError('Display Initialize Failure: ' + status.message);
			}
			
			// create layers
			var layers:int		= token.display.layers || 6;
			while (layers--) {
				display.createLayer();
			}
		}
		
		/**
		 * 	@public
		 */
		final public function StartDisplays():void {
			
			for each (var display:IDisplay in displays) {
				display.start();
			}
		}
		
		/**
		 * 	@public
		 */
		final public function Resume():void {
			
			//			// garbage collect first
			//			System.gc();
			//
			//			// NO DISPLAYS!
			//			if (!displays.length) {
			//				return Console.Log(CONSOLE::ERROR, 'NO DISPLAYS');
			//			}
			//			
			//			stage.addEventListener(Event.ENTER_FRAME,	handleRender);
			//			stage.addEventListener(Event.RENDER,		handleRender);
		}
		
		/**
		 * 	@public
		 */
		final public function Pause():void {
			//			
			//			// remove
			//			stage.removeEventListener(Event.ENTER_FRAME,	handleRender);
			//			
		}
		
		/**
		 * 	@public
		 */
		final public function CreateInstance(id:String, token:Object = null):IPlugin {
			const plugin:IPluginDefinition = plugins[id];
			if (!plugin) {
				return null;
			}
			var def:IPlugin = plugin.createInstance();
			if (token) {
				def.unserialize(token);
			}
			return def;
		}
		
		/**
		 * 	@public
		 */
		final public function GetPlugin(id:String):IPluginDefinition {
			return plugins[id];
		}
		
		/**
		 * 	@public
		 */
		public function GetDisplays():Vector.<IDisplay> {
			return displays; 
		}
		
		/**
		 * 	@public
		 */
		public function GetOriginWindow():IDisplayWindow {
			return null;
		}
	}
}