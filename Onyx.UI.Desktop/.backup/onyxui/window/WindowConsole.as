package onyxui.window {
	
	import flash.display.*;
	import flash.text.*;
	
	import onyx.core.*;
	
	import onyxui.assets.*;
	import onyxui.core.*;

	public final class WindowConsole extends UIWindow {

		/**
		 * 	@private
		 */
		private var text:TextField;
		
		/**
		 * 	@private
		 */
		private var command:TextField;
		
		/**
		 * 	@private
		 */
		private const colors:Vector.<TextFormat>	= new Vector.<TextFormat>();

		/**
		 * 	@private
		 */
		override public function initialize():void {
			
			// set draggable
			setDraggable(true);
			
			// init
			super.initialize();

			// get text
			text					= getChild('text',		'label');
			command					= getChild('command',	'label');
			command.type			= TextFieldType.INPUT;
			command.backgroundColor	= 0x333333;
			command.background		= true;
			command.textColor		= 0xFFFFFF;
			command.text			= 'Enter Command Here';
			command.selectable		= true;
			command.mouseEnabled	= true;
			
			colors[CONSOLE::DEBUG]	= UIStyle.createDefaultTextFormat(UIStyle.PIXEL, 0x999999);
			colors[CONSOLE::INFO]	= UIStyle.createDefaultTextFormat(UIStyle.PIXEL, 0x999999);
			colors[CONSOLE::MESSAGE]	= UIStyle.createDefaultTextFormat(UIStyle.PIXEL, 0xdff1f1);
			colors[CONSOLE::WARNING] = UIStyle.createDefaultTextFormat(UIStyle.PIXEL, 0xFFCC00);
			colors[CONSOLE::ERROR]	= UIStyle.createDefaultTextFormat(UIStyle.PIXEL, 0xFF0000);

			// register
			Console.RegisterListener(update);
		}
		
		/**
		 * 	@private
		 */
		private function update(type:uint, str:String):void {
			
			text.defaultTextFormat	= colors[type];
			text.appendText(str);
			text.scrollV = text.maxScrollV;
			
		}
		
		/**
		 * 	@public
		 */
		override public function dispose():void {
			Console.Unregister(update);
		}
	}
}