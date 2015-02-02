package onyx.module.thumbnail {
	
	import flash.display.*;
	import flash.events.*;
	
	import onyx.core.*;
	import onyx.display.*;
	import onyx.event.*;
	import onyx.plugin.*;
	import onyx.service.*;
	import onyx.util.*;
	
	[PluginInfo(
		id				= 'Onyx.Service.ThumbnailService',
		name			= 'Onyx.Service.ThumbnailService',
		version			= '1.0',
		vendor			= 'Daniel Hai',
		description 	= 'Thumbnail Service'
	)]
	
	final public class ThumbnailService extends PluginModule implements IThumbnailService {
		
		/**
		 * 	@private
		 */
		private var root:IFileReference;
		
		/**
		 * 	@private
		 */
		private const size:Dimensions				= new Dimensions(112,63);
		
		/**
		 * 	@private
		 */
		private var context:DisplayContextCPU		= new DisplayContextCPU();
		private var channel:ChannelCPU				= new ChannelCPU();
		
		/**
		 * 	@public
		 * 	Initializes the modules
		 */
		public function initialize():PluginStatus {
			
			root = FileSystem.GetFileReference('/onyx/data/' + this.id);
			if (!root.exists) {
				root.createDirectory();
			}
			
			context.initialize(size.width, size.height);
			channel.initializeCPU(null, context, false, 0x00);
			
			// ok?
			return PluginStatus.OK;
		}
		
		/**
		 * 	@public
		 */
		public function readThumbnail(type:String, file:IFileReference, callback:Callback):void {
			
			// first check the cache
			var thumbnail:IFileReference = root.resolve(type + '/' + createStub(file));
			if (thumbnail.exists) {
				
				// read the file
				FileSystem.ReadFile(thumbnail, new Callback(handleThumbnailRead, [file, callback]));
				
			} else {
				
				FileSystem.Load(file, new Callback(handleFileThumb, [callback]));
				
			}
		}
		
		/**
		 * 	@private
		 */
		private function createStub(file:IFileReference):String {
			return FileSystem.CreateStub(file.path.substr(1, file.path.length - file.extension.length - 2)) + '.jpg';
		}
		
		/**
		 * 	@private
		 */
		private function handleFileThumb(callback:Callback, file:IFileReference, content:Object, input:IPlugin):void {
			
			try {
				var generator:IPluginGeneratorCPU = input as IPluginGeneratorCPU;
				if (generator) {
					
					var status:PluginStatus = generator.initialize(context, channel, file, content);
					if (status === PluginStatus.OK) {
						
						context.bindChannel(channel);
						context.clear();
						context.swapBuffer();

						generator.checkValidation();
						generator.render(context);
						generator.dispose();
						
						context.swapBuffer();
						context.unbind();
						
						var bmp:BitmapData = channel.surface.clone();
	
					} else {
						Console.LogError(status);
					}
				}
				
				// save it so it doesn't automatically load
				if (bmp) {
					saveThumbnail('library', file, bmp);
				}
				
			} catch (e:Error) {
				Console.Log(CONSOLE::ERROR, 'Error Writing thumb: ' + e.message);
			}
			
			// exec!
			callback.exec(file, bmp);
		}
		
		/**
		 * 	@private
		 */
		private function handleThumbnailRead(file:IFileReference, callback:Callback, data:Object, thumbnailPath:IFileReference):void {
			
			var info:LoaderInfo	= (data as LoaderInfo);
			if (info.content is Bitmap) { 
				callback.exec(file, (info.content as Bitmap).bitmapData);
			}
		}

		/**
		 * 	@public
		 */
		public function saveThumbnail(type:String, file:IFileReference, data:BitmapData):void {
			
			var stream:IFileStream 		= FileSystem.CreateFileStream(root.resolve(type + '/' + createStub(file)), FileSystem.WRITE);
			stream.addEventListener(OutputProgressEvent.OUTPUT_PROGRESS, handleProgress);
			stream.writeBytes(data.encode(data.rect, new JPEGEncoderOptions(95)));

		}
		
		/**
		 * 	@private
		 */
		private function handleProgress(e:OutputProgressEvent):void {

			if (e.bytesPending === 0) {
				var stream:IFileStream			= e.currentTarget as IFileStream;
				stream.removeEventListener(OutputProgressEvent.OUTPUT_PROGRESS, handleProgress);
				stream.close();
			}
		}
		
		/**
		 * 	@public
		 */
		public function start():void {}
		
		/**
		 * 	@public
		 */
		public function stop():void {
		}

	}
}