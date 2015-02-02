package onyxui.core {

	import avmplus.*;
	
	import flash.geom.*;
	import flash.system.*;
	import flash.text.*;
	import flash.utils.*;
	
	import onyx.core.*;
	import onyx.event.*;
	import onyx.plugin.*;
	import onyx.util.*;
	
	import onyxui.assets.UIAssetButtonSkin;
	import onyxui.assets.UIAssetWindowSkin;
	import onyxui.component.*;
	import onyxui.factory.UIFactory;
	import onyxui.factory.UIFactoryWindow;
	import onyxui.window.*;
	
	use namespace onyx_ns;
	
	[PluginInfo(
		id			= 'Onyx.UI.Desktop',
		name		= 'Onyx.UI.Desktop',
		vendor		= 'Daniel Hai',
		version		= '1.0'
	)]
	
	public final class OnyxUIModule extends PluginModule implements IPluginModule {
		
		onyxui.component.UIButtonSkin;
		
		/**
		 * 	@private
		 */
		private const object_factories:Object = {
			textField:	onyxui.component.UITextField,
			windowSkin:	onyxui.assets.UIAssetWindowSkin,
			skin:		onyxui.component.UISkin,
			buttonSkin:	onyxui.assets.UIAssetButtonSkin
			
		};
		
		/**
		 * 	@private
		 * 	Stores metadata for factories 
		 */
		private const META_CACHE:Dictionary		= new Dictionary();
		
		/**
		 * 	@private
		 */
		private var settings:Object;
		
		/**
		 * 	@private
		 */
		private var factories:Array	= [];
		
		/**
		 * 	@public
		 */
		public function initialize():PluginStatus {
			
			// dispatch later
			Delay.create(10, new Callback(dispatchComplete));

			// return asynchronous, meaning this must dispatch a module complete
			return PluginStatus.ASYNC;
		}
		
		/**
		 * 	@private
		 */
		private function dispatchComplete(... args:Array):void {
			
			dispatchEvent(new OnyxEvent(OnyxEvent.MODULE_INIT_COMPLETE, this));
			
		}
		
		/**
		 * 	@public
		 */
		override public function unserialize(token:*):void {
			
			var sortObjects:Object	= token['Plugin.Sort'];
			for (var i:String in sortObjects) {
				// var sorted:Array	= sortObjects[i] || [];
				var enum:int		= -1;
				switch (i) {
					case 'BlendMode':
						enum = Plugin.BLENDMODE;
						break;
					case 'PlayMode':
						enum = Plugin.PLAYMODE;
						break;
				}
				
				if (enum !== -1) {
					sortPlugins(enum, sortObjects[i]);
				}
			}
		}
		
		/**
		 * 	@private
		 */
		private function sortPlugins(type:int, sorted:Array):void {
			
			Onyx.EnumeratePlugins(type).sort(function(a:IPluginDefinition, b:IPluginDefinition):int {
				
				var ai:int = sorted.indexOf(a.id);
				var bi:int = sorted.indexOf(b.id);
				
				if (ai === -1) {
					return 1;
				}
				
				if (bi === -1) {
					return 1;	
				}
				
				return (ai === bi ? 0 : (ai > bi ? 1 : -1));
			});
		}
		
		/**
		 * 	@public
		 */
		public function start():void {
			
			// sort
			var window:IDisplayWindow	= Onyx.GetOriginWindow();
			var settings:Object			= plugin.info.settings['UI.Display'];
			if (settings.bounds) {
				var bounds:Object	= settings.bounds;
				window.bounds = new Rectangle(bounds.x, bounds.y, bounds.width, bounds.height);
			}
			
//			
//			// go through all the modules and see if we have ui
//			for each (var module:IPluginModule in Onyx.GetModules()) {
//				
//				var c:Class = module.getUserInterface();
//				if (c) {
//					
//					// creating user interface for module?
//					OnyxUI.CreateFactory(c);
//					
//				}
//				
//			};

			// add items
			var ui:OnyxUI			= new OnyxUI();
			ui.unserialize({ top: 10, left: 10, right:10, bottom:10 });
			window.stage.addChild(ui);
			
			// add frame counter
			var factory:UIFactoryWindow = new UIFactoryWindow(WindowFrameCounter);
			ui.addChild(factory.createInstance());
			
			var buttonFact:UIFactory	= new UIFactory(UIButton);
			var button:UIObject = buttonFact.createInstance({ label: 'abcd' });
			ui.addChild(button);

		}
		
		/**
		 * 	@public
		 */
		public function stop():void {}
	}
}