package onyx.event {
	
	import flash.events.*;
	
	import onyx.core.*;

	final public class OnyxEvent extends Event {
		
		public static const DISPLAY_CREATE:String			= 'Onyx.Display.Create';
		
		public static const LAYER_CREATE:String				= 'Onyx.Layer.Create';
		public static const LAYER_UNLOAD:String				= 'Onyx.Layer.Unload';
		
		public static const LAYER_LOAD:String				= 'Onyx.Layer.Load';
		public static const LAYER_MOVE:String				= 'Onyx.Layer.Move';
		public static const LAYER_DESTROY:String			= 'Onyx.Layer.Destroy';
		
		/**
		 * 	@public
		 */
		public static const FILTER_CREATE:String			= 'Onyx.Filter.Create';

		/**
		 * 	@public
		 */
		public static const FILTER_MOVE:String				= 'Onyx.Filter.Move';
		
		/**
		 * 	@public
		 */
		public static const FILTER_DESTROY:String			= 'Onyx.Filter.Destroy';
		
		/**
		 * 	@public	Dispatched when a channel finishes a render cycle
		 */
		public static const CHANNEL_RENDER_CPU:String		= 'Onyx.Channel.Render::CPU';
		public static const CHANNEL_RENDER_GPU:String		= 'Onyx.Channel.Render::GPU';
		
		/**
		 * 	@public	Dispatched when a global channel is registered
		 */
		public static const CHANNEL_CREATE:String			= 'Onyx.Channel.Create';
		public static const CHANNEL_DESTROY:String			= 'Onyx.Channel.Destroy';
		
		public static const GPU_CONTEXT_DESTROY:String		= 'Onyx.GPU.Destroy';
		public static const GPU_CONTEXT_CREATE:String		= 'Onyx.GPU.Create';
		
		public static const INVALIDATE:String				= 'Onyx.Core.Invalidate';
		
		// public static const GENERATOR_UNLOAD:String			= 'Onyx.Generator.Unload';
		public static const GENERATOR_RESIZE:String			= 'Onyx.Generator.Resize';
		
		/**
		 * 	@public
		 */
		public static const ONYX_INITIALIZE_COMPLETE:String	= 'Onyx.Initialize.Complete';

		/**
		 * 	@public
		 */
		public var data:IPlugin;

		/**
		 * 	@constructor
		 */
		public function OnyxEvent(type:String, data:IPlugin = null, cancelable:Boolean = false):void {
			
			// store the data
			this.data	= data;
			
			// super
			super(type, false, cancelable);
		}

		/**
		 * 	@public	
		 */
		override public function clone():Event {
			return new OnyxEvent(type, data, cancelable);
		}
	}
}