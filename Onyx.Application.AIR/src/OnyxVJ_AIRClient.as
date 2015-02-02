package {
	
	import flash.desktop.*;
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.net.*;
	import flash.system.*;
	
	[SWF(width='1280', height='1024', frameRate='60', backgroundColor='0x333333')]
	final public class OnyxVJ_AIRClient extends Sprite {
		
		/**
		 * 	@private
		 */
		private var loader:Loader				= new Loader();
		
		/**
		 * 	@private
		 */
		private var domain:ApplicationDomain	= new ApplicationDomain(ApplicationDomain.currentDomain);
		
		/**
		 * 	@public
		 */
		public function OnyxVJ_AIRClient():void {
			
			var context:LoaderContext	= new LoaderContext();
			context.applicationDomain	= domain;
			context.allowCodeImport		= false;
			
			// load
			stage.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, handleError);
			loader.contentLoaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, handleError);
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, handleLoader);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, handleLoader)
			loader.load(new URLRequest('onyx/core/Onyx.Core.swf'), context);

			stage.nativeWindow.bounds	= new Rectangle(0,0,1920, 1200);
			stage.nativeWindow.activate();
			
			this.xyz();
			
		}
		
		/**
		 * 	@private
		 */
		private function handleError(e:UncaughtErrorEvent):void {
			throw new Error(e.error);
		}
		
		/**
		 * 	@private
		 */
		private function handleLoader(e:Event):void {
			
			const info:LoaderInfo = e.currentTarget as LoaderInfo;
			info.removeEventListener(Event.COMPLETE,		handleLoader);
			info.removeEventListener(IOErrorEvent.IO_ERROR, handleLoader);
			
			if (e is ErrorEvent) {
				return NativeApplication.nativeApplication.exit(2);
			}
			
			var o:Object		= domain.getDefinition('onyx.core::Onyx') as Object;
			o.Initialize(loader.contentLoaderInfo);
			
			var c:Class			= domain.getDefinition('onyxui.screens::InitScreen') as Class;
			var s:Object		= new c();
			s.initialize();
			
			// unload
			loader.unload();
			loader = null;

		}
		
		private function xyz(a:String):void {
			
		}
	}
}