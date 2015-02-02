package onyxui.window {
	
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.text.*;
	import flash.utils.*;
	
	import onyx.core.*;
	import onyx.host.*;
	import onyx.parameter.*;
	import onyx.util.*;
	import onyx.util.encoding.*;
	
	import onyxui.assets.*;
	import onyxui.core.*;
	import onyxui.parameter.*;
	import onyxui.window.mixer.*;

	public final class WindowMixer extends UIWindow {
		
		/**
		 * 	@private
		 */
		private const button:UIButton	= new UIButton('Save Mix File',		UIStyle.FORMAT_CENTER);
		
		/**
		 * 	@private
		 */
		private const bind:UIButton		= new UIButton('Bind Key/Midi',		UIStyle.FORMAT_CENTER);

		/**
		 * 	@private
		 */
		private const gc:UIButton		= new UIButton('GC LOG',			UIStyle.FORMAT_CENTER);
		
		/**
		 * 	@private
		 */
		private var state:BindingState;
		
		/**
		 * 	@private
		 */
		private const panel:BindingPanel	= new BindingPanel();

		/**
		 * 	@private
		 */
		override public function initialize():void {
			
			setDraggable(true);
			
			button.resize(80, 16);
			button.moveTo(4, 26);
			button.addEventListener(MouseEvent.CLICK,	handleClick);
			addChild(button);
			
			bind.resize(80, 16);
			bind.moveTo(4, 48);
			bind.addEventListener(MouseEvent.CLICK,		handleClick);
			addChild(bind);
			
			gc.resize(80, 16);
			gc.moveTo(4, 70);
			gc.addEventListener(MouseEvent.CLICK,		handleClick);
			addChild(gc);
			
			// panel
			panel.moveTo(4, 90);
			addChild(panel);
			
			// init
			super.initialize();

		}
		
		/**
		 * 	@private
		 */
		private function handleClick(event:Event):void {
			
			event.stopPropagation();
			switch (event.currentTarget) {
				
				// save mix
				case button:
					
					const str:String = Serialize.toJSON(Onyx.GetDisplay(0).serialize());
					trace(str);
					// TODO
					// FileSystem.Browse(FileSystem.Root, new Callback(saveMix, [str]));
					
					break;
				
				// bind control to midi
				case bind:
					
					// attach nothing
					panel.attach(null);
					panel.listen();
					
					break;
				
				case gc:
					CONFIG::DEBUG {
					
						GC.log();
					}
					break;
			}
		}
		
		/**
		 * 	@private
		 */
		private function saveMix(data:String, ref:IFileReference):void {
			
			if (!ref) {
				return;
			}
			if (!ref.extension || ref.isDirectory) {
				ref = FileSystem.GetFileReference(ref.path + '.onx');
			}
			
			const bytes:ByteArray	= new ByteArray();
			bytes.writeUTFBytes(data);
			
			// write
			FileSystem.Write(ref, bytes, new Callback(function(e:Error = null):void {
				if (e) {
					Console.Log(CONSOLE::ERROR, 'Mix failed to save: ' + e.message);
				} else {
					Console.Log(CONSOLE::MESSAGE, 'Mix saved');
				}
			}));

		}
		
		/**
		 * 	@public
		 */
		override public function dispose():void {
			
			// remove
			button.removeEventListener(MouseEvent.CLICK, handleClick);
			gc.removeEventListener(MouseEvent.CLICK, handleClick);
			bind.removeEventListener(MouseEvent.CLICK, handleClick);
			
			// dispose
			super.dispose();
		}
	}
}   