package onyx.ui.dialog {

	import flash.events.*;
	import flash.filesystem.*;
	
	import onyx.core.*;
	import onyx.service.IThumbnailService;
	import onyx.ui.component.*;
	import onyx.ui.core.*;
	import onyx.ui.file.OnyxMix;
	import onyx.ui.window.*;
	import onyx.util.*;
	import onyx.util.encoding.Serialize;
	
	use namespace skinPart;
	
	[UISkinPart(id='background',	type='skin',	transform='theme::default', constraint='fill', skinClass='DialogBackground')]
	[UISkinPart(id='label',			type='text',	constraint='relative', top='4', left='4', right='4', height='16', text='Enter a file name')]
	[UISkinPart(id='fileName',		type='text',	constraint='relative', top='24', left='4', right='4', height='24', size='16', editable='true', background='0xFFFFFF', border='0x000000', color='0x000000')]
	[UISkinPart(id='saveMixButton',	type='button',	label='Save Mix',	constraint='relative', right='4', bottom='4',	width='100', height='16')]
	[UISkinPart(id='cancelButton',	type='button',	label='Cancel',		constraint='relative', left='4', bottom='4',	width='100', height='16')]

	public final class SaveMixDialog extends UIObject {

		/**
		 * 	@private
		 */
		skinPart var background:UISkin;
		
		/**
		 * 	@private
		 */
		skinPart var fileName:UITextField;
		
		/**
		 * 	@private
		 */
		skinPart var label:UITextField;
		
		/**
		 * 	@private
		 */
		skinPart var saveMixButton:UIButton;
		
		/**
		 * 	@private
		 */
		skinPart var cancelButton:UIButton;
		
		/**
		 * 	@private
		 */
		private var location:IFileReference;
		
		/**
		 * 	@public
		 */
		public var data:OnyxMix;
		
		/**
		 * 	@public
		 */
		override public function initialize(data:Object):void {
			
			// initialize
			super.initialize(data);
			
			var browser:WindowFileBrowser	= application.getWindow('Onyx.UI.Desktop.FileBrowser') as WindowFileBrowser;
			location						= browser ? browser.currentPath : FileSystem.GetFileReference('/library');
			
			var date:Date	= new Date();
			fileName.text = 'Mix ' + StringUtil.padBefore(String(date.month)) + '-' + StringUtil.padBefore(String(date.date)) + '-' + StringUtil.padBefore(String(date.hours)) + '.' + StringUtil.padBefore(String(date.minutes)) + '.' + StringUtil.padBefore(String(date.seconds));
			fileName.selectAll();
			
			saveMixButton.addEventListener(MouseEvent.CLICK, handleMix);
			cancelButton.addEventListener(MouseEvent.CLICK, handleMix);
		}
		
		/**
		 * 	@private
		 */
		private function handleMix(e:MouseEvent):void {
			
			switch (e.currentTarget) {
				case cancelButton:
					
					application.destroyModal();
					
					break;
				case saveMixButton:
					
					if (!fileName.length) {
						
						label.text = 'You must enter a file name';
						
						return;
					}
					
					// create
					var file:IFileReference	= location.resolve(fileName.text + '.mix');
					var stream:IFileStream	= FileSystem.CreateFileStream(file, FileSystem.WRITE);
					if (stream) {
						stream.addEventListener(OutputProgressEvent.OUTPUT_PROGRESS,	handleSave);
						stream.addEventListener(IOErrorEvent.IO_ERROR,					handleSave);
						stream.writeUTFBytes(Serialize.toJSON(data.data, true));
					}
					
					var service:IThumbnailService = Onyx.GetModule('Onyx.Service.ThumbnailService') as IThumbnailService;
					if (service) {
						service.saveThumbnail('library', file, data.thumbnail);
					}
					
					break;
			}
		}
		
		/**
		 * 	@private
		 */
		private function handleSave(e:Event):void {
			
			var stream:IFileStream = e.currentTarget as IFileStream;
			switch (e.type) {
				case OutputProgressEvent.OUTPUT_PROGRESS:
					
					if ((e as OutputProgressEvent).bytesPending === 0) {
						
						var browser:WindowFileBrowser	= application.getWindow('Onyx.UI.Desktop.FileBrowser') as WindowFileBrowser;
						browser.update();
						
						closeStream(stream);
						application.destroyModal();

					}
					
					break;
				case IOErrorEvent.IO_ERROR:
					
					Console.Log(CONSOLE::ERROR, 'Error writing file:', stream.file.path);
					closeStream(stream);
					application.destroyModal();
					
					break;
			}
			
			
		}
		
		private function closeStream(stream:IFileStream):void {
			
			stream.removeEventListener(OutputProgressEvent.OUTPUT_PROGRESS,	handleSave);
			stream.removeEventListener(IOErrorEvent.IO_ERROR,				handleSave);
			stream.close();
		}
		
		/**
		 * 	@public
		 */
		override public function arrange(rect:UIRect):void {
			
			super.arrange(rect);
			
			this.arrangeSkins(rect.identity());
			
		}
		
		/**
		 * 	@public
		 */
		override public function dispose():void {
			
			saveMixButton.removeEventListener(MouseEvent.CLICK, handleMix);
			cancelButton.removeEventListener(MouseEvent.CLICK,	handleMix);
			
			super.dispose()
		}
	}
}