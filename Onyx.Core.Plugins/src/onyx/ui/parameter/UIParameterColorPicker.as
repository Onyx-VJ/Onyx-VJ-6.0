package onyx.ui.parameter {

	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	
	import onyx.core.*;
	import onyx.display.*;
	import onyx.event.*;
	import onyx.parameter.*;
	import onyx.ui.component.*;
	import onyx.ui.core.*;
	import onyx.ui.factory.UIFactory;
	
	use namespace skinPart;
	
	[UISkinPart(id='skin',	type='buttonSkin',	transform='theme::default',	constraint='relative', left='0', right='0', top='0', bottom='0', skinClass='DropDownBackground')]
	
	public final class UIParameterColorPicker extends UIParameterDisplayBase {
		
		/**
		 * 	@private
		 */
		private static const SELECTION_FACTORY:UIFactory	= new UIFactory(UIParameterColorPickerPalette);

		/**
		 * 	@private
		 */
		private var shape:Shape								= new Shape();
		
		/**
		 * 	@private
		 */
		skinPart var skin:UIButtonSkin;
		
		/**
		 * 	@private
		 */
		private var selection:UIParameterColorPickerPalette;
		
		/**
		 * 	@private
		 */
		override public function initialize(data:Object):void {
			
			super.initialize(data);
			
			const g:Graphics	= shape.graphics;
			g.clear();
			g.beginFill(0x00);
			g.drawRect(0,0,100,100);
			g.endFill();
			
			shape.x = 1;
			shape.y = 1;
			addChild(shape);
			
			// add listener
			addEventListener(MouseEvent.MOUSE_DOWN, handleMouse);

		}
		
		/**
		 * 	@private
		 */
		private function handleMouse(event:MouseEvent):void {
			switch (event.type) {
				case MouseEvent.MOUSE_DOWN:
					
					application.addChild(selection = SELECTION_FACTORY.createInstance());
					var rect:Rectangle	= getRect(AppStage);
					selection.arrange(new UIRect(rect.x - 137, rect.y - 130, 275, 260));
					
					stage.addEventListener(MouseEvent.MOUSE_MOVE,	handleMouse);
					stage.addEventListener(MouseEvent.MOUSE_UP,		handleMouse);
					
					break;
				case MouseEvent.MOUSE_UP:
					
					if (application.contains(selection)) {
						application.removeChild(selection);
						selection = null;
					}
					
					stage.removeEventListener(MouseEvent.MOUSE_MOVE,	handleMouse);
					stage.removeEventListener(MouseEvent.MOUSE_UP,		handleMouse);
					
					break;
				case MouseEvent.MOUSE_MOVE:
					
					parameter.value		= selection.color;
					
					break;
			}
		}
		
		/**
		 * 	@public
		 */
		override public function update():void {
			
			var color:*							= parameter.value;
			var colorTransform:ColorTransform	= shape.transform.colorTransform;
			
			if (color is Color) {
				colorTransform.redOffset 		= color.r * 255;
				colorTransform.greenOffset 		= color.g * 255;
				colorTransform.blueOffset 		= color.b * 255;
			} else {
				var u:uint = color as uint || uint(color); 
				colorTransform.redOffset 		= (u & 0xFF0000) >> 16;
				colorTransform.greenOffset 		= (u & 0x00FF00) >> 8;
				colorTransform.blueOffset 		= (u & 0x0000FF);
			}

			shape.transform.colorTransform	= colorTransform;

		}
		
		override public function arrange(rect:UIRect):void {
			
			super.arrange(rect);
			
			rect = rect.identity();
			skin.measure(rect);
			
			// transform
			shape.width		= rect.width - 2;
			shape.height	= rect.height - 2;
			
		}
		
		/**
		 * 	@public
		 */
		override public function dispose():void {
			
			removeEventListener(MouseEvent.MOUSE_DOWN,			handleMouse);
			stage.removeEventListener(MouseEvent.MOUSE_MOVE,	handleMouse);
			stage.removeEventListener(MouseEvent.MOUSE_UP,		handleMouse);
			
			// dispose
			super.dispose();
			
		}
	}
	
}