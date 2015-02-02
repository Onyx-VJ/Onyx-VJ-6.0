package onyx.ui.window {
	
	import flash.text.*;
	
	import onyx.core.*;
	import onyx.ui.component.*;
	import onyx.ui.core.*;
	
	use namespace skinPart;

	[UIComponent(id='Onyx.UI.Desktop.Console', title='CONSOLE')]
	[UISkinPart(id='consoleText', type='text')]
	
	public final class WindowConsole extends UIContainer {

		/**
		 * 	@public
		 * 	This is injected
		 */
		skinPart var consoleText:UITextField;
		
		/**
		 * 	@private
		 */
		private const colors:Vector.<TextFormat>	= new Vector.<TextFormat>();
		
		/**
		 * 	@public
		 */
		override public function initialize(data:Object):void {
			
			// do defaults
			super.initialize(data);
			
			// set
			colors[Console.VERBOSE]	= UIStyleManager.createDefaultTextFormat(0x999999);
			colors[Console.DEBUG]	= UIStyleManager.createDefaultTextFormat(0x999999);
			colors[Console.INFO]	= UIStyleManager.createDefaultTextFormat(0x999999);
			colors[Console.MESSAGE]	= UIStyleManager.createDefaultTextFormat(0xdff1f1);
			colors[Console.WARNING] = UIStyleManager.createDefaultTextFormat(0xFFCC00);
			colors[Console.ERROR]	= UIStyleManager.createDefaultTextFormat(0xFF0000);
			
			// register
			Console.RegisterListener(update);
		
		}
		
		/**
		 * 	@private
		 */
		private function update(type:uint, str:String):void {
			
			// don't print verbose
			if (type < Console.DEBUG) {
				return;
			}

			consoleText.defaultTextFormat = colors[type];
			consoleText.appendText(str);
			consoleText.scrollMax();

		}
		
		/**
		 * 	@public
		 */
		override public function dispose():void {
			Console.Unregister(update);
			super.dispose();
		}
	}
}