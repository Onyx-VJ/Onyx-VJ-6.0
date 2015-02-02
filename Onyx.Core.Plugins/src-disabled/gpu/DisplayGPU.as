package onyx.display.gpu {
	
	import flash.desktop.*;
	import flash.display.*;
	import flash.display3D.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.system.*;
	import flash.utils.*;
	
	import onyx.core.*;
	import onyx.display.*;
	import onyx.display.common.DisplayMouseProxy;
	import onyx.event.*;
	import onyx.plugin.*;
	import onyx.util.*;
	
	use namespace onyx_ns;
	use namespace parameter;
	
	[PluginInfo(
		id			= 'Onyx.Display.GPU',
		name		= 'Onyx.Display.GPU',
		vendor		= 'Daniel Hai',
		version		= '1.0'
	)]
	
	[Parameter(target='size/width', 		id='width',				type='number',	clamp='160,1920',	reset='320',	display='false')]
	[Parameter(target='size/height', 		id='height',			type='number',	clamp='120,1080',	reset='240',	display='false')]
	[Parameter(target='frameRate', 			id='frameRate',			type='number',	name='Frame Rate',	clamp='1,60',	reset='24')]
	[Parameter(target='backgroundColor', 	id='backgroundColor',	type='color',	name='Background',	reset='0x00000000')]
	
	/**
	 * 	@public
	 */
	final public class DisplayGPU extends ChannelGPUBase implements IDisplayGPU {

		/**
		 * 	@private
		 */
		private const layers:Vector.<DisplayLayerGPU>	= new Vector.<DisplayLayerGPU>();
		
		/**
		 * 	@private
		 */
		parameter const size:Dimensions					= new Dimensions(2048, 1024);
		
		/**
		 * 	@private
		 */
		parameter var backgroundColor:Color				= new Color(0, 0, 0);
		
		/**
		 * 	@private
		 */
		parameter var frameRate:Number					= 30;
		
		/**
		 * 	@private
		 */
		parameter var transform:ColorTransform			= new ColorTransform();
		
		/**
		 * 	@private
		 */
		private var nextTimeStamp:int;
		
		/**
		 * 	@private
		 */
		private var fps:int;
		
		/**
		 * 	@private
		 */
		private var paused:Boolean;

		/**
		 * 	@private
		 */
		private var initialized:Boolean;

		/**
		 * 	@private
		 */
		private var factory:IPluginDefinition		= Onyx.GetPlugin('Onyx.Display.GPU.Layer');

		/**
		 * 	@private
		 */
		private var matrix:Vector.<Number>;
		
		/**
		 * 	@private
		 */
		private var stage:Stage;
		
		/**
		 * 	@protected
		 */
		private var window:IDisplayWindow;
		
		/**
		 * 	@private
		 */
		private var proxy:DisplayMouseProxy;
		
		/**
		 * 	@public
		 */
		public function initialize(window:IDisplayWindow):PluginStatus {
			
			if (!factory) {
				return new PluginStatus('No layer factory defined');
			}

			// create the context
			context 	= new DisplayContextGPU();
			var status:PluginStatus = context.initialize(window.stage, size.width, size.height);
			if (status !== PluginStatus.OK) {
				Console.LogError('Error Initializing context: ' + status.message);
				return status;
			}
			
			// store window
			this.window	= window;
			this.proxy	= new DisplayMouseProxy(context, window);
			proxy.initialize();

			// initialize
			return initializeChannel(context, size.width, size.height);
		}
		
		/**
		 * 	@public
		 */
		public function start():void {
			window.stage.addEventListener(Event.ENTER_FRAME, handleFrame);
		}
		
		/**
		 * 	@public
		 */
		public function get index():int {
			return Onyx.GetDisplays().indexOf(this);
		}
		
		/**
		 * 	@private
		 */
		private function handleFrame(e:Event):void {
			
			if (!context.context) {
				return;
			}
			
			TimeStamp = getTimer();
			
			// TODO, need to set up
			if (invalid || TimeStamp > nextTimeStamp) {
				
				// next timestamp?
				nextTimeStamp = TimeStamp + (1000 / frameRate);
				
				// only render on timestamps
				render();
				
			}
		}
		
		/**
		 * 	@private
		 */
		private function handleResize(e:Event):void {
			trace(e);
		}
		
		/**
		 * 	@public
		 */
		override public function unserialize(token:*):void {
			if (token.parameters) { 
				super.unserialize(token.parameters);
			}
		}
		
		/**
		 * 	@private
		 */
		private function handleClose(e:Event):void {
			e.preventDefault();
		}
		
		/**
		 * 	@public
		 */
		public function show():void {
			window.activate();
		}
		
		/**
		 * 	@public
		 */
		public function getWindow():IDisplayWindow {
			return window;
		}
		
		/**
		 * 	@public
		 */
		public function getStage():Stage {
			return window.stage;
		}

		/**
		 * 	@public
		 */
		public function pause(value:Boolean):void {
			paused = value;
		}
		
		/**
		 * 	@public
		 */
		public function createLayer():IDisplayLayer {

			const layer:DisplayLayerGPU = factory.createInstance() as DisplayLayerGPU;
			const status:PluginStatus	= layer.initialize(this, context);
			if (status !== PluginStatus.OK) {
				Console.LogError('Error creating layer:', status.message);
				return null;
			}
			
			layer.addEventListener(OnyxEvent.LAYER_LOAD,		handleLayer);
			layer.addEventListener(OnyxEvent.LAYER_UNLOAD,		handleLayer);
			
			// push
			layers.push(layer);
			
			// dispatch
			dispatchEvent(new OnyxEvent(OnyxEvent.LAYER_CREATE, layer));
			
			// return
			return layer;
		}
		
		/**
		 * 	@protected
		 */
		protected function handleLayer(e:OnyxEvent):void {
			
			invalid = true;

		}
		
		/**
		 * 	@public
		 */
		public function render():Boolean {
			
			if (!texture.nativeTexture) {
				return false;
			}
			
			// paused?
			if (!paused) {
				
				var forceUpdate:Boolean	= invalid;
				
				// set alpha blending on
				context.setBlendFactor(Context3DBlendFactor.SOURCE_ALPHA, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);
				
				// see if anything has rendered first
				for each (var layer:DisplayLayerGPU in layers) {
					forceUpdate = (layer.render() && layer.isVisible()) || forceUpdate;
				}
			}

			// force update
			if (forceUpdate) {
				
				// bind the buffer (clear)
				context.bindBuffer();
				context.setBlendFactor(Context3DBlendFactor.SOURCE_ALPHA, Context3DBlendFactor.ONE);
				
				// render all the layers
				for each (layer in layers) {
					
					// is visible?
					if (layer.isVisible() && layer.generator) {
						
						// render
						(layer.blendMode as IPluginBlendGPU).render(context.getBuffer(), layer.texture, layer.colorTransform);
						
						// swap buffer
						context.swapBuffer();
					}

				}
				
				// we need to break out of here if nothing was swapped
				
				// draw the buffer to our texture
//				trace(texture, texture.width, texture.height);
				context.bindTexture(texture);
				context.clear(Color.CLEAR);
				context.setBlendFactor(Context3DBlendFactor.ONE, Context3DBlendFactor.ONE);
				context.draw(context.getBuffer());
				
				// blit the texture
				context.unbind();
				context.clear(backgroundColor);
				context.setBlendFactor(Context3DBlendFactor.ONE, Context3DBlendFactor.ONE);
				context.draw(texture);
				context.present();
				
				// invalid?
				invalid = false;
			}
			
			// return false
			return false;
		}
		
		/**
		 * 	@public
		 */
		public function getLayer(index:int):IDisplayLayer {
			return layers[index];
		}
		
		/**
		 * 	@public
		 */
		public function getLayers():Vector.<IDisplayLayer> {
			return Vector.<IDisplayLayer>(layers);
		}
		
		/**
		 * 	@public
		 */
		public function getLayerIndex(layer:IDisplayLayer):int {
			var test:DisplayLayerGPU = layer as DisplayLayerGPU;
			if (!test) { return -1; }
			
			return layers.indexOf(test);
		}
		
		/**
		 * 	@public
		 */
		public function swapLayers(layerA:IDisplayLayer, layerB:IDisplayLayer):void {
			
			const a:DisplayLayerGPU	= layerA as DisplayLayerGPU;
			const b:DisplayLayerGPU	= layerB as DisplayLayerGPU;
			
			const ai:int			= layers.indexOf(a);
			const bi:int			= layers.indexOf(b);
			
			CONFIG::DEBUG {
				if (ai === -1 || bi === -1) {
					throw new Error('LAYER IS NOT PART OF PARENT');
				} 
			}
			
			layers[bi]	= a;
			layers[ai]	= b;
			
			// move it!
			a.dispatchEvent(new OnyxEvent(OnyxEvent.LAYER_MOVE, a));
			b.dispatchEvent(new OnyxEvent(OnyxEvent.LAYER_MOVE, b));
			
		}
		
		/**
		 * 	@public
		 */
		public function drawThumbnail(width:int, height:int):BitmapData {
			return null;
		}
		
		/**
		 * 	@public
		 */
		public function get width():int {
			return context.width;
		}
		
		/**
		 * 	@public
		 */
		public function get height():int {
			return context.height;
		}
	}
}

