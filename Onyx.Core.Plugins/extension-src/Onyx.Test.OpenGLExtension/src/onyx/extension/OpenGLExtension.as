package onyx.extension {
	
	import flash.events.*;
	import flash.external.*;

	final public class OpenGLExtension {
		
		/**
		 * 	@private
		 */
		private static var refCount:int					= 0;
		
		/**
		 * 	@private
		 */
		private static var context:ExtensionContext;
		
		/**
		 * 	@public
		 */
		public function OpenGLExtension():void {

			if (++refCount === 1) {
				
				// context
				context = ExtensionContext.createExtensionContext("onyx.extension.OpenGLExtension", "");
				
				// listen for stuff
				context.addEventListener(StatusEvent.STATUS, handler);
				
			}

		}
		
		/**
		 * 	@private
		 */
		private function handler(e:Event):void {
			trace(e);
		}
		
		/**
		 * 	@public
		 */
		public function initialize():Boolean {
			return context.call("initialize") as Boolean;
		}
		
		/**
		 * 	@public
		 */
		public function getThreadID():int {
			return context.call("getThreadID") as int;
		}
		
		/**
		 * 	@public
		 */
		public function createDisplay():* {
			return context.call("createDisplay");
		}
		
		/**
		 * 	@public
		 */
		public function dispose():void {
		}
	}
}