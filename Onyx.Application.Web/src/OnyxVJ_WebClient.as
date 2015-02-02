package {
	
	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	import flash.system.*;
	import flash.utils.*;
	
	import onyx.core.*;
	import onyx.plugin.*;
	import onyx.util.*;
	
	import onyxui.assets.*;
	import onyxui.core.*;
	import onyxui.screens.*;
	import onyxui.state.*;
	
	[SWF(width='1280', height='1024', frameRate='60', backgroundColor='0x333333')]
	final public class OnyxVJ_WebClient extends Sprite {

		/**
		 * 	@private
		 */
		private var screen:InitScreen;
		
		/**
		 * 	@private
		 */
		private var info:LoaderInfo				= new Loader().contentLoaderInfo;
		
		/**
		 * 	@private
		 */
		private var current:Object;
		
		/**
		 * 	@private
		 * 	Loader our default objects that we need to actually start loading things
		 */
		private const queue:Array				= [
			{	
				type:		Plugin.HOST,
				path:		'core/Onyx.PluginHost.SWF.swf',
				definition:	'onyx.host.swf::PluginSWFHost',
				extension:	'swf'
			}, {
				type:		Plugin.HOST,
				extension:	'onx',
				definition:	'onyx.host.gl::PluginGLHost',
				path:		'core/Onyx.PluginHost.GL.swf'
			}, {
				type:		Plugin.PROTOCOL,
				path:		'core/Onyx.Protocol.HTTP.swf'
			}];
		
		/**
		 * 	@public
		 */
		public function OnyxVJ_WebClient():void {

			// initialize
			stage.align							= StageAlign.TOP_LEFT;
			stage.scaleMode						= StageScaleMode.NO_SCALE;
			stage.quality						= StageQuality.MEDIUM;
			stage.displayState					= StageDisplayState.FULL_SCREEN_INTERACTIVE;
			
			// initialize
			Onyx.Initialize(stage);
			
			// queuenext
			queueNext();

		}
		
		/**
		 * 	@private
		 */
		private function queueNext(e:Event = null):void {
			
			if (e && current) {
				
				// depending on the resource, load
				switch (current.type) {
					case Plugin.HOST:
						
						const c:Class = info.applicationDomain.getDefinition(current.definition) as Class;
						Onyx.RegisterPluginHost(current.extension, new c());
						
						break;
					case Plugin.PROTOCOL:
						
						Onyx.RegisterPlugin(Onyx.CreatePluginDefinitions('swf', info)[0]);
						
						break;
				}
			}
			
			current = queue.shift();
			if (current) {
				info.addEventListener(Event.COMPLETE, queueNext);
				info.loader.load(new URLRequest(current.path));
			} else {
				initialize();
			}
		}
		
		/**
		 * 	@private
		 */
		private function initialize():void {
			
			const serial:Object = {
				queryPath:	'D:\\Projects\\Onyx-VJ\\Onyx-VJ\\script\\http-manifest',
				rootPath:	'D:\\Projects\\Onyx-VJ\\Onyx-VJ\\bin'
			}

			// register mapping
			FileSystem.RegisterMap('/library',	Onyx.GetPlugin('Onyx.Protocol.HTTP'), serial);
			FileSystem.RegisterMap('/plugins',	Onyx.GetPlugin('Onyx.Protocol.HTTP'), serial);
			FileSystem.RegisterMap('/settings', Onyx.GetPlugin('Onyx.Protocol.HTTP'), serial);

			// init
			screen = new InitScreen(stage, 
				new InitState()
			);
			screen.initialize(new Callback(setupHost));
		}
		
		/**
		 * 	@private
		 */
		private function setupHost():void {
			
			// close the child windows
			screen.dispose();

			// initialize the ui
			OnyxApp.Initialize(Onyx.GetStage());
			
		}
	}
}