package onyx.host {
	
	import flash.desktop.*;
	import flash.display.*;
	import flash.display3D.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.utils.*;
	
	import onyx.core.*;
	import onyx.display.*;
	import onyx.host.air.*;
	import onyx.plugin.*;
	import onyx.util.*;

	/**
	 * 	@private
	 */
	final public class OnyxHostAIR extends OnyxHost implements IOnyxHost {
		
		/**
		 * 	@public
		 */
		override public function GetOriginWindow():IDisplayWindow {
			return new AIRWindow(stage.nativeWindow);
		}

		/**
		 * 	@public
		 */
		public function OnyxHostAIR():void {

			var window:NativeWindow = NativeApplication.nativeApplication.openedWindows[0];
			stage				= window.stage;
			
			// exiting?
			NativeApplication.nativeApplication.addEventListener(Event.EXITING, dispose);
				
		}
		
		/**
		 * 	@public
		 */
		public function Exit():void {
			NativeApplication.nativeApplication.exit(0);
		}
		
		/**
		 * 	@public
		 */
		override public function CreateWindow(type:String, chrome:String, renderMode:String, resizable:Boolean = false, minimizable:Boolean = false, maximizable:Boolean = false, closable:Boolean = true):IDisplayWindow {
			
			trace('creating window');
			
			const options:NativeWindowInitOptions		= new NativeWindowInitOptions();
			options.type								= type;
			options.resizable							= resizable;
			options.minimizable							= minimizable;
			options.maximizable							= maximizable;
			options.systemChrome						= chrome;
			options.renderMode							= renderMode;
			const window:AIRWindow						= new AIRWindow(new NativeWindow(options));
			return window;
		}

		/**
		 * 	@public
		 */
		override public function GetScreens():Vector.<Rectangle> {
			
			const screens:Array				= Screen.screens;
			const vect:Vector.<Rectangle>	= new Vector.<Rectangle>(screens.length, true);
			for (var count:int = 0; count < screens.length; ++count) {
				vect[count] = screens[count].bounds;
			}
			return vect; 
		}
		
		/**
		 *	@public
		 */
		private function dispose(event:Event):void {
			
			// dispose
			NativeApplication.nativeApplication.removeEventListener(Event.EXITING, dispose);
			
			// stop
			modules.stop();
			
			// pause
			Pause();
		}
	}
}