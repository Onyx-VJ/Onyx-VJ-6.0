package onyx.util {
	
	import flash.desktop.*;
	import flash.display.*;
	import flash.events.*;
	import flash.filesystem.*;
	import flash.utils.*;
	
	final public class AssetManager {
		
		/**
		 * 	@private
		 */
		public static function loadAssets(assets:Object, callback:Function):void {
			
			const queue:Array		= [];
			const handler:Function	= function(obj:Object, content:Object):void {
				
				const key:String	= obj.key;
				const file:File		= obj.file;
				
				const index:int = queue.indexOf(obj);
				if (index >= 0) {
					
					queue.splice(index, 1);
					assets[key]	= content;
					
					if (queue.length === 0) {
						callback(assets);
					}
				}
			}
			
			for (var i:String in assets) {
				var file:File = File.applicationDirectory.resolvePath(assets[i]);
				if (file.exists) {
					queue.push({ key: i, file: file});
				}
			}
			
			for each (var obj:Object in queue.concat()) {
				loadAsset(obj, handler);
			}
		}
		
		/**
		 * 	@private
		 */
		private static function loadAsset(obj:Object, callback:Function):void {
			
			const file:File			= obj.file;
			const key:String		= obj.key;
			const bytes:ByteArray	= new ByteArray();
			const stream:FileStream	= new FileStream();
			
			stream.open(file, FileMode.READ);
			stream.readBytes(bytes);
			
			switch (file.type) {
				case '.swf':
				case '.jpg':
				case '.jpeg':
				case '.png':
					
					const loader:Loader		= new Loader();
					loader.contentLoaderInfo.addEventListener(Event.COMPLETE, function(e:Event):void {
						loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, arguments.callee);
						callback(obj, loader.content);
					});
					loader.loadBytes(bytes);

					break;
				case '.onx':
					
					callback(obj, Tokenizer.tokenize(bytes.readUTFBytes(bytes.length)));
					
					break;
				default:
					
					callback(obj, bytes.readUTFBytes(bytes.length));
					
					break;
			}
		}

	}
}