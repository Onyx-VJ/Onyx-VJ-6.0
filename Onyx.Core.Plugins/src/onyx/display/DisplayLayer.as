package onyx.display {
	
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
	import onyx.util.encoding.*;
	
	use namespace parameter;
	use namespace onyx_ns;
	
	[PluginInfo(
		id			= 'Onyx.Core.Display.Layer',
		name		= 'Onyx.Core.Display.Layer',
		depends		= 'Onyx.Core.Display,Onyx.PlayMode.Linear',
		vendor		= 'Daniel Hai',
		version		= '1.0'
	)]

	[Parameter(id='colorTransform',	target='colorTransform',		type='colorTransform',	channels='rgba', size='1')]
	[Parameter(id='blendMode',		target='blendMode',				type='blendMode')]
	[Parameter(id='playMode',		target='playMode',				type='playMode',		reset='Onyx.PlayMode.Linear')]
	[Parameter(id='visible',		target='visible',				type='boolean',			reset='true')]
	[Parameter(id='playStart',		target='info/playStart',		type='number',			clamp='0,1',	reset='0')]
	[Parameter(id='playEnd',		target='info/playEnd',			type='number',			clamp='0,1',	reset='1')]
	[Parameter(id='playSpeed',		target='info/playSpeed',		type='number',			clamp='0,10',	reset='1',	precision='1')]
	[Parameter(id='playDirection',	target='info/playDirection',	type='number',			clamp='-1,1',	reset='1')]
	
	[Parameter(id='time',			target='time',					type='number',			clamp='0,1')]
	[Parameter(id='frameRate',		target='frameRate',				type='number',			clamp='0,60')]
	[Parameter(id='type',			target='type',					type='array',			values='0x00,0x01', labels='cpu,gpu')]
	
	final public class DisplayLayer extends DisplayChannelBase implements IDisplayLayer {
		
		/**
		 * 	@private
		 */
		parameter var type:uint								= Plugin.CPU;

		/**
		 * 	@private
		 */
		parameter var visible:Boolean						= true;
		
		/**
		 * 	@private
		 * 	Color transform (alpha channel, etc)
		 */
		parameter const colorTransform:ColorTransform		= new ColorTransform();
		
		/**
		 * 	@private
		 * 	The playMode mode
		 */
		parameter var mode:IPluginPlayMode;

		/**
		 * 	@private
		 * 	0 is auto
		 */
		parameter var frameRate:uint						= 0;		
		
		/**
		 * 	@private
		 */
		private var display:Display;
		
		/**
		 *	@private
		 */
		parameter const info:LayerTime						= new LayerTime();
		
		/**
		 * 	@private
		 */
		internal var renderMode:ILayerRenderMode;
		
		/**
		 * 	@private
		 */
		RENDER::DISPLAY_GPU
		private var channel:ChannelMixed					= new ChannelMixed();

		/**
		 * 	@public
		 */
		public function initialize(display:Display):PluginStatus {
			
			// display
			this.display		= display;
			this.addEventListener(OnyxEvent.LAYER_MOVE, handleChannelName);
			
			// playmode
			playMode = Onyx.CreateInstance('Onyx.PlayMode.Linear');
			
			// mode
			if (!mode || mode.initialize(this) !== PluginStatus.OK) {
				return new PluginStatus('PlayMode invalid');
			}

			return PluginStatus.OK;
		}
		
		/**
		 * 	@private
		 */
		private function handleChannelName(e:OnyxEvent):void {
			if (renderMode) {
				renderMode.updateChannelName();
			}
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
		public function isVisible():Boolean {
			return visible && renderMode;
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
			
			if (renderMode && renderMode.setBlendMode(value)) {
				invalid = true;	
			}

		}
		
		/**
		 * 	@public
		 */
		public function get blendMode():IPlugin {
			return renderMode ? renderMode.getBlendMode() : null;
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
		public function setGenerator(instance:IPluginGenerator, file:IFileReference, content:Object):Boolean {
			
			// see if we have a previous generator
			// todo, check if generator is the same
			if (renderMode) {
				
				// unload
				unload(false);
				
			}
			
			if (instance is IPluginGeneratorCPU) {
				
				var cpu:DisplayLayerRenderModeCPU		= new DisplayLayerRenderModeCPU();
				var contextCPU:IDisplayContextCPU		= display.getContext(Plugin.CPU) as IDisplayContextCPU;		
				cpu.initialize(this, contextCPU, instance as IPluginGeneratorCPU, file, content);
				
				// set time
				info.totalTime	= instance.getTotalTime();
				
				// store the mode
				renderMode	= cpu;
				invalid		= true;
				
				// add a channel
				addChannel(renderMode.getChannel());
				
				parameters.hash.blendMode.updatePluginType(Plugin.BLENDMODE);
				
				// dispatch the load
				return dispatchEvent(new OnyxEvent(OnyxEvent.LAYER_LOAD, this));
			
			// TODO!
			} else if (instance is IPluginGeneratorGPU) {
				
				var gpu:DisplayLayerRenderModeGPU	= new DisplayLayerRenderModeGPU();
				var contextGPU:IDisplayContextGPU	= display.getContext(Plugin.GPU) as IDisplayContextGPU;
				gpu.initialize(this, contextGPU, instance as IPluginGeneratorGPU, file, content);
				
				// set time
				info.totalTime	= instance.getTotalTime();
				
				renderMode	= gpu;
				invalid		= true;
				
				addChannel(renderMode.getChannel());
				
				parameters.hash.blendMode.updatePluginType(0x10 | Plugin.BLENDMODE);
				
				// dispatch the load
				return dispatchEvent(new OnyxEvent(OnyxEvent.LAYER_LOAD, this));
			}
			return false;
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
			return renderMode ? renderMode.getGenerator() : null;
		}
		
		/**
		 * 	@public
		 */
		public function render():Boolean {

			// no generator, return false
			if (!renderMode) {
				return false;
			}

			// first we need to update the time if it's changed (pluginpatch can have variable lengths
			info.totalTime	= renderMode.getTotalTime();
			
			// update the generator based on time
			if (renderMode.update(mode.update())) {
				invalid = true;
			}

			// store a temporary redraw
			if (invalid) {
				
				// validate!
				checkValidation();
				
				// render!
				renderMode.render();

				// return true;
				return true;
			}
			
			// return
			return false;
		}

		/**
		 * 	@public
		 */
		public function draw():Boolean {
			return renderMode.draw(colorTransform);
		}
		
		/**
		 * 	@public
		 */
		override public function serialize(options:uint = 0xFFFFFFFF):Object {
			
			trace('xxx', options);
			
			const obj:Object	= renderMode.serialize(options);
			if (parameters) {
				const params:Object		= parameters.serialize(options);
				if (params) {
					obj.parameters	= params;
				}
			}
			
			return obj;
		}
		
		/**
		 * 	@public
		 */
		override public function unserialize(token:*):void {
			
			// Console.Log(CONSOLE::VERBOSE, 'Unserializing Layer', Serialize.toJSON(token, false));
			
			if (!token || !renderMode) {
				return;
			}
			
			// unserialize
			renderMode.unserialize(token);
			
			// unserialize;
			super.unserialize(token);
		} 
		
		/**
		 * 	@public
		 */
		public function get path():String {
			return renderMode ? renderMode.getGenerator().getFile().path : null;
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
				
				// set generator
				setGenerator(generator, file, content);
				
				// unserialize
				super.unserialize(token);
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
		public function unload(clear:Boolean = true):void {
			
			info.actualTime	= 0;
			info.totalTime	= 0;
			
			// nothing to unload
			if (!renderMode) {
				return;
			}
			
			renderMode.clearFilters();
			
			// dispatch an unload first
			dispatchEvent(new OnyxEvent(OnyxEvent.LAYER_UNLOAD, this));
				
			// remove the channel
			removeChannel(renderMode.getChannel());
			
			renderMode.dispose();
			renderMode = null;
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
			
			removeEventListener(OnyxEvent.LAYER_MOVE, handleChannelName);
			
			// dispose
			super.dispose();
		}
		
		/**
		 * 	@public
		 */
//		public function get channel():IChannel {
//			return this.
//		}
		
		/**
		 * 	@public
		 */
		public function getRenderType():uint {
			return renderMode ? renderMode.type : uint.MAX_VALUE;
		}
		
		/**
		 * 	@public
		 */
		override public function get name():String {
			return 'Layer: ' + display.getLayerIndex(this);
		}
	}
}