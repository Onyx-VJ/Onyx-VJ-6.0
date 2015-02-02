package onyx.ui.core {

	import avmplus.*;
	
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.system.*;
	import flash.text.*;
	import flash.utils.*;
	
	import onyx.core.*;
	import onyx.event.*;
	import onyx.plugin.*;
	import onyx.ui.component.*;
	import onyx.ui.factory.*;
	import onyx.ui.parameter.*;
	import onyx.ui.window.*;
	import onyx.ui.window.channel.*;
	import onyx.ui.window.layer.*;
	import onyx.util.*;
	
	use namespace onyx_ns;
	
	[PluginInfo(
		id			= 'Onyx.UI.Desktop',
		name		= 'Onyx.UI.Desktop',
		vendor		= 'Daniel Hai',
		version		= '1.0',
		priority	= '-1'		// run last
	)]
	
	public final class OnyxUIModule extends PluginModule implements IPluginModule {
		
		/**
		 * 	@private
		 * 	Settings from the skin.conf
		 */
		private var settingsUI:Object;
		
		/**
		 * 	@private
		 * 	Settings fom Onyx.UI.Desktop.conf
		 */
		private var settings:Object;
		
		/**
		 * 	@private
		 */
		private const styleManager:Object	= {};
		
		/**
		 * 	@private
		 */
		private var root:UIStage;
		
		/**
		 * 	@private
		 */
		private var window:IDisplayWindow;
		
		/**
		 * 	@private
		 */
		private var skinRoot:IFileReference;
		
		/**
		 * 	@public
		 */
		public function initialize():PluginStatus {

			try {
				var skinPath:String = this.settings['UI.Display']['skin'];
			} catch (e:Error) {
				skinPath = '/1600x1200';
			}

			// skin path
			skinRoot = FileSystem.GetFileReference('/onyx/data/Onyx.UI.Desktop' + skinPath);
			if (!skinRoot.exists) {
				return new PluginStatus('Error loading skin!');
			}
			
			const config:IFileReference = skinRoot.resolve('skin.conf');
			if (!config.exists) {
				return new PluginStatus('Skin configuration file does not exist!');
			}
			
			// read
			FileSystem.ReadFile(config, new Callback(readConfig));

			// return asynchronous, meaning this must dispatch a module complete
			return PluginStatus.ASYNC;
		}
		
		/**
		 * 	@private
		 */
		private function readConfig(data:Object, file:IFileReference):void {
			
			// send a message out
			Console.Log(CONSOLE::MESSAGE, 'Loading Skin Information: ', skinRoot.name);
			
			// now load the skin factories
			var skinPath:IFileReference = skinRoot.resolve('skin.swf');
			if (!skinPath.exists) {
				skinPath = skinRoot.resolve('../global-skin.swf');
			}
			if (!skinPath) {
				dispatchEvent(new PluginStatusEvent(PluginStatusEvent.STATUS, new PluginStatus('Error reading skin file')));
				return;
			}
			
			// store settings
			settingsUI = data;
			
			// read the skins
			FileSystem.ReadFile(skinPath, new Callback(dispatchComplete), UIFactoryDefinitions.ASSET_DOMAIN);
			
		}
		
		/**
		 * 	@private
		 */
		private function dispatchComplete(... args:Array):void {
			
			// register!
			UIFactoryDefinitions.registerFactories(
				new UIFactory(UIBitmap),
				new UIFactory(UITextField),
				new UIFactory(UISkin),
				new UIFactory(UIButton),
				new UIFactory(UIButtonSkin),
				new UIFactory(UIScrollPane),
				new UIFactory(UIScrollBar),
				new UIFactory(UIScrollContent),
				new UIFactory(UILayerPreview),
				new UIFactory(UILayerTransport),
				new UIFactory(UILayerScrub),
				new UIFactory(UIParameter),
				new UIFactory(UIFilterList),
				new UIFactory(UIParameterList),
				new UIFactory(UILayer),
				new UIFactory(UIDisplay),
				new UIFactoryWindow(WindowFrameCounter),
				new UIFactory(WindowLayer),
				new UIFactory(WindowDisplay),
				new UIFactoryWindow(WindowConsole),
				new UIFactoryWindow(WindowFileBrowser),
				new UIFactoryWindow(WindowFilterBrowser),
				new UIFactory(WindowMixer)
			);
			
			var tokens:Object = settingsUI.factories;
			for (var i:String in tokens) {
				UIFactoryDefinitions.Unserialize(i, tokens[i]);
			}
			
			var screenSetting:Object	= settings['UI.Display'];
			
			// where?
			if (screenSetting['screen'] === 'default') {
				window = Onyx.GetOriginWindow();
			} else {
				window = createWindow();
			}
			
			if (!window) {
				dispatchEvent(new PluginStatusEvent(PluginStatusEvent.STATUS, new PluginStatus('No window!')));
				return;
			}
			
			window.stage.addChild(root = new UIFactory(UIStage).createInstance());
			if (screenSetting.bounds) {
				
				trace(
					screenSetting.bounds.x,
					screenSetting.bounds.y,
					screenSetting.bounds.width,
					screenSetting.bounds.height
				);
				root.setBounds(
					screenSetting.bounds.x,
					screenSetting.bounds.y,
					screenSetting.bounds.width,
					screenSetting.bounds.height
				);
			}
			
			var keyboardInterface:IPluginModuleInterface = Onyx.GetModule('Onyx.Interface.Keyboard') as IPluginModuleInterface;
			if (keyboardInterface) {
				keyboardInterface.addDispatcher(window.stage);
			}
			
			// complete
			dispatchEvent(new PluginStatusEvent(PluginStatusEvent.STATUS, PluginStatus.OK));

		}
		
		/**
		 * 	@private
		 */
		private function createWindow():IDisplayWindow {

			// sort
			var window:IDisplayWindow	= Onyx.CreateWindow('normal', 'none', 'direct');
			window.title				= 'Onyx-VJ';
//			var settings:Object			= this.settings['UI.Display'];
//			if (settings.bounds) {
//				var bounds:Object	= settings.bounds;
//				window.bounds = new Rectangle(bounds.x, bounds.y, bounds.width, bounds.height);
//			}
			
			window.addEventListener(Event.CLOSE, handleClose);
			window.stage.quality = StageQuality.LOW;
			
			return window;
		}
		
		/**
		 * 	@private
		 */
		private function handleClose(e:Event):void {
			Onyx.Exit();
		}
		
		/**
		 * 	@public
		 */
		override public function unserialize(token:*):void {
			this.settings				= token;
		}
		
		/**
		 * 	@public
		 */
		public function start():void {

			if (!window) {
				throw new Error('WINDOW CREATION FAILED');
			}
			
			sortPlugins();
			
			AppStage					= window.stage;
			
			var settings:Object			= this.settings['UI.Display'];
//			if (settings.bounds) {
//				var bounds:Object		= settings.bounds;
//				window.bounds			= new Rectangle(bounds.x, bounds.y, bounds.width, bounds.height);
//			}
			
			var startup:Array	= [
				'Onyx.UI.Desktop.FrameCounter',
				'Onyx.UI.Desktop.Layers',
				'Onyx.UI.Desktop.Displays',
				'Onyx.UI.Desktop.Console',
				'Onyx.UI.Desktop.FileBrowser',
				'Onyx.UI.Desktop.FilterBrowser',
				'Onyx.UI.Desktop.Mixer'
			];
			
			for each (var id:String in startup) {
				root.addChild(UIFactoryDefinitions.CreateInstance(id));
			}

			// listen for an init
			Onyx.addEventListener(OnyxEvent.ONYX_INITIALIZE_COMPLETE, activate);

		}
		
		private function sortPlugins():void {
			
			const sortObjects:Object	= settings['Plugin.Sort'];
			const sortPairs:Object	= { 
				BlendMode:	Plugin.BLENDMODE,
				Filter:		Plugin.FILTER,
				PlayMode:	Plugin.PLAYMODE,
				Font:		Plugin.FONT
			}
			
			const popType:Function		= function(a:String):String {
				var index:int = a.indexOf('::');
				if (index !== -1) {
					return a.substr(0, index);
				}
				return a;
			}
			
			const SORT_DEFINED:Function = function(a:IPluginDefinition, b:IPluginDefinition):int {
				
				var ai:int = sorted ? sorted.indexOf(popType(a.id)) : -1;
				var bi:int = sorted ? sorted.indexOf(popType(b.id)) : -1;
				
				if (ai === bi) {
					return a.id.localeCompare(b.id);
				} else if (bi === -1) {
					return -1;
				} else if (ai === -1) {
					return 1;
				} else if (ai > bi){
					return 1;
				} else {
					return -1;
				}
			}
			
			const SORT_UNDEFINED:Function = function(a:IPluginDefinition, b:IPluginDefinition):int {
				return a.id.localeCompare(b.id)
			}
			
			for (var i:String in sortPairs) {
				var sorted:Object	= sortObjects[i];
				var type:int		= sortPairs[i];	
				if (sorted) {
					Onyx.EnumeratePlugins(type).sort(SORT_DEFINED);
				} else {
					Onyx.EnumeratePlugins(type).sort(SORT_UNDEFINED);
				}
			}
			
			sorted = sortObjects.BlendMode;
			Onyx.EnumeratePlugins(0x10 | Plugin.BLENDMODE).sort(SORT_DEFINED);
			
			sorted = sortObjects.Filter;
			Onyx.EnumeratePlugins(0x10 | Plugin.FILTER).sort(SORT_DEFINED);
		}
		
		/**
		 * 	@private
		 */
		private function activate(e:*):void {
			window.activate();
			Onyx.removeEventListener(OnyxEvent.ONYX_INITIALIZE_COMPLETE, activate);
		}
		
		/**
		 * 	@public
		 */
		public function stop():void {}
	}
}