// http://wonderfl.net/c/4VE6

package onyx.patch.gpu {
	
	import com.adobe.utils.*;
	
	import flash.display.*;
	import flash.display3D.*;
	import flash.display3D.textures.*;
	import flash.geom.*;
	import flash.utils.*;
	
	import onyx.core.*;
	import onyx.display.*;
	import onyx.event.*;
	import onyx.plugin.*;
	
	use namespace parameter;
	
	[Parameter(id='reset', type='function')]
	
	final public class GPUTex extends PluginPatchGPU {
		
		private var tx:DisplayTexture;
		
		/**
		 * 	@public
		 */
		override public function initialize(context:IDisplayContextGPU, channel:IChannelGPU, file:IFileReference, content:Object):PluginStatus {
			
			var status:PluginStatus = super.initialize(context, channel, file, content);
			if (status !== PluginStatus.OK) {
				return status;
			}
			
			context.addEventListener(OnyxEvent.GPU_CONTEXT_CREATE, handleContext);
			tx = context.requestTexture(context.width, context.height, false);
			if (context.isValid()) {
				handleContext();
			}
			
			return PluginStatus.OK;
		}
		
		private function handleContext(e:OnyxEvent = null):void {
			tx.upload(new GPUTexAsset().bitmapData);
		}
		
		/**
		 * 	@public
		 * 	Update every frame
		 */
		override public function update(time:Number):Boolean {
			return invalid;
		}
		
		/**
		 * 	@public
		 */
		override public function render(context:IDisplayContextGPU):Boolean {
			
			context.clear(Color.CLEAR);
			context.blit(tx);
			
			return true;
		}
		
		/**
		 * 	@public
		 */
		override public function dispose():void {
			
			// return
			context.removeEventListener(OnyxEvent.GPU_CONTEXT_CREATE, handleContext);
			context.releaseTexture(tx);
			
			// dispose
			super.dispose();
			
		}
	}
}