package onyx.host.gl {
	
	import com.adobe.utils.*;
	
	import flash.display.*;
	import flash.display3D.*;
	import flash.events.*;
	import flash.utils.*;
	
	import onyx.core.*;
	import onyx.display.*;
	import onyx.parameter.*;
	import onyx.plugin.*;
	import onyx.util.*;
	
	use namespace onyx_ns;
	use namespace parameter;

	/**
	 * 	@public
	 */
	final public class PluginGL implements IPluginDefinition {

		/**
		 * 	@private
		 * 	The vertex shader bytecode
		 */
		internal const vertexData:ByteArray						= Initializer.vertex;
		
		/**
		 * 	@private
		 * 	The fragment shader bytecode
		 */
		internal const fragmentData:ByteArray					= Initializer.fragment;
		
		/**
		 * 	@private
		 * 	Stores the plugin type
		 */
		internal const pluginType:uint							= Initializer.pluginType;
		
		/**
		 * 	@private
		 * 	The definition of the class we should create
		 */
		internal const definition:Class							= Initializer.definition;
		
		/**
		 * 	@private
		 * 	Other information
		 */
		internal const _info:Object								= Initializer.info;
		
		/**
		 * 	@private
		 * 	The vertex shader bytecode
		 */
		internal const defaultVertex:Vector.<Number>			= Initializer.vertParams;
		
		/**
		 * 	@private
		 * 	The vertex shader bytecode
		 */
		internal const defaultFragment:Vector.<Number>			= Initializer.fragParams;
		
		/**
		 * 	@private
		 * 	The vertex shader bytecode
		 */
		internal const parameters:Vector.<PluginGLParameterDef>	= Initializer.parameters;
		
		/**
		 * 	@internal
		 */
		internal const referrer:Dictionary						= new Dictionary();

		/**
		 * 	@internal
		 */
		internal const _path:String								= Initializer.path;
		
		/**
		 * 	@internal
		 */
		internal const _dependencies:String						= Initializer.dependencies;
		
		/**
		 * 	@public
		 */
		public function createInstance(... args:Array):IPlugin {
			
			const instance:PluginGLBase	= new definition();
			instance.definition			= this;
			
			// do we have data?
			if (parameters) {
				
				// instance.id
				instance.parameters = new ParameterList(PluginGLHost.Retrieve(instance));
				
			}
			
			// return
			return instance;
		};
		
		/**
		 * 	@public
		 */
		public function get enabled():Boolean {
			return _info['Plugin.Enabled'] === undefined || _info['Plugin.Enabled'] === true;
		}
		
		/**
		 * 	@public
		 */
		public function createProgram(context:IDisplayContextGPU):IDisplayProgramGPU {
			
			if (!context) {
				CONFIG::DEBUG {
					trace('WARNING:', 'no context passed to PluginGL');
				}
				return null;
			}
			
			
			var program:ContextProgram	= referrer[context];
			if (!program) {
				program = referrer[context] = new ContextProgram(context.requestProgram(vertexData, fragmentData, this.id));
				trace('creating program', this.id, program.refCount+1);
			}
			
			// increment
			++program.refCount;
			
			// returns the program
			return program.program;
		}

		/**
		 * 	@public
		 */
		public function release(context:IDisplayContextGPU):void {
			
			var program:ContextProgram	= referrer[context];
			CONFIG::DEBUG {
				if (!program) {
					throw new Error('PROGRAM DOES NOT EXIST!');
				}
			}
			trace('releasing program', this.id, program.refCount);
			
			// refcount == 0
			if (--program.refCount === 0) {
				program.program.dispose();
				delete referrer[context];
			}
		}
		
		/**
		 * 	@public
		 */
		public function get id():String {
			return _info['Plugin.ID'];
		}
		
		/**
		 * 	@public
		 */
		public function get info():Object {
			return _info;
		}
		
		/**
		 * 	@public
		 */
		public function get path():String {
			return _path;
		}
		
		/**
		 * 	@public
		 */
		public function get dependencies():String {
			return _dependencies;
		}
		
		/**
		 * 	@public
		 */
		public function get type():uint {
			return pluginType;
		}
		
		/**
		 * 	@public
		 */
		public function get name():String {
			return _info['Plugin.Name'] || this.id;
		}
		
		/**
		 * 	@public
		 */
		public function get icon():DisplayObject {
			return null;
		}
		
		/**
		 * 	@public
		 * 	Unserializes an object
		 */
		public function unserialize(token:*):void {}
		
		/**
		 * 	@public
		 * 	Serializes an object to JSON
		 */
		public function serialize(options:uint = 0xFFFFFFFF):Object {
			return null;
		}
		
		/**
		 * 	@public
		 */
		public function isModule():Boolean {
			return false;
		}
		
		/**
		 * 	@public
		 */
		public function toString():String {
			return this.name; // '[PluginGL: ' + info['Plugin.ID'] + ']';
		}
		
		/**
		 * 	@public
		 */
		public function releaseInstance(plugin:IPlugin):void {
			
		}
	}
}

import flash.display3D.*;

import onyx.core.*;

final class ContextProgram {
	
	/**
	 * 	@public
	 */
	public var refCount:int;
	
	/**
	 * 	@public
	 */
	public var program:IDisplayProgramGPU;
	
	/**
	 * 	@public
	 */
	public function ContextProgram(program:IDisplayProgramGPU):void {
		this.program	= program;
	}
} 