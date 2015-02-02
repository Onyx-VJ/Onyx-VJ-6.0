package onyx.ui.file {
	
	import flash.display.*;
	
	import onyx.core.*;
	import onyx.util.Callback;
	import onyx.util.encoding.*;
	
	public final class OnyxMix {
		
		/**
		 * 	@private
		 */
		public var thumbnail:BitmapData;
		
		/**
		 * 	@private
		 */
		public var data:Object;
		
		/**
		 * 	@public
		 * 
		 * 
		 * 	4 bytes:	JSON LENGTH
		 * 	....... JSON
		 *	2 bytes:	thumb width
		 * 	2 bytes:	thumb height
		 * 	4 bytes:	thumb size
		 * 	........ BITMAPDATA compressed
		 */
		public function save():Boolean {
			
			const displays:Vector.<IDisplay>	= Onyx.GetDisplays();
			const token:Array					= [];
			var thumbDisplay:IDisplay;
			
			for each (var display:IDisplay in displays) {
				var data:Object		= display.serialize();
				var layers:Array	= [];
				for each (var layer:IDisplayLayer in display.getLayers()) {
					if (layer.getGenerator()) {
						layers.push(layer.serialize());
					}
				}
				
				if (layers.length) {
					data.layers = layers;
					token.push(data);
					
					if (!thumbDisplay) {
						thumbDisplay = display;
					}
				}
			}
			
			if (token.length) {
				this.data	= data;
				this.thumbnail	= thumbDisplay.drawThumbnail(112, 63);
				return true;
			}
			
			thumbnail = null;
			
			return false;
		}
		
		/**
		 * 	@public
		 */
		public function load(data:Object, origin:IDisplayLayer):void {
			
			const queue:Array		= [];
			var index:int			= origin.index;
			const display:IDisplay	= origin.parent;
			for each (var token:Object in data.layers) {
				if (!token.generator || !token.generator.path) {
					break;
				}
				
				var layer:IDisplayLayer = display.getLayer(index++);
				if (!layer) {
					break;
				}
				
				queue.push(new LoadHandle(layer, FileSystem.GetFileReference(token.generator.path), token));
			}
			
			if (queue.length) {
				new LoadQueue(queue);
			}
		}
	}
}

import onyx.core.*;
import onyx.util.Callback;

final class LoadQueue {
	
	public var handles:Vector.<LoadHandle>
	public var queue:Array;
	private var current:LoadHandle;
	
	/**
	 * 	@public
	 */
	public function LoadQueue(queue:Array):void {
		
		this.handles	= Vector.<LoadHandle>(queue);
		this.queue		= queue;
		
		loadNext();
	}
	
	/**
	 * 	@private
	 */
	private function loadNext():void {
		
		current = queue.shift();
		if (current) {
			
			FileSystem.Load(current.file, new Callback(handleLoad));
			
		} else {
			
			for each (var handle:LoadHandle in handles) {
				handle.layer.setGenerator(handle.generator, handle.file, handle.content);
				handle.layer.unserialize(handle.token);
			}
		}
	}
	
	/**
	 * 	@private
	 */
	private function handleLoad(file:IFileReference, content:Object, generator:IPluginGenerator):void {
		
		current.content		= content;
		current.generator	= generator;
		
		loadNext();
	}
}

final class LoadHandle {
	
	/**
	 * 	@private
	 */
	public var layer:IDisplayLayer;
	public var file:IFileReference;
	public var token:Object;
	public var content:Object;
	public var generator:IPluginGenerator;
	
	/**
	 * 	@public
	 */
	public function LoadHandle(layer:IDisplayLayer, file:IFileReference, token:Object):void {
		this.layer	= layer;
		this.file	= file;
		this.token	= token;
	}
	
}