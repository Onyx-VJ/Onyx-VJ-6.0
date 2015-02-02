package onyx.ui.window.layer {
	
	import flash.display.*;
	import flash.events.Event;
	import flash.geom.*;
	import flash.text.*;
	
	import onyx.core.*;
	import onyx.display.*;
	import onyx.event.OnyxEvent;
	import onyx.ui.core.*;
	
	[UIComponent(id='layerPreview')]
	
	final public class UILayerPreview extends UIObject  {
		
		/**
		 * 	@private
		 */
		private const bitmap:Bitmap		= addChild(new Bitmap()) as Bitmap;
		
		/**
		 * 	@private
		 */
		private var bounds:UIRect;
		
		/**
		 * 	@private
		 */
		private var channel:IChannelCPU;
		
		/**
		 * 	@public
		 */
		public function attach(channel:IChannelCPU):void {
			
			removeListeners();
			
			this.channel	= channel;
			if (channel) {
				channel.addEventListener(OnyxEvent.CHANNEL_RENDER_CPU, handleRender);
			} else {
				bitmap.bitmapData = null;
			}
		}
		
		/**
		 * 	@private
		 */
		private function removeListeners():void {
			if (channel) {
				channel.removeEventListener(OnyxEvent.CHANNEL_RENDER_CPU, handleRender);
				channel = null;
			}
		}
		
		/**
		 * 	@private
		 */
		private function handleRender(e:*):void {
			
			if (!bounds) {
				return;
			}
			
			bitmap.bitmapData	= channel.surface;
			bitmap.width		= bounds.width;
			bitmap.height		= bounds.height;
		}
		
		/**
		 *	@public 
		 */
		override public function arrange(rect:UIRect):void {
			
			if (!rect) {
				return;
			}
			
			super.arrange(bounds = rect);
			
			if (bitmap.bitmapData) {
				bitmap.width		= bounds.width;
				bitmap.height		= bounds.height;
			}
		}
		
		override public function dispose():void {
			
			removeListeners();
			
			super.dispose();
		}
	}
}