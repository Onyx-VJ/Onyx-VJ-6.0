package onyx.display.gpu {
	
	import flash.display.*;
	import flash.display3D.*;
	import flash.display3D.textures.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.utils.*;
	
	import onyx.core.*;
	import onyx.display.*;
	import onyx.event.*;
	import onyx.parameter.*;
	import onyx.plugin.*;
	import onyx.util.*;
	
	use namespace parameter;
	use namespace onyx_ns;
	
	[PluginInfo(
		id			= 'Onyx.Display.GPU.Layer',
		name		= 'Onyx.Display.GPU.Layer',
		depends		= 'Onyx.Display.GPU',
		vendor		= 'Daniel Hai',
		version		= '1.0'
	)]
	
	[Parameter(id='colorTransform',		type='colorTransform',			target='colorTransform', 	channels='rgba', size='1')]
	[Parameter(id='blendMode',			type='blendMode',				target='blendMode',			reset='Onyx.Display.Blend.Normal')]
	
	[Parameter(id='playMode',			target='playMode',				type='playMode',			reset='Onyx.PlayMode.Linear')]
	[Parameter(id='visible',			target='visible',				type='boolean',				reset='true')]
	[Parameter(id='playStart',			target='info/playStart',		type='number',				clamp='0,1',	reset='0')]
	[Parameter(id='playEnd',			target='info/playEnd',			type='number',				clamp='0,1',	reset='1')]
	[Parameter(id='playSpeed',			target='info/playSpeed',		type='number',				clamp='0,10',	reset='1',	precision='1')]
	[Parameter(id='playDirection',		target='info/playDirection',	type='number',				clamp='-1,1',	reset='1')]
	
	[Parameter(id='time',				target='time',					type='number',				clamp='0,1')]
	[Parameter(id='frameRate',			target='frameRate',				type='number',				clamp='0,60',	displayFunction='static::FormatFrameRate')]
	
	final public class DisplayLayerGPU extends ChannelGPUBase implements IDisplayLayerGPU {
		
		/**
		 * 	@public
		 * 	This will format the frame rate
		 */
		public static function FormatFrameRate(value:Number):String {
			if (value === 0) {
				return 'auto';
			}
			
			return value.toFixed(2);
		}
		
		/**
		 * 	@private
		 * 	The generator
		 */
		internal var generator:IPluginGenerator;
		
		/**
		 * 	@private
		 */
		parameter var visible:Boolean					= true;
		
		/**
		 * 	@private
		 */
		parameter var frameRate:Number					= 24;
		
		/**
		 * 	@private
		 * 	Color transform (alpha channel, etc)
		 */
		parameter const colorTransform:ColorTransform	= new ColorTransform();
		
		/**
		 * 	@private
		 * 	Blending mode
		 */
		parameter var blend:IPluginBlendGPU				= Onyx.CreateInstance('Onyx.Display.Blend.Normal') as IPluginBlendGPU;
		
		/**
		 * 	@private
		 * 	The playMode mode
		 */
		parameter var mode:IPluginPlayMode				= Onyx.CreateInstance('Onyx.PlayMode.Linear') as IPluginPlayMode;
		
		/**
		 * 	@parameter
		 */
		parameter const info:LayerTime					= new LayerTime();
		
		/**
		 * 	@private
		 */
		private var surface:DisplaySurface;
		
		/**
		 * 	@private
		 */
		private var surfaceTexture:DisplayTexture;
		
		/**
		 * 	@protected
		 */
		protected var display:IDisplay;
		
		/**
		 * 	@public
		 */
		public function initialize(display:IDisplay, contextGPU:IDisplayContextGPU):PluginStatus {
			
			// display
			this.display		= display;
			
			// listen for stuff
			context		= contextGPU as DisplayContextGPU;
			if (!context) {
				return new PluginStatus('Error Initializing Layer');
			}
			
			// make sure blendmodes and playmodes exist
			if (!blend) {
				return new PluginStatus('No blend mode found');
			}
			
			if (!mode) {
				return new PluginStatus('No play mode found');
			}
			
			var status:PluginStatus = blend.initialize(contextGPU);
			if (status !== PluginStatus.OK) {
				return status;
			}
			
			// mode
			status = mode.initialize(this);
			if (status !== PluginStatus.OK) {
				return status;
			}
			
			// ok fine
			return initializeChannel(context, context.width, context.height);
		}
		
		/**
		 * 	@public
		 */
		public function getSurface():DisplaySurface {
			return surface;
		}

		/**
		 * 	@public
		 */
		public function set time(value:Number):void {
			info.actualTime	= info.totalTime * value;
		}
		
		/**
		 * 	@public
		 */
		public function get time():Number {
			return info.totalTime > 0 ? info.actualTime / info.totalTime : 0;
		}
		
		/**
		 * 	@public
		 */
		public function set blendMode(value:IPlugin):void {
			
			const blend:IPluginBlendGPU = value as IPluginBlendGPU;
			if (blend && blend.initialize(context) === PluginStatus.OK) {
				
				this.blend = blend;
			
			// doesn't exist, create normal
			} else {
				
				this.blend	= Onyx.CreateInstance('Onyx.Display.Blend.Normal') as IPluginBlendGPU;
				this.blend.initialize(context);
				
			}
			
			invalid = true;
		}
		
		/**
		 * 	@public
		 */
		public function get blendMode():IPlugin {
			return blend;
		}
		
		/**
		 * 	@public
		 */
		parameter function set playMode(value:IPlugin):void {
			
			const mode:IPluginPlayMode = value as IPluginPlayMode;
			if (mode && mode.initialize(this)) {
				this.mode	= mode;
			} else {
				this.mode	= Onyx.CreateInstance('Onyx.PlayMode.Linear') as IPluginPlayMode;
			}
		}
		
		/**
		 * 	@public
		 */
		parameter function get playMode():IPlugin {
			return mode;
		}
		
		/**
		 * 	@public
		 */
		public function isVisible():Boolean {
			return visible;
		}
		
		/**
		 * 	@public
		 */
		public function setGenerator(instance:IPluginGenerator, file:IFileReference, content:Object):Boolean {
			
			// see if we have a previous generator
			if (generator) {
				
				generator.addEventListener(OnyxEvent.INVALIDATE, handleGenerator);
				generator.dispose();
				
				info.actualTime	= 0;
				info.totalTime	= 0;
				
				if (surface) {
					surface.dispose();
					context.releaseTexture(surfaceTexture);
					surfaceTexture = null;
				}
				if (texture) {
					texture.dispose();
				}
				
				// unload
				dispatchEvent(new OnyxEvent(OnyxEvent.LAYER_UNLOAD, this));
			}
			
			// now test the incoming
			generator = instance;
			
			// invalidate
			invalid = true;
			
			// set the generator to null
			if (!generator) {
				return false;
			}
			
			var status:PluginStatus = generator.initialize(context, file, content); 
			if (status === PluginStatus.OK) {
				
				CONSOLE::DEBUG('GENERATOR LOADED', generator);
				
				// listen for changes
				generator.addEventListener(OnyxEvent.INVALIDATE, handleGenerator);
				
				// store the time information
				info.totalTime	= generator.getTotalTime();
				
				// store the dimensions
				var dimensions:Dimensions = generator.getDimensions();
				
				// create a new surface
				surface				= new DisplaySurface(dimensions.width, dimensions.height, true, 0x00);
				surfaceTexture		= context.requestTexture(surface.width, surface.height) as DisplayTexture;
				
				// dispatch a load event
				dispatchEvent(new OnyxEvent(OnyxEvent.LAYER_LOAD, this));
				
				return true;

				// fail?
			} else {
				
				// error?
				Console.LogError(status.message);
				
				// dispose
				generator.dispose();
				
				// set generator to null
				generator = null;
				
				return false;
			}
		}
		
		/**
		 * 	@private
		 */
		private function handleGenerator(e:OnyxEvent):void {
			invalid = true;
		}
		
		/**
		 * 	@public
		 */
		public function getGenerator():IPluginGenerator {
			return generator;
		}
		
		/**
		 * 	@public
		 */
		public function render():Boolean {
			
			// return false
			if (!generator) {
				return false;
			}
			
			// deal with time -- are we paused?
			// does the generator have a new frame?  if so, update the texture
			if (info.playDirection === 0) {

				if (generator.update(info.totalTime === 0 ? 0 : info.actualTime / info.totalTime)) {
					invalid = updateTexture();
				}
				
			} else {
				
				// update the generator based on time
				if (generator.update(mode.update())) {
					invalid = updateTexture();
				}
			}

			// invalid?
			if (invalid) {
				
				validate();
				
				context.bindTexture(texture);
 				context.setBlendFactor(Context3DBlendFactor.ONE, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);
				context.clear(Color.CLEAR);
				context.draw(surfaceTexture);
				// channel.renderFilters(surfaceTexture);

			}
//				
//				// start the ping pong
//				var buffer:ContextGPUBuffer	= contextGPU.getRenderBuffer();
//				
//				// clear buffers
//				buffer.start();
//				
//				var screenX:Number	= surfaceTexture.width / channelGPU.texture.width * matrix.a;
//				var screenY:Number	= surfaceTexture.height / channelGPU.texture.height * matrix.d;
//				var ratio:Number	= 1.0;
//				
//				// draw the generator
//				contextGPU.setBlendFactor(Context3DBlendFactor.SOURCE_ALPHA, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);
//				contextGPU.drawTransform(surfaceTexture, Vector.<Number>([
//					screenX,		0.0,		0.0,	screenX - 1.0 + (matrix.tx / contextGPU.width), //(screenX - 1.0) + matrix.tx / gen.width,
//					0.0,			screenY,	0.0,	1.0 - screenY - (matrix.ty / contextGPU.height), //(1.0 - screenY) + matrix.ty / -gen.height,
//					0.0,			0.0,		1.0,	0.0,
//					0.0,			0.0,		0.0,	1.0
//				]));
//				
//				// swap buffers
//				buffer.swap();
//				
//				// bind the texture
//				contextGPU.bindTexture(channelGPU.texture);
//				contextGPU.clear(Color.CLEAR);
//				
//				// draw to the layer texture
//				contextGPU.setBlendFactor(Context3DBlendFactor.SOURCE_ALPHA, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);
//				contextGPU.draw(buffer.getPrevious());
//				
//				invalid = false;
//			}
//			
			// return false
			return true;
		}
		
		/**
		 * 	@private
		 */
		private function updateTexture():Boolean {
			
			// render the surface
			generator.render(channel);
			
			// update the texture
			surfaceTexture.upload(surface);
			
			// return true
			return true;
		}
//		
//		/**
//		 * 	@private
//		 */
//		private function doRender():Boolean {
//
//			// we're rendered the generator
//			dispatchEvent(new OnyxEvent(OnyxEvent.CHANNEL_RENDER_GENERATOR, gen));
//			
//			// TODO: now render the surface filters
//			// now update the texture
//			// texture.update();
//			
//			// bind
//			// contextGPU.bindTextureGPU(channelGPU.texture);
//			// contextGPU.clear(Color.Random());
//			
//			var buffer:ContextGPUBuffer	= contextGPU.getRenderBuffer();
//			buffer.start();
//			buffer.upload(surface);
//			
////			// swap the buffer
//			buffer.swap();
//			
//			// todo render the whatevers
//
//			// bind the texture
//			contextGPU.bindTexture(texture);
//			contextGPU.clear(Color.CLEAR);
//			contextGPU.draw(buffer.getPrevious());
//			
//			// invalidate
//			invalid = false;
//			
//			// return
//			return true;
//		}
		
		/**
		 * 	@public
		 */
		override public function serialize(options:uint = 0xFFFFFFFF):Object {
			
			if (generator) {
				
				const serialized:Object		= super.serialize();
				serialized.generator		= generator.serialize();
				
				return serialized;
			}
			
			return null;
		}
		
		/**
		 * 	@public
		 */
		override public function unserialize(token:*):void {
			
			if (token.parameters) {
				
				// unserialize?
				return super.unserialize(token.parameters);
				
			}
		} 
		
		/**
		 * 	@public
		 */
		public function get path():String {
			return generator ? generator.file.path : null;
		}
		
		/**
		 * 	@public
		 */
		public function get index():int {
			return display.getLayerIndex(this);
		}
		
		/**
		 * 	@public
		 */
		public function load(reference:IFileReference, token:Object):void {
			
			CONFIG::DEBUG {
				Debug.out('LOADING LAYER', token.path);
				Debug.object(token);
			}
			
			// load
			FileSystem.Load(reference, new Callback(handleLoad, [token]));
			
		}
		
		/**
		 * 	@private
		 */
		private function handleLoad(token:Object, file:IFileReference, content:Object, generator:IPluginGenerator):void {
			
			if (generator) {
				if (setGenerator(generator, file, content) && token) {
					generator.unserialize(token);
				};
			}
		}
		
		/**
		 * 	@public
		 */
		public function getTimeInfo():LayerTime {
			return info;
		}
		
		/**
		 * 	@public
		 */
		public function unload():void {
			
			// auto disposal is here
			generator = null;
			
			// clear the filters
			clearFilters();

		}
		
		/**
		 * 	@public
		 */
		public function get parent():IDisplay {
			return display;
		}
		
		/**
		 *	@public
		 */
		override public function dispose():void {
			
			// unload
			unload();
			
			// dispose
			super.dispose();
		}
		
		/**
		 * 	@public
		 */
		CONFIG::RELEASE override public function toString():String {
			
			if (gen) {
				return '[Layer: ' + gen.getFile().path + ']';
			}
			
			return '[Layer:' + index + ': [empty]]';
		}
		
		/**
		 * 	@public
		 */
		CONFIG::DEBUG override public function toString():String {
			
			if (generator) {
				return '[Layer: ' + generator.file.path + ']';
			}
			
			return '[Layer:' + index + ': [empty]]';
			
		}
	}
}