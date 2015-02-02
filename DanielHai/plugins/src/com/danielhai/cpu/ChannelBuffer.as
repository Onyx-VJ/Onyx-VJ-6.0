package com.danielhai.cpu {
	
	import flash.events.*;
	import flash.utils.*;
	
	import onyx.core.*;
	import onyx.display.*;
	import onyx.event.*;
	
	final public class ChannelBuffer {

		/**
		 * 	@private
		 */
		private static const SHARES:Dictionary	= new Dictionary();
		
		/**
		 * 	@private
		 */
		private var buffer:SharedBuffer;
		
		/**
		 * 	@private
		 */
		private var channel:IChannelCPU;
		
		/**
		 * 	@private
		 */
		private var context:IDisplayContextCPU;
		
		/**
		 * 	@public
		 */
		public var type:uint;
		
		/**
		 * 	@public
		 */
		public function initialize(context:IDisplayContextCPU):void {
			this.context	= context;
		}
		
		/**
		 * 	@public
		 */
		public function releaseFrames(frames:Array):void {
			for each (var frame:SharedBufferFrame in frames) {
				frame.dispose(context);
			}
		}
		
		/**
		 * 	@public
		 */
		public function attach(channel:IChannelCPU, callback:Function):void {
			
			// release
			if (buffer) {
				
				// done?
				if (buffer.release(callback)) {
					delete SHARES[channel];
				}
				
				buffer = null;
			}
			
			// store the channel we're listening to
			this.channel = channel;
			
			// input channel
			if (channel) {
				
				// test to see if anything is recording
				buffer		= SHARES[channel];
				if (!buffer) {
					SHARES[channel] = buffer	= new SharedBuffer(context, channel);
				}
				
				// attach
				buffer.attach(callback);
			}
		}
		
		/**
		 * 	@public
		 */
		public function requestFrame():SharedBufferFrame {
			return buffer.requestFrame();
		}
	}
}