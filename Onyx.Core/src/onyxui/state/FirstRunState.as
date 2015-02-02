package onyxui.state {
	
	import flash.data.*;
	import flash.desktop.*;
	import flash.display.*;
	import flash.events.*;
	import flash.filesystem.*;
	import flash.net.*;
	import flash.utils.*;
	
	import onyx.core.*;
	import onyx.util.*;
	import onyx.util.encoding.*;
	
	// first run?
	public final class FirstRunState implements IState {
		
		/**
		 * 	@private
		 */
		private var config:File			 = File.applicationStorageDirectory.resolvePath('onyx-path.conf');
		
		/**
		 * 	@private
		 */
		private var ref:FileReference;
		
		/**
		 * 	@private
		 */
		private var settings:File;
		
		/**
		 * 	@private
		 */
		private var callback:Callback;
		
		/**
		 * 	@private
		 */
		private var data:Object;
		
		/**
		 * 	@public
		 */
		public function initialize(callback:Callback, data:Object):void {
			
			// store callback
			this.callback = callback;
			
			// make sure we have an id
			var bytes:ByteArray = EncryptedLocalStore.getItem('uuid');
			if (!bytes) {
				
				bytes = new ByteArray();
				bytes.writeUTFBytes(GUID.create());
				
				// set the item
				EncryptedLocalStore.setItem('uuid', bytes);
				
				// go back to zero so we can read it
				bytes.position = 0;
			}
			
			// only search if in a non-debug build
			CONFIG::RELEASE {
				
				// browse for onyx folder?
				if (!config.exists) {
					return browse();
				}
				
				// re-write the file with last updated
				var stream:FileStream	= new FileStream();
				
				// this will touch the modification date
				stream.open(config, FileMode.UPDATE);
				
				// re-write
				var str:String			= stream.readUTFBytes(stream.bytesAvailable);
				var data:Object			= Serialize.fromJSON(str);
				
				stream.position = 0;
				stream.truncate();
				stream.writeUTFBytes(Serialize.toJSON(ObjectUtil.Clone(data, { lastRun: new Date().time }), true));
				stream.close();
					
				// return the data
				callback.exec(data);

			}
			
			// always return app folder in debug build
			CONFIG::DEBUG {
			
				// return the data
				callback.exec({
					mappings: [
						{
							"mapping": "library",
							"path": new File('app:/library').nativePath
						},
						{
							"mapping": "onyx",
							"path": new File('app:/onyx').nativePath
						}
					],
					lastRun: new Date().time
				});
				
			}
			
		}
		
		/**
		 * 	@private
		 */
		private function browse():void {
			
			settings = new File('C:');
			settings.addEventListener(Event.CANCEL, handleSettings);
			settings.addEventListener(Event.SELECT, handleSettings);
			settings.browseForDirectory('Please select a directory to install Onyx-VJ');

		}
		
		/**
		 * 	@private
		 */
		private function handleSettings(event:Event):void {
			
			// remove listeners
			settings.removeEventListener(Event.CANCEL, handleSettings);
			settings.removeEventListener(Event.SELECT, handleSettings);
			
			// browse again
			if (event.type === Event.CANCEL || !settings.exists) {
				return NativeApplication.nativeApplication.exit(0);
			}

			// settings!
			if (settings.name.toLowerCase() === 'onyx-vj') {
				settings = settings.parent;
			} else {
				settings = settings.resolvePath('Onyx-VJ');
			}
			
			// first we need to create the directory
			if (!settings.exists) {

				settings.createDirectory();
				
				settings.resolvePath('library').createDirectory();
				settings.resolvePath('onyx').createDirectory();

			}
			
			flush();
		}
		
		/**
		 * 	@private
		 */
		private function flush():void {
			
			var stream:FileStream	= new FileStream();
			stream.open(config, FileMode.WRITE);
			
			var data:Object			= {
				mappings: [
					{
						mapping:	'library',
						path:		settings.resolvePath('library').nativePath.replace(/\\/g, '/')
					},
					{
						mapping:	'onyx',
						path:		settings.resolvePath('onyx').nativePath.replace(/\\/g, '/')
					}		
				],
				lastRun:	new Date().time
			};
			
			// save the file
			stream.writeUTFBytes(Serialize.toJSON(data, true));
			stream.close();
			
			// START LOGGING HERE

			// complete!
			callback.exec(data);
		}
		
		/**
		 * 	@public
		 */
		public function dispose():void {}
	}
}