//
//var screenIndex:int		= settings.screen	|| 1;
//if (!Screen.screens[screenIndex]) {
//	screenIndex = 0;
//}
//
//var quality:Object			= settings.quality		|| { width: 320, height: 240 };
//var width:int				= quality.width			|| 320;
//var height:int				= quality.height		|| 240;
//var layers:int				= settings.layers		|| 6;
//var native:NativeWindow;
//
//if (screenIndex > 0) {
//	
//	var screen:Screen	= Screen.screens[screenIndex];
//	native				= Onyx.CreateWindow(NativeWindowType.LIGHTWEIGHT, NativeWindowSystemChrome.NONE, screen.bounds);
//	
//} else {
//	
//	screen				= Screen.mainScreen;
//	native				= Onyx.CreateWindow(NativeWindowType.UTILITY, NativeWindowSystemChrome.STANDARD, new Rectangle(screen.bounds.width - width - 16, screen.bounds.height - height - 34, width + 16, height + 34));
//	
//}
//
//// create a window for the 3d context
//window	= new DisplayWindowGL();
//window.addEventListener(Event.CONTEXT3D_CREATE,	handleContext);
//window.initialize(width, height, native);
//
//matrix = Vector.<Number>([
//	
//	1.0,	0.0,	0.0,	0.0,
//	0.0,	1.0,	0.0,	0.0,
//	0.0,	0.0,	1.0,	0.0,
//	0.0,	0.0,	0.0,	1.0
//	
//]);
////			
////			matrix = Vector.<Number>([
////				
////				ratio * screenX,	0.0,	0.0,	ratio * screenX - 1.0,
////				0.0,	ratio * screenY,	0.0,	1.0 - ratio * screenY,
////				0.0,	0.0,	1.0,	0.0,
////				0.0,	0.0,	0.0,	1.0
////				
////			]);
//
//// proxy
//var display:DisplayGPU;
//Callback.proxy(this, new Callback(function():void {
//	callback.exec(display);
//}), 'initialize');