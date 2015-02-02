package onyx.ui.parameter {
	
	import flash.display.*;
	import flash.events.*;
	import flash.text.*;
	
	import onyx.core.InterfaceBinding;
	import onyx.parameter.*;
	import onyx.ui.core.*;
	
	final internal class UIParameterOverlay extends Sprite implements IControlParameterProxy {
		
		/**
		 * 	@private
		 */
		private var parameter:IParameter;
		
		/**
		 * 	@private
		 */
		private var text:TextField;
		
		/**
		 * 	@public
		 */
		public function UIParameterOverlay(p:IParameter):void {
			
			parameter = p;
			
			text						= new TextField();
			text.embedFonts				= true;
			text.gridFitType			= GridFitType.PIXEL;
			text.antiAliasType			= AntiAliasType.ADVANCED;
			text.mouseEnabled			= false;
			text.selectable				= false;
			text.border					= true;
			text.borderColor			= 0x993366;
			text.defaultTextFormat		= UIStyleManager.createDefaultTextFormat();
			text.textColor				= 0xFFFFFF;
			addChild(text);
			
			addEventListener(MouseEvent.MOUSE_DOWN, handleMouse);
			addEventListener(MouseEvent.MOUSE_OVER,	handleMouse);
			addEventListener(MouseEvent.MOUSE_OUT,	handleMouse);
			
			// add
			this.name			= 'overlay';
			this.useHandCursor	= this.buttonMode	= true;
			
			update();

		}
		
		public function update():void {
			
			var i:InterfaceBinding = parameter.getBoundInterface();
			if (i && i.origin) {
				text.text				= i.origin.formatMessage(i.key);
			}
		}
		
		/**
		 * 	@public
		 */
		public function setSize(width:int, height:int):void {
			text.width	= width;
			text.height	= height;
			
			const g:Graphics = this.graphics;
			g.clear();
			g.beginFill(0x000000, 0.75);
			g.drawRect(0, 0, width, height);
			g.endFill();
		}
		
		/**
		 * 	@public
		 */
		public function getParameter():IParameter {
			return parameter;
		}
		
		/**
		 * 	@private
		 */
		private function handleMouse(event:Event):void {
			event.stopImmediatePropagation();
		}
		
		/**
		 * 	@public
		 */
		public function dispose():void {
			
			removeEventListener(MouseEvent.MOUSE_DOWN, handleMouse);
			removeEventListener(MouseEvent.MOUSE_OVER,	handleMouse);
			removeEventListener(MouseEvent.MOUSE_OUT,	handleMouse);
			
		}
	}
}