package onyxui.screens {
	
	import flash.desktop.*;
	import flash.display.*;
	import flash.events.*;
	import flash.filesystem.*;
	import flash.geom.*;
	import flash.text.*;
	
	import mx.states.State;
	
	import onyx.core.*;
	import onyx.util.*;
	
	import onyxui.assets.*;
	import onyxui.state.*;

	public final class InitScreen {
		
		/**
		 * 	@private
		 */
		private static const FORMAT_DEFAULT:TextFormat				= createDefaultTextFormat(new UIAssetPixelFont().fontName, 0xffffff);
		
		/**
		 * 	@private
		 */
		private static function createTextField(format:TextFormat = null):flash.text.TextField {
			
			const label:flash.text.TextField	= new flash.text.TextField();
			label.embedFonts					= true;
			label.gridFitType					= GridFitType.PIXEL;
			label.antiAliasType					= AntiAliasType.NORMAL;
			label.defaultTextFormat				= format || FORMAT_DEFAULT;
			label.mouseEnabled					= false;
			label.height						= 16;
			label.sharpness						= 50;
			label.mouseEnabled					= false;
			
			return label;
		}
		
		/**
		 * 	@private
		 */
		private static function createDefaultTextFormat(name:String, color:uint = 0xdff1f1, align:String = null):TextFormat {
			const format:TextFormat = new TextFormat(name, 11, color);
			format.align			= align || TextFormatAlign.LEFT;
			return format;
		};
		
		/**
		 * 	@private
		 */
		private const source:BitmapData	= new UIStartupImage().bitmapData;
		
		/**
		 * 	@private
		 */
		private const windows:Array		= [];
		
		/**
		 * 	@private
		 */
		private const onyx:Bitmap			= new UIAssetOnyxTitle();
		
		/**
		 * 	@private
		 */
		private const outputR:TextField		= createTextField();
		
		/**
		 * 	@private
		 */
		private const copyright:TextField	= createTextField();
		
		/**
		 * 	@private
		 */
		private var stage:Stage;
		
		/**
		 * 	@private
		 */
		private var states:StateQueue;
		
		/**
		 * 	@private
		 */
		private const formats:Vector.<TextFormat>	= Vector.<TextFormat>([
			createDefaultTextFormat('UIPixelFont', 0x666666),
			createDefaultTextFormat('UIPixelFont', 0x666666),
			createDefaultTextFormat('UIPixelFont', 0xAAAAAA),
			createDefaultTextFormat('UIPixelFont', 0xFFFFFF),
			createDefaultTextFormat('UIPixelFont', 0xFFCC00),
			createDefaultTextFormat('UIPixelFont', 0xFF3333)
		]);
		
		/**
		 * 	@public
		 */
		public function initialize():void {
			
			// set outputR defaults
			outputR.multiline						= true;
//			outputR.selectable						= true;
//			outputR.mouseEnabled						= true;
			outputR.width							= 400;
			outputR.height							= 400;
			
			// outputR any core events
			Console.RegisterListener(consoleListener);
			
			const screens:Vector.<Rectangle>		= Onyx.GetScreens();
			
			var maxIndex:int	= 1;
			var count:int		= 0;
			
			for each (var screen:Rectangle in screens) {
				var window:IDisplayWindow	= createWindow(screen);
				windows.push(window);
				
				window.bounds				= screen;
				window.activate();
				
				if (++count > maxIndex) {
					break;
				}
			}
			
			if (windows[0]) {
				window = windows[0];
				window.stage.addChild(outputR);
				window.stage.addChild(copyright);
				outputR.x = window.stage.stageWidth * .5;
				outputR.y = (window.stage.stageHeight * .33) + 90;
			}
		
			// initialize
			states = new StateQueue();
			states.initialize(new Callback(complete), [
				new FirstRunState(),
				new InitState()
			]);

		}
		
		/**
		 * 	@private
		 */
		private function complete():void {
			
			dispose();
			
		}

		/**
		 * 	@private
		 */
		private function createWindow(screen:Rectangle):IDisplayWindow {
			
			var window:IDisplayWindow 			= Onyx.CreateWindow('lightweight', 'none', 'cpu');
			var stage:Stage						= window.stage;
			window.bounds						= screen;
			
			var data:BitmapData					= new BitmapData(screen.width, screen.height, false, 0x00);
			var bitmap:Bitmap					= new Bitmap(data);
			data.draw(source, new Matrix(data.width / source.width, 0, 0, data.height / source.height), null, null, null, true);
			data.draw(onyx, new Matrix(1, 0, 0, 1, (bitmap.width * .5) >> 0, (bitmap.height * .33) >> 0), null, null, null, false);
			stage.addChild(bitmap);
			
			window.addEventListener('closing', handleClose);
			
			// push it
			windows.push(window);
			
			// return
			return window;
		}
		
		/**
		 * 	@private
		 */
		private function handleClose(event:Event):void {
			Onyx.Exit();
		}
		
		/**
		 * 	@private
		 */
		private function consoleListener(type:uint, str:String):void {
			
			outputR.scrollV				= outputR.maxScrollV;
			outputR.defaultTextFormat	= formats[type];
			outputR.appendText(str);
			
		}
		
		/**
		 * 	@public
		 */
		public function dispose():void {
			
			// outputR any core events
			Console.Unregister(consoleListener);

			while (windows.length) {
				var window:IDisplayWindow = windows.pop();
				while (window.stage.numChildren) {
					window.stage.removeChildAt(window.stage.numChildren - 1);
				}
				window.removeEventListener('closing', handleClose);
				window.close();
			}
		}
	}
}