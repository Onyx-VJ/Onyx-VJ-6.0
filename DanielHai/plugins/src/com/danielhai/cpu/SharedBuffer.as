package com.danielhai.cpu {
	
	import flash.events.*;
	
	import onyx.core.*;
	import onyx.display.*;
	import onyx.event.*;

	public final class SharedBuffer extends EventDispatcher {
		
		/**
		 * 	@private
		 */
		private static const SHARES:Object	= {};
		
		/**
		 * 	@internal
		 */
		internal var channel:IChannelCPU;
		
		/**
		 * 	@private
		 */
		private const callbacks:Vector.<Function>	= new Vector.<Function>();
		
		/**
		 * 	@private
		 */
		private var context:IDisplayContextCPU;
		
		/**
		 * 	@private
		 */
		private var currentRequest:SharedBufferFrame;
		
		/**
		 * 	@public
		 */
		public function SharedBuffer(context:IDisplayContextCPU, channel:IChannelCPU):void {
			this.context	= context;
			this.channel 	= channel;
		}
		
		/**
		 * 	@public
		 */
		public function requestFrame():SharedBufferFrame {
			
			if (!currentRequest) {
				
				var surface:DisplaySurface = context.requestSurface(false);
				surface.copyPixels(channel.surface, CONST_RECT, CONST_IDENTITY);
				
				currentRequest = new SharedBufferFrame(surface);
			}
			++currentRequest.refCount;
			
			return currentRequest;
		}
		
		/**
		 * 	@public
		 */
		public function attach(callback:Function):void {
			
			CONFIG::DEBUG {
				if (callbacks.indexOf(callback) !== -1) {
					throw new Error('Already in!');
				}
			}
			
			callbacks.push(callback);

			channel.addEventListener(OnyxEvent.CHANNEL_RENDER_CPU, handleRender);
		}
		
		/**
		 * 	@private
		 */
		private function handleRender(e:OnyxEvent):void {
			
			var channel:IChannelCPU	= e.target as IChannelCPU;
			currentRequest			= null;
			if (channel) {
				for each (var callback:Function in callbacks) {
					callback();
				}
			}
		}
		
		/**
		 * 	@public
		 */
		public function release(callback:Function):Boolean {
			
			callbacks.splice(callbacks.indexOf(callback), 1);
			
			// zero?
			if (callbacks.length === 0) {
				channel.removeEventListener(OnyxEvent.CHANNEL_RENDER_CPU, handleRender);
				return true;
			}
			
			// false!
			return false;
		}
	}
}