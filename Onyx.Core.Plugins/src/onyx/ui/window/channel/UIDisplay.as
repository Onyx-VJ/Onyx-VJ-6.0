package onyx.ui.window.channel {
	
	import flash.display.*;
	import flash.events.*;
	import flash.filters.*;
	import flash.text.*;
	
	import onyx.core.*;
	import onyx.display.*;
	import onyx.event.*;
	import onyx.plugin.*;
	import onyx.ui.component.*;
	import onyx.ui.core.*;
	import onyx.ui.event.*;
	import onyx.ui.interaction.*;
	import onyx.ui.parameter.*;
	import onyx.ui.window.channel.*;
	import onyx.ui.window.layer.*;
	import onyx.util.encoding.*;
	
	use namespace skinPart;
	
	[UIComponent(id='Onyx.UI.Desktop.Displays::Display')]
	
	[UISkinPart(id='background',		type='skin', transform='theme::default', skinClass='DisplayBackground')]
	[UISkinPart(id='preview',			type='layerPreview')]
	[UISkinPart(id='cursor',			type='skin', skinClass='DisplayCursorIcon', constraint='absolute', bounds='0,0,5,5')]
	[UISkinPart(id='filterList',		type='filterList')]
	[UISkinPart(id='parameterList',		type='parameterList')]

	final public class UIDisplay extends UIChannel {
		
		/**
		 * 	@private
		 */
		private var display:IDisplay;
		
		/**
		 * 	@private
		 */
		skinPart var cursor:UISkin;
		
		/**
		 * 	@private
		 */
		skinPart var blendDrop:UIParameter;
		
		/**
		 * 	@private
		 */
		private var context:IDisplayContext;
		
		/**
		 * 	@private
		 */
		private var mouse:UIRect;
		
		/**
		 * 	@public
		 */
		override public function initialize(data:Object):void {
			
			// initialize
			super.initialize(data);
			
			// cursor?
			cursor.visible = false;
		}

		/**
		 * 	@public
		 */
		override public function attach(channel:IDisplayChannel):void {
			
			display	= channel as IDisplay;
			if (!display) {
				return;
			}
			
			// attach the display
			super.attach(display);
			
			// attach display
			filterList.addEventListener(SelectionEvent.SELECT,		handleSelection);
		
			preview.addEventListener(MouseEvent.MOUSE_DOWN,			handleMouse);
			preview.addEventListener(MouseEvent.RIGHT_CLICK,		handleMouse);
			
			context = display.getContext(Plugin.CPU);
			context.addEventListener(InteractionEvent.MOUSE_ENTER,	handleContext);
			context.addEventListener(InteractionEvent.MOUSE_LEAVE,	handleContext);
			
			// add filter
			filterList.setSelected(
				filterList.add(FACTORY_BASE, display, 0)
			);
			
		}
		
		
		private function handleContext(e:InteractionEvent):void {
			switch (e.type) {
				case InteractionEvent.MOUSE_ENTER:
					
					context.addEventListener(InteractionEvent.MOUSE_MOVE, handleContext);
					
					cursor.visible	= true;
					
					break;
				case InteractionEvent.MOUSE_MOVE:
					
					cursor.x = (e.x / context.width)	* mouse.width;
					cursor.y = (e.y / context.height)	* mouse.height;
					
					break;
				case InteractionEvent.MOUSE_LEAVE:
					
					cursor.visible	= false;
					
					break;
			}
		}
		
		private function handleMouse(e:MouseEvent):void {
			
			// e.stopPropagation();
			
			var context:IDisplayContext = display.getContext(Plugin.CPU);
			var x:Number				= (preview.mouseX / preview.width) * context.width;
			var y:Number				= (preview.mouseY / preview.height) * context.height;
			
			switch (e.type) {
				case MouseEvent.RIGHT_CLICK:
					
					context.dispatchEvent(new InteractionEvent(InteractionEvent.RIGHT_CLICK, x, y));
					
					break;
				case MouseEvent.MOUSE_DOWN:
					
					stage.addEventListener(MouseEvent.MOUSE_MOVE,	handleMouse);
					stage.addEventListener(MouseEvent.MOUSE_UP,		handleMouse);
					
					context.dispatchEvent(new InteractionEvent(InteractionEvent.MOUSE_DOWN, x, y));
					
					break;
				case MouseEvent.MOUSE_MOVE:
					
					context.dispatchEvent(new InteractionEvent(InteractionEvent.MOUSE_MOVE, x, y));
					
					break;
				case MouseEvent.MOUSE_UP:
					
					context.dispatchEvent(new InteractionEvent(InteractionEvent.MOUSE_UP, x, y));
					
					stage.removeEventListener(MouseEvent.MOUSE_MOVE,	handleMouse);
					stage.removeEventListener(MouseEvent.MOUSE_UP,		handleMouse);

					break;
			}
		}

		/**
		 * 	@private
		 */
		private function handleSelection(e:SelectionEvent):void {
			
			var target:IPlugin = e.data;
			parameterList.attach(target ? target.getParameters() : null);

		}
		
		/**
		 * 	@public
		 */
		public function getDisplay():IDisplay {
			return display;
		}
		
		/**
		 * 	@public
		 */
		override public function arrange(rect:UIRect):void {
			
			// arrange
			super.arrange(rect);
			
			// identity!
			rect = rect.identity();

			// arrange
			mouse = preview.measure(rect);
			
			// draws
			filterList.measure(rect);
			parameterList.measure(rect);

		}
		
		/**
		 * 	@public
		 */
		override public function dispose():void {
			
			
			context.removeEventListener(InteractionEvent.MOUSE_ENTER, handleContext);
			context.removeEventListener(InteractionEvent.MOUSE_LEAVE, handleContext);

			filterList.removeEventListener(SelectionEvent.SELECT, handleSelection);

			// dispose
			super.dispose();
		}
	}
}