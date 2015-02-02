package onyx.host {
	
	import flash.desktop.*;
	import flash.display.*;
	import flash.display3D.*;
	import flash.events.*;
	import flash.geom.*;
	
	import onyx.core.*;
	import onyx.display.*;
	import onyx.host.flash.WindowFlash;
	import onyx.plugin.*;
	import onyx.util.*;
	
	/**
	 * 	@private
	 */
	final public class OnyxHostWeb extends OnyxHost implements IOnyxHost {
		
		/**
		 * 	@public
		 */
		override public function GetOriginWindow():IDisplayWindow {
			return new WindowFlash(stage);
		}
		
		/**
		 *	@public
		 */
		private function dispose(event:Event):void {

			// stop
			modules.stop();
			
			// pause
			Pause();

		}
		
		/**
		 * 	@public
		 */
		public function Exit():void {
			
		}
		
		/**
		 * 	@public
		 */
		override public function CreateWindow(type:String, chrome:String, mode:String, resizable:Boolean = false, minimizable:Boolean = false, maximizable:Boolean = false, closable:Boolean = true):IDisplayWindow {
			return new WindowFlash(stage);
		}
	}
}