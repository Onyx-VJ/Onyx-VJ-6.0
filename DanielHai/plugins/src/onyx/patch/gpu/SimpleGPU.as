package onyx.patch.gpu {
	
	import com.adobe.utils.*;
	
	import flash.display.*;
	import flash.display3D.*;
	import flash.display3D.textures.*;
	import flash.geom.*;
	import flash.utils.*;
	
	import onyx.core.*;
	import onyx.display.*;
	import onyx.event.OnyxEvent;
	import onyx.plugin.*;
	
	final public class SimpleGPU extends PluginPatchGPU {
		
		/**
		 * 	@private
		 */
		private var texture:DisplayTexture;
		
		/**
		 * 	@private
		 */
		private var buffer:IndexBuffer3D;
		
		/**
		 * 	@public
		 */
		override public function initialize(context:IDisplayContextGPU, channel:IChannelGPU, file:IFileReference, content:Object):PluginStatus {

			// success
			var status:PluginStatus = super.initialize(context, channel, file, context);
			
			texture					= context.requestTexture(16, 16, false);
			context.addEventListener(OnyxEvent.GPU_CONTEXT_CREATE, handleContext);
			if (context.isValid()) {
				handleContext();
			}
			
			return status;
		}
		
		/**
		 * 	@private
		 */
		private function handleContext(e:* = null):void {
			
			texture.upload(new SimpleGPUAsset().bitmapData);

		}
		
		/**
		 * 	@public
		 * 	Update every frame
		 */
		override public function update(time:Number):Boolean {
			return true;
		}
		
		/**
		 * 	@public
		 */
		override public function render(context:IDisplayContextGPU):Boolean {
			
			context.clear(Color.BLACK);
			
			// update our index buffer

			return true;
		}
		
		/**
		 * 	@public
		 */
		override public function dispose():void {
			
			// dispose
			super.dispose();

		}
	}
}