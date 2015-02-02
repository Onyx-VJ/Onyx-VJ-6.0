package onyx.display {
	
	import flash.display.*;
	import flash.display3D.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.ui.*;
	import flash.utils.*;
	
	import onyx.core.*;
	import onyx.display.*;
	import onyx.event.*;
	import onyx.plugin.*;
	
	use namespace onyx_ns;
	use namespace parameter;
	
	[PluginInfo(
		id			= 'Onyx.Core.Display',
		name		= 'Display',
		vendor		= 'Daniel Hai',
		version		= '1.0'
	)]
	
	[Parameter(target='position/x', 					id='x',					type='number',			clamp='0,3840',	reset='0')]
	[Parameter(target='position/y', 					id='y',					type='number',			clamp='0,3840',	reset='0')]
	
	[Parameter(target='size/width', 					id='width',				type='number',			clamp='160,1920',	reset='320',	display='false')]
	[Parameter(target='size/height', 					id='height',			type='number',			clamp='120,1080',	reset='240',	display='false')]
	
	[Parameter(target='contextGPU/outputMatrix',		id='scale',				type='matrix/scale')]
	[Parameter(target='contextGPU/outputMatrix',		id='translate',			type='matrix/translate')]
	
	[Parameter(target='backgroundColor', 				id='backgroundColor',	type='color',			name='Background',		reset='0x00000000')]
	[Parameter(target='contextGPU/colorTransform',		id='colorTransform',	type='colorTransform',	name='Transform',		channels='rgba')]
	[Parameter(target='contextCPU/quality',				id='quality',			type='stageQuality',	name='Vector Quality', reset='high')]	
	[Parameter(target='contextCPU/smoothing',			id='smoothing',			type='array',			name='Bitmap Quality',	values='1,2',			labels='linear,none')]
	[Parameter(target='contextGPU/textureAntiAlias',	id='antiAlias',			type='array',			name='GPU Antialias',	values='0,2,4,8,16',	labels='none,2x,4x,8x,16x')]
	[Parameter(target='frameRate', 						id='frameRate',			type='number',			name='Frame Rate',		clamp='1,60',	reset='24')]
	
	final public class Display extends DisplayChannelBase implements IDisplay {
		
		/**
		 * 	@private
		 */
		parameter const size:Dimensions									= new Dimensions(320, 240);
		
		/**
		 * 	@private
		 */
		parameter const position:Point									= new Point(0, 0);
		
		/**
		 * 	@private
		 */
		parameter var frameRate:Number									= 24;
		
		/**
		 * 	@parameter
		 */
		parameter var backgroundColor:uint								= 0xFFFFFF;
		
		/**
		 * 	@parameter
		 */
		private const color:Color										= new Color();
		
		/**
		 * 	@private
		 */
		private var window:IDisplayWindow;
		
		/**
		 * 	@private
		 */
		private var nextTimeStamp:int									= 1;
		
		/**
		 * 	@private
		 */
		private var stage:Stage;
		
		/**
		 * 	@private
		 */
		private var proxy:DisplayMouseProxy;
		
		/**
		 * 	@private
		 */
		onyx_ns const contextCPU:DisplayContextCPU	= new DisplayContextCPU();

		/**
		 * 	@private
		 */
		onyx_ns const contextGPU:DisplayContextGPU	= new DisplayContextGPU();
		
		/**
		 * 	@private
		 */
		RENDER::DISPLAY_MIXED
		onyx_ns const channel:ChannelMixed = Onyx.CreateInstance('Onyx.Display.Channel::MIX') as ChannelMixed;
		
		/**
		 * 	@private
		 */
		private var factory:IPluginDefinition;
		
		/**
		 * 	@public
		 */
		public function initialize(window:IDisplayWindow, x:int, y:int, width:int, height:int):PluginStatus {
			
			this.window	= window;
			this.stage	= window.stage;
			
			if (!channel) {
				return new PluginStatus('Error creating channels!');
			}
			
			trace('INIT DISPLAY!', arguments);
			
			factory			= Onyx.GetPlugin('Onyx.Core.Display.Layer');
			channel._name	= 'Display: ' + Onyx.GetDisplays().indexOf(this);
			
			// initialize!

			// cpu is always initialized, even in gpu mode
			// this is because layers will use this context
			contextCPU.initialize(size.width, size.height);
			contextGPU.initialize(stage, x, y, width, height);
			
			// return
			var status:PluginStatus = channel.initialize(this, contextCPU, contextGPU, false);
			if (status !== PluginStatus.OK) {
				return status;
			}
			
			addChannel(channel);

			// initialize
			proxy								= new DisplayMouseProxy(window, position.x, position.y, contextCPU.width, contextCPU.height, contextCPU, contextGPU);
			proxy.initialize();
			
			// activate
			window.activate();
			window.addEventListener('closing', handleClose);
			
			// ok
			return PluginStatus.OK;
		}
		
		/**
		 * 	@public
		 */
		override public function get name():String {
			return 'Display ' + Onyx.GetDisplays().indexOf(this);
		}
		
		/**
		 * 	@private
		 */
		public const layers:Vector.<IDisplayLayer>	= new Vector.<IDisplayLayer>();
		
		/**
		 * 	@public
		 */
		public function getLayer(index:int):IDisplayLayer {
			return index < layers.length ? layers[index] : null;
		}
		
		/**
		 * 	@public
		 */
		public function getLayerIndex(layer:IDisplayLayer):int {
			return layers.indexOf(layer);
		}
		
		/**
		 * 	@public
		 */
		public function createLayer():IDisplayLayer {
			
			var layer:DisplayLayer	= factory.createInstance() as DisplayLayer;
			if (!layer) {
				return null;
			}
			
			var status:PluginStatus = layer.initialize(this);
			if (status !== PluginStatus.OK) {
				Console.LogError('Error Creating Layer:', status.message);
				return null;
			}
			
			// listen to stuff
			layer.addEventListener(OnyxEvent.LAYER_LOAD,	handleLayer);
			layer.addEventListener(OnyxEvent.LAYER_UNLOAD,	handleLayer);
			
			// push!
			layers.push(layer);
			
			// dispatch a creation
			dispatchEvent(new OnyxEvent(OnyxEvent.LAYER_CREATE, layer));
			
			// create layer
			return layer;
		}
		
		/**
		 * 	@public
		 */
		public function swapLayers(a:IDisplayLayer, b:IDisplayLayer):void {
			
			const ai:int			= layers.indexOf(a);
			const bi:int			= layers.indexOf(b);
			
			CONFIG::DEBUG {
				if (ai === -1 || bi === -1) {
					throw new Error('LAYER IS NOT PART OF PARENT');
					return;
				} 
			}
			
			layers[bi]	= a;
			layers[ai]	= b;
			
			// dispatch events
			a.dispatchEvent(new OnyxEvent(OnyxEvent.LAYER_MOVE, a));
			b.dispatchEvent(new OnyxEvent(OnyxEvent.LAYER_MOVE, b));
			
		}
		
		/**
		 * 	@public
		 */
		public function getContext(type:uint = 0x00):IDisplayContext {
			RENDER::DISPLAY_MIXED {
				return type === 0x01 ? contextGPU : contextCPU;
			}
		}
		
		/**
		 * 	@public
		 */
		public function get channelName():String {
			return '[Display: ' + Onyx.GetDisplays().indexOf(this) + ']';
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
		private function handleClose(e:Event):void {
			e.preventDefault();
		}
		
		/**
		 * 	@public
		 */
		public function start():void {
			if (!contextGPU.context) {
				contextGPU.addEventListener(OnyxEvent.GPU_CONTEXT_CREATE, handleContext);
			} else {
				stage.addEventListener(Event.ENTER_FRAME, handleFrame);
			}
		}
		
		/**
		 * 	@private
		 */
		private function handleContext(e:Event):void {
			contextGPU.removeEventListener(OnyxEvent.GPU_CONTEXT_CREATE, handleContext);
			stage.addEventListener(Event.ENTER_FRAME, handleFrame);
		}
		
		/**
		 * 	@private
		 */
		private function handleFrame(e:Event):void {
			
			TimeStamp = getTimer();
			
			// do clean ups? 
			if (TimeStamp < nextTimeStamp) {
				
				// clean up memory
				contextCPU.cleanup(5);
				
			} else {
				
				// next timestamp?
				nextTimeStamp = TimeStamp + (1000 / frameRate);
				
				// only render on timestamps
				CONFIG::RELEASE {
					try {
						render();
					} catch (e:Error) {
						Console.LogError(e.message);
					}
				}
				
				CONFIG::DEBUG {
					render();
				}
			}
		}
		
		/**
		 * 	@public
		 */
		override public function serialize(options:uint = 0xFFFFFFFF):Object {
			
			var data:Object		= {};
			var params:Object	= parameters.serialize(options, { 'backgroundColor': true });
			if (params) {
				data.parameters	= params;
			}
			
			data.channel		= channel.serialize(options);
			
			return data;
		}
		
		/**
		 * 	@public
		 */
		public function pause(value:Boolean):void {}

		/**
		 * 	@public
		 */
		override protected function validate(invalidParameters:Object):void {
			
			if (invalidParameters.backgroundColor) {
				color.fromInt(backgroundColor);
			}
			
			if (invalidParameters.x !== undefined || invalidParameters.y !== undefined) {
				
				trace(invalidParameters.x, invalidParameters.y)
				contextGPU.setPosition(
					position.x,
					position.y
				);
			}
			
			if (invalidParameters.scale || invalidParameters.translate) {
				contextGPU.updateProjectionMatrix();
			}
		}
		
		/**
		 * 	@public
		 */
		public function render():Boolean {
			
			// set the current context rectangle
			CONST_RECT = contextCPU.rect;
			
			// loop through and update layers
			var updated:Boolean	= invalid;
			if (invalid) {
				checkValidation();
			}
			
			if (!contextGPU.context) {
				return false;
			}
			
			// test to see if driver is ok
			if (contextGPU.context && contextGPU.context.driverInfo === 'Disposed') {
				Console.Log(CONSOLE::WARNING, 'GPU Context Destroyed');
				contextGPU.context = null;
				return contextGPU.dispatchEvent(new OnyxEvent(OnyxEvent.GPU_CONTEXT_DESTROY));
			}
			
			var updatedLayers:Array = [];
			for each (var layer:DisplayLayer in layers) {
				if (layer.render()) {
					updatedLayers.push(layer);
					updated = true;
				}
			}
			
			// updated?
			if (updated) {
				
				
				/*
				 *
				 *	Mixed rendering mode -- layers can draw either to surface that is uploaded, or directly
				 *	to gpu
				 */
				RENDER::DISPLAY_MIXED {
					
					// bind the channel
					contextCPU.bindChannel(channel);
					
					// clears target
					contextCPU.clear(backgroundColor);
					
					// swap!
					contextCPU.swapBuffer();
					
					// render layers
					for each (layer in layers) {
						
						// render
						if (layer.isVisible() && layer.getRenderType() === Plugin.CPU && layer.draw()) {
							
							// swap the buffer!
							contextCPU.swapBuffer();
							
						}
					}
					
					// loop through filters
					for each (var filter:IPluginFilterCPU in channel.filtersCPU) {
						
						filter.checkValidation();
						
						// render and swap?
						if (filter.render(contextCPU)) {
							contextCPU.swapBuffer();
						}
					}
					
					// swap the buffer
					contextCPU.unbind();
					
					// tell the channel that it's finished rendering
					channel.dispatchEvent(new OnyxEvent(OnyxEvent.CHANNEL_RENDER_CPU, channel));
					
					// blending is always done with pre-multiplied
					contextGPU.setBlendFactor(Context3DBlendFactor.ONE, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);
					
					// now we need to update the context
					contextGPU.bindChannel(channel);
					contextGPU.clear(color);
					contextGPU.upload(channel.internalSurface);
					contextGPU.swapBuffer();
					
					// loop through gpu layers
					// TODO: OPTIMIZE THE LOOP?
					for each (layer in layers) {
						
						// render
						if (layer.isVisible() && layer.getRenderType() === Plugin.GPU && layer.draw()) {
							
							// swap the buffer!
							contextGPU.swapBuffer();
							
						}
					}
					
					// loop through filters and render
					for each (var filterGPU:IPluginFilterGPU in channel.filtersGPU) {
						
						filterGPU.checkValidation();
						
						// render and swap?
						if (filterGPU.render(contextGPU)) {
							contextGPU.swapBuffer();
						}
					}
					
					// unbind
					contextGPU.unbind();
					
					// tell the channel that it's finished rendering
					// but we also want to be able to cancel the default render to screen
					if (channel.dispatchEvent(new OnyxEvent(OnyxEvent.CHANNEL_RENDER_GPU, channel, true))) {
						
						// present -- background color comes from the surface
						contextGPU.clear(Color.BLACK);
						
						// present
						contextGPU.present(channel.texture);
						
					}
				}
			}
			
			// return false
			return false;
		}
		
		/**
		 * 	@public
		 */
		public function show():void {}
		
		/**
		 * 	@private
		 */
		private function handleLayer(e:OnyxEvent):void {
			invalid = true;
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
		override public function dispose():void {
			
			window.removeEventListener('closing', handleClose);
//			var stage:Stage3D = window.stage.stage3Ds[0];
//			stage.removeEventListener(Event.CONTEXT3D_CREATE, handleContext);
			
			super.dispose();
		}
		
		/**
		 * 	@public
		 */
		public function drawThumbnail(width:int, height:int):BitmapData {
			
			const bmp:BitmapData	= new BitmapData(width, height, false, 0);
			const data:BitmapData	= channel.internalSurface;
			
			// as good as you can get
			bmp.drawWithQuality(data, new Matrix(bmp.width / data.width, 0, 0, bmp.height / data.height), null, null, null, true, StageQuality.BEST);
			
			return bmp;
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
		public function get width():int {
			return size.width;
		}
		
		/**
		 * 	@public
		 */
		public function get height():int {
			return size.height;
		}
		
		/**
		 * 	@public
		 */
		public function getLayers():Vector.<IDisplayLayer> {
			return layers;
		}
	}
}