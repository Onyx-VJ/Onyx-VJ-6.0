package onyxui.parameter {

	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	
	import onyx.core.*;
	import onyx.display.*;
	import onyx.event.*;
	import onyx.parameter.*;
	
	import onyxui.assets.*;
	import onyxui.core.*;
	
	public final class UIParameterColorPicker extends UIParameter {
		
		/**
		 * 	@private
		 */
		private static var selection:UIAssetColorPicker		= new UIAssetColorPicker();
		
		/**
		 * 	@private
		 */
		private const shape:Shape							= addChild(new Shape()) as Shape;
		
		/**
		 * 	@private
		 */
		private const colorTransform:ColorTransform			= new ColorTransform(1,1,1,1);
		
		/**
		 * 	@private
		 */
		private static const pixel:BitmapData				= new BitmapData(1, 1, false, 0); 
		
		/**
		 * 	@private
		 */
		override public function initialize():void {
			
			const g:Graphics	= shape.graphics;
			g.clear();
			g.beginFill(0x000000);
			g.drawRect(0, 0, 100,100);
			g.endFill();
			
			// add listener
			addEventListener(MouseEvent.MOUSE_DOWN, handleMouse);
		}
		
		/**
		 * 	@private
		 */
		private function handleMouse(event:MouseEvent):void {
			switch (event.type) {
				case MouseEvent.MOUSE_DOWN:
					
					var rect:Rectangle	= getRect(AppStage);
					
					selection.x			= rect.x;
					selection.y			= rect.y;
					
					AppStage.addChild(selection);
					
					AppStage.addEventListener(MouseEvent.MOUSE_MOVE,	handleMouse);
					AppStage.addEventListener(MouseEvent.MOUSE_UP,		handleMouse);
					
					break;
				case MouseEvent.MOUSE_UP:
					
					if (AppStage.contains(selection)) {
						AppStage.removeChild(selection);
					}
					
					AppStage.removeEventListener(MouseEvent.MOUSE_MOVE,	handleMouse);
					AppStage.removeEventListener(MouseEvent.MOUSE_UP,	handleMouse);
					
					break;
				case MouseEvent.MOUSE_MOVE:
					
					var matrix:Matrix	= new Matrix(1,0,0,1, -AppStage.mouseX, -AppStage.mouseY)
					pixel.draw(AppStage, matrix, null, null, pixel.rect);
					
					var value:uint		= pixel.getPixel(0,0);
					var r:Number		= ((value & 0xFF0000) >> 16) / 255;
					var g:Number		= ((value & 0x00FF00) >> 8) / 255;
					var b:Number		= ((value & 0x0000FF)) / 255;
					
					parameter.value		= new Color(r, g, b);
					break;
			}
		}
		
		/**
		 * 	@private
		 */
		override public function resize(width:int, height:int):void {
			shape.width		= width;
			shape.height	= height;
			super.resize(width, height);
		}
		
		/**
		 * 
		 */
		override public function update(e:ParameterEvent=null):void {
			
			var color:Color					= parameter.value;
			
			colorTransform.redOffset		= color.r * 255;
			colorTransform.greenOffset		= color.g * 255;
			colorTransform.blueOffset		= color.b * 255;
			
			shape.transform.colorTransform	= colorTransform;

		}
		
		/**
		 * 	@public
		 */
		override public function dispose():void {
			
			removeEventListener(MouseEvent.MOUSE_DOWN,			handleMouse);
			AppStage.removeEventListener(MouseEvent.MOUSE_MOVE,	handleMouse);
			AppStage.removeEventListener(MouseEvent.MOUSE_UP,	handleMouse);
			
			// dispose
			super.dispose();
			
		}
	}
	
}