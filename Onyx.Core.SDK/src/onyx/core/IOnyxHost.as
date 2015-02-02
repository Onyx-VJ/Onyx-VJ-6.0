package onyx.core {
	
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	
	import onyx.display.*;
	import onyx.parameter.*;
	import onyx.plugin.*;
	import onyx.util.*;
	
	/**
	 * 	@public
	 */
	public interface IOnyxHost extends IEventDispatcher {
		
		/**
		 * 	@public
		 * 	Returns the initial window that was created with the application
		 */
		function Initialize(info:LoaderInfo):void;
		
		/**
		 * 	@public
		 * 	Creates an Instance of a Plugin by ID
		 */
		function CreateInstance(id:String, token:Object = null):IPlugin;
		
		/**
		 * 	@public
		 * 	Returns a display by Index
		 */
		function GetDisplay(index:int):IDisplay;
		
		/**
		 * 	@public
		 * 	Returns the initial window that was created with the application
		 */
		function GetDisplays():Vector.<IDisplay>;
		
		/**
		 * 	@public
		 */
		function SetOrigin(stage:Stage):void;
		
		/**
		 * 	@public
		 * 	Registers a group of plugins
		 */
		function RegisterPlugin(plugins:IPluginDefinition):void;
		
		/**
		 * 	@public
		 */
		function GetOriginWindow():IDisplayWindow;

		/**
		 * 	@public
		 * 	Creates a generator from a file
		 */
		function GetDefaultGenerator(file:IFileReference):IPluginDefinition;
		
		/**
		 * 	@public
		 * 	Returns a vector of screen rectangles
		 */
		function GetScreens():Vector.<Rectangle>;
		
		/**
		 * 	@public
		 */
		function CreateWindow(type:String, chrome:String, mode:String, resizable:Boolean = false, minimizable:Boolean = false, maximizable:Boolean = false, closable:Boolean = true):IDisplayWindow;

		/**
		 * 	@public
		 * 	Registers a group of plugins
		 */
		// function CreatePluginDefinitions(extension:String, data:Object, callback:Function, file:IFileReference = null):void;

		/**
		 * 	@public
		 * 	Returns a Plugin Definition by ID
		 */
		function GetPlugin(id:String):IPluginDefinition;
		
		/**
		 * 	@public
		 * 	Returns the plugin host for a particular extension.  Required for creating parameters
		 */
		function GetPluginHost(type:String):IPluginHost;

		/**
		 * 	@public
		 * 	Returns a module residing in memory
		 */
		function GetModule(id:String):IPluginModule;
		
		/**
		 * 	@public
		 * 	Returns all modules residing in memory
		 */
		function GetModules():Vector.<IPluginModule>;

		/**
		 * 	@public
		 * 	Returns an object that contains extensions that can be loaded
		 */
		// function GetPluginExtensions():Object;

		/**
		 * 	@public
		 * 	Enumerates Plugins of a specific type (see onyx.plugin.Plugin)
		 */
		function EnumeratePlugins(type:uint):Vector.<IPluginDefinition>;

		/**
		 * 	@public
		 * 	Registers a channel for use
		 */
		function RegisterChannel(channel:IChannel):void;
		
		/**
		 * 	@public
		 * 	UnRegisters a channel for use
		 */
		function UnRegisterChannel(channel:IChannel):void;
		
		/**
		 * 	@public
		 * 	Registers a channel for use
		 */
		function GetChannels(type:uint):*;
		
		/**
		 * 	@public
		 */
		// function StartModules(settings:Object, callback:Callback):void;
		
		/**
		 * 	@public
		 */
		function Start(settings:Object):void;
		
		/**
		 * 	@public
		 * 	Exits the application
		 */
		function Exit():void;
		
	}
}