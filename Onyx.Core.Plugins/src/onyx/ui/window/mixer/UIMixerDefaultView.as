package onyx.ui.window.mixer {
	
	import flash.events.*;
	
	import onyx.core.*;
	import onyx.service.*;
	import onyx.ui.component.*;
	import onyx.ui.core.*;
	import onyx.ui.dialog.*;
	import onyx.ui.factory.*;
	import onyx.ui.file.OnyxMix;
	
	use namespace skinPart;
	
	[UIConstraint(type='relative', top='22', left='4', right='4', bottom='4')]
	
	[UISkinPart(id='saveMixButton',			type='button', 			constraint='relative', left='0', top='0', width='100', height='16', label='Save Mix')]
	[UISkinPart(id='saveThumbnail', 		type='button',			constraint='relative', left='0', top='18', width='100', height='16', label='Snapshot')]
	[UISkinPart(id='startRecordButton',		type='button', 			constraint='relative', left='0', top='36', width='100', height='16', label='Record Start')]
	[UISkinPart(id='endRecordButton',		type='button',	 		constraint='relative', left='0', top='54', width='100', height='16', label='Record End')]
	//[UISkinPart(id='debugMixButton',		type='button',			constraint='relative', left='0', top='90', 	width='100', height='16', label='Debug Mix')]

	final public class UIMixerDefaultView extends UIObject {
		
		/**
		 * 	@private
		 */
		skinPart var saveMixButton:UIButton;
		
		/**
		 * 	@private
		 */
		CONFIG::DEBUG
		skinPart var debugMixButton:UIButton;
		
		/**
		 * 	@private
		 */
		skinPart var saveThumbnail:UIButton;
		
		/**
		 * 	@private
		 */
		skinPart var endRecordButton:UIButton;
		
		/**
		 * 	@private
		 */
		skinPart var startRecordButton:UIButton;
		
		/**
		 * 	@public
		 */
		override public function initialize(data:Object):void {
			
			// init
			super.initialize(data);
			
			// save
			saveMixButton.addEventListener(MouseEvent.CLICK, handleClick);
			saveThumbnail.addEventListener(MouseEvent.CLICK, handleClick);
			endRecordButton.addEventListener(MouseEvent.CLICK, handleClick);
			startRecordButton.addEventListener(MouseEvent.CLICK, handleClick);
			
//			CONFIG::DEBUG {
//				debugMixButton.addEventListener(MouseEvent.CLICK, handleClick);
//			}
			
		}
		
		/**
		 * 	@private
		 */
		private function handleClick(e:Event):void {
			
//			CONFIG::DEBUG {
//				if (e.currentTarget === debugMixButton) {
//					
//					mix = new OnyxMix();
//					mix.save();
//					
//					return Debug.object(mix.data);					
//				}
//			}
			
			switch (e.currentTarget) {
				case startRecordButton:
				case endRecordButton:
					
					var record:IRecordService = Onyx.GetModule('Onyx.Service.RecordingService') as IRecordService;
					if (e.currentTarget === startRecordButton) {
						record.record(true);
						Console.Log(CONSOLE::MESSAGE, 'Recording');
					} else {
						record.record(false);
						Console.Log(CONSOLE::MESSAGE, 'Encoding');
					}	
					
					break;
				case saveMixButton:
					
					var mix:OnyxMix = new OnyxMix();
					mix.save();
					
					if (mix.data) {
						var dialog:SaveMixDialog = application.createModalDialog(new UIFactory(SaveMixDialog), 200, 200) as SaveMixDialog;
						dialog.data				 = mix;
					}
					
					break;
				case saveThumbnail:
					
					var service:IThumbnailService	= Onyx.GetModule('Onyx.Service.ThumbnailService') as IThumbnailService;
					var display:IDisplay			= Onyx.GetDisplay(0);
					var file:IFileReference			= FileSystem.GetFileReference('/onyx/' + String(new Date().time) + '.ext');
					service.saveThumbnail('screen-capture', file, display.drawThumbnail(display.width,display.height));
					
					break;
			}
		}
		
		/**
		 * 	@private
		 */
		private function handleClose(e:Event):void {
			
		}
		
		override public function arrange(rect:UIRect):void {
			super.arrange(rect);
			super.arrangeSkins(rect.identity());
		}
		
		/**
		 * 	@public
		 */
		override public function dispose():void {
			
			saveMixButton.removeEventListener(MouseEvent.CLICK, handleClick);
			saveThumbnail.removeEventListener(MouseEvent.CLICK, handleClick);
			endRecordButton.removeEventListener(MouseEvent.CLICK, handleClick);
			startRecordButton.removeEventListener(MouseEvent.CLICK, handleClick);
			
//			CONFIG::DEBUG {
//				debugMixButton.removeEventListener(MouseEvent.CLICK, handleClick);
//			}
			
			super.dispose();
			
		}
	}
}