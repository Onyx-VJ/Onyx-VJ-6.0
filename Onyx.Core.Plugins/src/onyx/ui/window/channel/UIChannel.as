package onyx.ui.window.channel {
	
	import flash.utils.Dictionary;
	
	import onyx.core.*;
	import onyx.event.*;
	import onyx.ui.component.*;
	import onyx.ui.core.*;
	import onyx.ui.event.*;
	import onyx.ui.factory.*;
	import onyx.ui.file.OnyxMix;
	import onyx.ui.interaction.*;
	import onyx.ui.parameter.*;
	import onyx.ui.window.layer.*;
	import onyx.util.Callback;
	import onyx.util.encoding.Serialize;

	use namespace skinPart
	
	public class UIChannel extends UIObject {
		
		/**
		 * 	@private
		 */
		protected static const FACTORY_FILTER:UIFactory			= new UIFactory(UIFilterSelection);
		
		/**
		 * 	@private
		 */
		protected static const FACTORY_BASE:UIFactory			= new UIFactory(UISelection);
		
		/**
		 * 	@private
		 */
		skinPart var background:UISkin;
		
		/**
		 * 	@private
		 */
		skinPart var parameterList:UIParameterList;
		
		/**
		 * 	@private
		 */
		skinPart var filterList:UIFilterList;
		
		/**
		 * 	@private
		 */
		skinPart var preview:UILayerPreview;
		
		/**
		 * 	@protected
		 */
		protected var owner:IDisplayChannel;
		
		/**
		 * 	@protected
		 */
		private const channelHash:Dictionary	= new Dictionary(true);	
		
		/**
		 * 	@protected
		 */
		public function attach(owner:IDisplayChannel):void {
			
			this.owner = owner;
			
			owner.addEventListener(OnyxEvent.CHANNEL_CREATE,	handleChannel);
			owner.addEventListener(OnyxEvent.CHANNEL_DESTROY,	handleChannel);
			
			addEventListener(DragEvent.DRAG_OVER,				handleDrag);
			addEventListener(DragEvent.DRAG_OUT,				handleDrag);
			addEventListener(DragEvent.DRAG_DROP,				handleDrag);
			
		}
		
		/**
		 * 	@private
		 */
		protected function handleDrag(e:DragEvent):void {
			switch (e.type) {
				case DragEvent.DRAG_DROP:
					
					background.transform.colorTransform = UIStyleManager.TRANSFORM_DEFAULT;
					
					switch (e.dragType) {
						case DragManager.GENERATOR:
							
							// ok, is it a mix file? -- if so do other stuff
							var file:IFileReference = e.dropData as IFileReference;
							if (!file) {
								return Console.LogError('ERROR!');
							}
							
							if (file.extension === 'mix') {
								
								FileSystem.ReadFile(file, new Callback(handleMix));
								
							} else {
								(owner as IDisplayLayer).load(file, {});
							}
							
							break;
						case DragManager.FILTER_GPU:
						case DragManager.FILTER_CPU:
							
							(e.data as IChannel).addFilter((e.dropData as IPluginDefinition).createInstance() as IPluginFilter);
							break;
					}
					
					break;
				case DragEvent.DRAG_OVER:
					background.transform.colorTransform = UIStyleManager.TRANSFORM_HIGHLIGHT;
					break;
				case DragEvent.DRAG_OUT:
					background.transform.colorTransform = UIStyleManager.TRANSFORM_DEFAULT;
					break;
			}
		}
		
		/**
		 * 	@private
		 */
		private function handleMix(data:String, file:IFileReference):void {
			
			// offset them a little bit?
			
			var layer:IDisplayLayer	= owner as IDisplayLayer;
			if (!layer) {
				return;
			}
			
			var mix:OnyxMix						= new OnyxMix();
			mix.load(Serialize.fromJSON(data), layer);
			// var layers:Vector.<IDisplayLayer>	= layer.parent.getLayers();
			// var count:int = 0;
//			for each (var token:Object in json.layers) {
//				
//				if (layers.length - 1 < index + count) {
//					break;
//				}
//				
//				//layers[index + count].unserialize(token);
//				
//				count++;
//			}
		}
		
		/**
		 * 	@private
		 */
		private function handleChannel(e:OnyxEvent):void {
			
			var channel:IChannel	= e.data as IChannel;
			CONFIG::DEBUG {
				if (!channel) {
					return;
				}
			}
			
			switch (e.type) {
				case OnyxEvent.CHANNEL_CREATE:
					
					// test channels - pass the channel we should drop on
					if (e.data is IChannelCPU) {
						
						DragManager.registerTarget(this, DragManager.FILTER_CPU, channel);
						preview.attach(e.data as IChannelCPU);
					
					} else if (e.data is IChannelGPU) {
						DragManager.registerTarget(this, DragManager.FILTER_GPU, channel);
					}
					
					// we need to listen to stuff
					channel.addEventListener(OnyxEvent.FILTER_CREATE,		handleFilterCPU);
					channel.addEventListener(OnyxEvent.FILTER_DESTROY,		handleFilterCPU);
					channel.addEventListener(OnyxEvent.FILTER_MOVE,			handleFilterCPU);
					
					break;
				case OnyxEvent.CHANNEL_DESTROY:
					
					if (e.data is IChannelCPU) {
						DragManager.unregisterTarget(this, DragManager.FILTER_CPU);
						preview.attach(null);
					} else if (e.data is IChannelGPU) {
						DragManager.unregisterTarget(this, DragManager.FILTER_GPU);
					}
					
					// we need to listen to stuff
					channel.removeEventListener(OnyxEvent.FILTER_CREATE,	handleFilterCPU);
					channel.removeEventListener(OnyxEvent.FILTER_DESTROY,	handleFilterCPU);
					channel.removeEventListener(OnyxEvent.FILTER_MOVE,		handleFilterCPU);
					
					break;
			}
		}
		
		/**
		 * 	@private
		 */
		private function handleFilterCPU(e:OnyxEvent):void {
			
			var item:UIFilterListItem,
				channel:IChannel		= e.currentTarget as IChannel;
			
			switch (e.type) {
				case OnyxEvent.FILTER_CREATE:

					// add
					item = filterList.add(FACTORY_FILTER, e.data, channel.getFilterIndex(e.data as IPluginFilter));
					item.addEventListener(SelectionEvent.REMOVE, handleRemove);
					channelHash[e.data];

					break;
				case OnyxEvent.FILTER_MOVE:
					
					filterList.updateIndex(e.data, channel.getFilterIndex(e.data as IPluginFilter));
					
					break;
				case OnyxEvent.FILTER_DESTROY:
					
					item = filterList.remove(e.data);
					item.removeEventListener(SelectionEvent.REMOVE, handleRemove);
					
					break;
			}
			
		}
		
		/**
		 * 	@private
		 */
		private function handleRemove(e:SelectionEvent):void {
			var filter:IPluginFilter = e.data as IPluginFilter;
			if (filterList.selected === e.currentTarget) {
				parameterList.attach(null);
				filterList.setSelected(null);
			}
			
			filter.getOwner().removeFilter(filter);
		}
		
		/**
		 * 	@public
		 */
		override public function dispose():void {
			
			owner.removeEventListener(OnyxEvent.FILTER_CREATE,	handleChannel);
			owner.removeEventListener(OnyxEvent.FILTER_DESTROY,	handleChannel);
			owner.removeEventListener(OnyxEvent.FILTER_MOVE,	handleChannel);
			
			super.dispose();
		}
	}
}