package com.danielhai.cpu {
	
	import flash.events.*;
	
	import onyx.core.*;
	import onyx.display.*;
	import onyx.event.*;

	public final class SharedBufferFrame {
		
		/**
		 * 	@private
		 */
		public var surface:DisplaySurface;
		
		/**
		 * 	@public
		 */
		public var refCount:int;
		
		/**
		 * 	@public
		 */
		public function SharedBufferFrame(surface:DisplaySurface):void {
			this.surface	= surface;
		}
		
		/**
		 * 	@public
		 */
		public function dispose(context:IDisplayContextCPU):void {
			
			if (--refCount === 0) {
				context.releaseSurface(surface);
				surface = null;
			}
		}
	}
}