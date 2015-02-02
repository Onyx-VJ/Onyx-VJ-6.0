package {

	import flash.desktop.NativeApplication;
	import flash.display.*;
	import flash.filesystem.*;
	
	final public class Main extends Sprite {
		
		private const sdkDir:File	= new File('D:\\Projects\\Onyx-VJ\\Onyx.Core.SDK');
		private const rootDir:File	= new File('D:\\Projects\\Onyx-VJ\\Onyx-VJ\\bin');
		private const outDir:File	= new File('D:\\Projects\\Onyx-VJ\\Onyx-VJ\\script\\http-manifest');
		
		/**
		 * 	@constructor
		 */
		public function Main():void {
			
			// query
			// query(rootDir);
			
			// get all scripts to include
			var manifest:Array = scripts(sdkDir.resolvePath('src'));
			var inc:String		= '';
			for each (var file:File in manifest) {
				inc += file.name.substr(0, -3) + ';\n';
			}
			
			const stream:FileStream	= new FileStream();
			stream.open(sdkDir.resolvePath('includes.as'), FileMode.WRITE);
			stream.writeUTFBytes(inc);
			stream.close();
			
			// exit
			NativeApplication.nativeApplication.exit();

		}
		
		/**
		 * 	@private
		 */
		private function scripts(dir:File):Array {
			const files:Array		= dir.getDirectoryListing();
			const extensions:Object	= {
				'as':	true
			}
			
			var manifest:Array	= [];
			for each (var file:File in files) {

				if (file.isDirectory) {
					manifest.push.apply(null, scripts(file));	
				} else if (file.extension === 'as') {
					manifest.push(file);
				}
			}
			
			return manifest;
		}
		
		/**
		 * 	@private
		 */
		private function query(dir:File):Boolean {
			const files:Array		= dir.getDirectoryListing();
			const extensions:Object	= {
				'onx':	true,
				'swf':	true,
				'flv':	true,
				'png':	true,
				'gif':	true,
				'jpg':	true,
				'jpeg':	true,
				'conf':	true
			}
				
			const manifest:Array	= [];
			const reg:RegExp = /\\/g;
			for each (var file:File in files) {
				
				if (file.isDirectory) {
					
					if (query(file)) {
						manifest.push({
							path: file.nativePath.replace(rootDir.nativePath, '').replace(reg, '/')
						});	
					}
					
				} else if (extensions[file.extension] !== undefined) {
					manifest.push({
						path: file.nativePath.replace(rootDir.nativePath, '').replace(reg, '/')
					});	
				}
			}

			if (manifest.length) {
				const stream:FileStream = new FileStream();
				stream.open(outDir.resolvePath(dir.nativePath.replace(rootDir.nativePath + '\\', '').replace(reg, '/') + '/manifest.json'), FileMode.WRITE);
				stream.writeUTFBytes(JSON.stringify({ files: manifest }));
				stream.close();
				return true;
			}
			return false;
		}
	}
}