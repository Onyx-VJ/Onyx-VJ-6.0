package onyx.host.swf {
	
	import avmplus.*;
	
	import flash.display.*;
	import flash.system.*;
	import flash.text.Font;
	import flash.utils.*;
	
	import onyx.core.*;
	import onyx.display.*;
	import onyx.parameter.*;
	import onyx.plugin.*;
	import onyx.util.*;
	import onyx.util.encoding.*;
	
	use namespace parameter;
	use namespace onyx_ns;
	
	final public class PluginSWFHost extends PluginBase implements IPluginHost {
		
		/**
		 * 	@private
		 */
		private static const PARAMETER_CACHE:Dictionary	= new Dictionary(true);
		
		/**
		 * 	@public
		 */
		public function PluginSWFHost():void {
			
			// this maybe for debug?
			var def:PluginSWF		= new PluginSWF();
			var data:PluginData		= new PluginData();
			data.id					= 'Onyx.PluginHost.SWF';
			def.data				= data;
			definition				= def;
			
		}
		
		/**
		 * 	@public
		 */
		public function initialize():PluginStatus {
			return PluginStatus.OK;
		}
		
		/**
		 * 	@public
		 */
		public function createDefinitions(data:Object, file:IFileReference, callback:Function):void {
			
			if (!(data is LoaderInfo)) {
				Console.LogError('DATA IS NOT LOADERINFO');
				callback(null);
				return;
			}
			
			const info:LoaderInfo				= data as LoaderInfo;
			const domain:ApplicationDomain		= info.applicationDomain;
			
			// parse the manifest out of the metadata
			const manifest:Object				= PluginData.parseMetaKey(info.content, 'PluginInfo');
			const definitions:Array				= String(manifest.manifest).split(';');
			const plugins:Array					= [];
			
			for each (var definition:String in definitions) {
				
				// make sure it's valid
				if (!definition) continue;
				
				// has definition?
				if (!domain.hasDefinition(definition)) {
					
					Console.LogError('Plugin definition defined but not found:', definition);
					
					continue;
				}
				
				const c:Class = domain.getDefinition(definition) as Class;
				if (c) {
					var plugin:IPluginDefinition = createPluginDefinition(domain, c);
					if (plugin) {
						plugins.push(plugin);
					} else {
						throw new Error('Error Retrieving Definition:' + definition, info.url);
					}
				}
			}
			
			callback(Vector.<IPluginDefinition>(plugins));
		}
		
		/**
		 * 	@private
		 */
		private function getPluginType(c:Class):uint {
			
			var traits:Object	= avmplus.describeClass(c);
			
			// get type based on the interface
			for each (var i:String in traits.bases) {
				switch (i) {
					case 'flash.text::Font':
						return Plugin.FONT;
				}
			}

			// get type based on the interface
			for each (i in traits.interfaces) {
				
				switch (i) {
					case 'onyx.core::IPluginHost':
						return Plugin.HOST;
					case 'onyx.core::IPluginFilterGPU':
						return 0x10 | Plugin.FILTER;
					case 'onyx.core::IPluginFilterCPU':
						return Plugin.FILTER;
					case 'onyx.core::IPluginBlendCPU':
						return Plugin.BLENDMODE;
					case 'onyx.core::IPluginBlendGPU':
						return 0x10 | Plugin.BLENDMODE;
					case 'onyx.core::IPluginGeneratorCPU':
						return Plugin.GENERATOR;
					case 'onyx.core::IPluginGeneratorGPU':
						return 0x10 | Plugin.GENERATOR;
						
					case 'onyx.core::IPluginPlayMode':
						return Plugin.PLAYMODE;
					case 'onyx.core::IDisplayTransform':
						return Plugin.TRANSFORM;
					case 'onyx.core::IPluginMacro':
						return Plugin.MACRO;
					// on modules, continue, because it could also be an interface
					case 'onyx.core::IPluginModule':
						return Plugin.MODULE;
					case 'onyx.core::IPluginInterface':
						return Plugin.INTERFACE;
					case 'onyx.core::IPluginProtocol':
						return Plugin.PROTOCOL;
					
					// everything else goes in here -- these are just display related plugins
					case 'onyx.core::IDisplay':
					case 'onyx.core::IChannel':
					case 'onyx.core::IDisplayLayer':
						return Plugin.DISPLAY;
				}
			}
			
			return uint.MAX_VALUE;
		}
		
		/**
		 * 	@private
		 * 	Creates a plugin definition
		 */
		private function createPluginDefinition(domain:ApplicationDomain, definition:Class):IPluginDefinition {
			
			// get the cache for the children
			const data:PluginData				= PluginData.getMetaData(definition);
			const type:uint						= getPluginType(definition);
			
			var plugin:IPluginDefinition;
			
			switch (type) {
				case uint.MAX_VALUE:
					Console.LogError('Invalid Plugin Type!');
					break;
				case Plugin.FONT:
					plugin = createFontPlugin(domain, definition, type, data);
					break;
				default:
					plugin = createDefaultPlugin(domain, definition, type, data);
					break;
			}
		
			// return plugin
			return plugin;
		}
		
		/**
		 * 	@private
		 */
		private static function createFontPlugin(domain:ApplicationDomain, definition:Class, type:uint, info:PluginData):PluginFont {
			
			const plugin:PluginFont				= new PluginFont();
			plugin.pluginType					= type;
			plugin.definition					= definition;
			
			// info
			if (!info || !info.id) {
				if (!info) {
					throw new Error('No PluginInfo Metadata: ' + info.id);
				} else if (!info.id) {
					throw new Error('No ID Defined: ' + info.id);
				}
				return null;
			}
			
			// store data
			plugin.data							= info;
			
			// return
			Font.registerFont(definition);
			
			// has icon?
			if (info.icon) {
				plugin.iconClass	= domain.hasDefinition(info.icon) ? (domain.getDefinition(info.icon) as Class) : null;
			}
			
			return plugin;
		}
		
		/**
		 * 	@private
		 */
		private static function createDefaultPlugin(domain:ApplicationDomain, definition:Class, type:uint, info:PluginData):PluginSWF {
			
			const plugin:PluginSWF			= new PluginSWF();
			plugin.pluginType				= type;
			plugin.factory					= (type === Plugin.GENERATOR && info.cacheContent) ? new PluginFactoryCache(plugin, definition) : new PluginFactoryDefault(definition);
			plugin.data						= info;
			
			// info
			if (!info || !info.id) {
				
				CONFIG::DEBUG {
					if (!info) {
						Console.Log(CONSOLE::WARNING, 'No PluginInfo Metadata: ' + info.id);
						return null;
					} else if (!info.id) {
						Console.Log(CONSOLE::WARNING, 'No ID Defined: ' + info.id);
						return null;
					}
				}
				
				return null;
			}
			
			plugin.data					= info;
			plugin.definitions			= ParseParameters(info);
			
			// has icon?
			if (info.icon) {
				plugin.iconClass = domain.hasDefinition(info.icon) ? (domain.getDefinition(info.icon) as Class) : null;
			}
			
			return plugin;
		}

		/**
		 * 	@private
		 */
		public static function createParameterDefinition(token:Object):PluginSWFDefinition {

			// no target, set it to name
			if (!token.target) {
				token.target = token.id;
			}
			
			// token type
			if (!token.type) {
				throw new Error('No type defined!');
				return null;
			}
			
			var definition:PluginSWFDefinition	= new PluginSWFDefinition();
			for (var i:String in token) {
				definition[i] = token[i];
			}
			
			// target object
			switch (definition.type) {
				
				////////////////////////
				case 'matrix':
					var channels:String							= definition.channels || 'adxy';
					var children:Vector.<PluginSWFDefinition>	= definition.children = new Vector.<PluginSWFDefinition>(String(channels.length), true);
					for (var count:int = 0; count < children.length; ++count) {
						switch (channels.charAt(count)) {
							case 'a':
								children[count] = new PluginSWFDefinition(definition.id, 'number', 'a',	{ clamp: '-3,3', reset: 1 });
								break;
							case 'd':
								children[count] = new PluginSWFDefinition(definition.id, 'number', 'd',	{ clamp: '-3,3', reset: 1 });
								break;
							case 'x':
								children[count] = new PluginSWFDefinition(definition.id, 'number', 'tx', { clamp: '-500,500', reset: 0 });
								break;
							case 'y':
								children[count] = new PluginSWFDefinition(definition.id, 'number', 'ty', { clamp: '-500,500', reset: 0 });
								break;
						}
					}
					break;
				
				case 'stageQuality':
					
					if (!definition.values) {
						definition.type		= 'array';
						definition.values	= '16x16linear,16x16,8x8linear,8x8,high,medium,low';
					} 
					
					break;
				
				////////////////////////
				case 'point':
					
					var buf:Array = (definition.reset || '0,0').split(',');
					
					children = definition.children = new Vector.<PluginSWFDefinition>(2, true);
					children[0]	= new PluginSWFDefinition('x', 'number', 'x', { clamp: definition.clamp || '-5,5', reset: buf[0] });
					children[1]	= new PluginSWFDefinition('y', 'number', 'y', { clamp: definition.clamp || '-5,5', reset: buf[1] });
					break;
				
				////////////////////////
				case 'matrix/scale':
					
					children = definition.children = new Vector.<PluginSWFDefinition>(2, true);
					children[0]	= new PluginSWFDefinition('a', 'number', 'a', { clamp: '-3,3', reset: 1 });
					children[1]	= new PluginSWFDefinition('d', 'number', 'd', { clamp: '-3,3', reset: 1 });
					
					break;
				
				////////////////////////
				case 'matrix/translate':
					children = definition.children = new Vector.<PluginSWFDefinition>(2, true);
					children[0]	= new PluginSWFDefinition('tx', 'number', 'tx', { clamp: '-3,3', reset: 0 });
					children[1]	= new PluginSWFDefinition('ty', 'number', 'ty', { clamp: '-3,3', reset: 0 });
					break;
				
				////////////////////////
				case 'colorTransform':
					
					channels	= definition.channels || 'rgba';
					children	= definition.children = new Vector.<PluginSWFDefinition>(String(channels.length), true);
					for (count = 0; count < children.length; ++count) {
						switch (channels.charAt(count)) {
							case 'r':
								children[count] = new PluginSWFDefinition('redMultiplier',		'number',	'redMultiplier', { reset: 1 });
								break;
							case 'g':
								children[count] = new PluginSWFDefinition('greenMultiplier',	'number',	'greenMultiplier', { reset: 1 });
								break;
							case 'b':
								children[count] = new PluginSWFDefinition('blueMultiplier',		'number',	'blueMultiplier', { reset: 1 });
								break;
							case 'a':
								children[count] = new PluginSWFDefinition('alphaMultiplier',	'number',	'alphaMultiplier', { reset: 1 });
								break;
						}
					}
					break;
			}
			
			return definition;
		}
		
		/**
		 * 	@private
		 */
		internal static function Retrieve(target:Object, cache:Boolean = true):Vector.<IParameter> {
			const c:Class	= Object(target).constructor;
			return RetrieveParameters(target, PARAMETER_CACHE[c] || ParseMetaData(c, cache));
		}
		
		/**
		 * 	@private
		 */
		private static function ParseMetaData(c:Class, cache:Boolean):Vector.<PluginSWFDefinition> {

			const params:Vector.<PluginSWFDefinition>	= ParseParameters(PluginData.getMetaData(c));
			if (cache) {
				PARAMETER_CACHE[c] = params;
			}
			
			return params;
		}
		
		/**
		 * 	@public
		 */
		public static function ParseParameters(data:PluginData):Vector.<PluginSWFDefinition> {
			
			const parameters:Array		= [];
			
			for (var i:String in data.parameters) {
				var parameter:PluginSWFDefinition	= createParameterDefinition(data.parameters[i]);
				if (parameter) {
					parameters.push(parameter);
				}
			}
			
			parameters.sortOn('sort', Array.NUMERIC | Array.DESCENDING);
			
			const vec:Vector.<PluginSWFDefinition>	= Vector.<PluginSWFDefinition>(parameters);
			vec.fixed	= true;
			return vec;
		}
		
		/**
		 * 	
		 */
		public static function RetrieveParameters(target:Object, definitions:Vector.<PluginSWFDefinition>):Vector.<IParameter> {
			const parameters:Vector.<IParameter>				= new Vector.<IParameter>(definitions.length, true);
			for (var count:int = 0; count < definitions.length; ++count) {
				parameters[count] = CreateParameter(target, definitions[count]);
			}
			
			return parameters;
		}
		
		/**
		 * 	@public
		 */
		public function createParameters(target:Object, cache:Boolean = true):Vector.<IParameter> {
			return Retrieve(target, cache);
		}
		
		/**
		 * 	@internal
		 */
		internal static function CreateParameter(target:Object, data:PluginSWFDefinition):IParameter {
			
			var parameter:PluginSWFParameter;
			
			// see if the property is a proxy to another object
			var prop:String = data.target || data.id;
			
			// allow it to see child properties
			var index:int	= prop.indexOf('/'); 
			if (index > 0) { 
				target						= target[prop.substr(0, index)];
				prop						= prop.substr(index + 1);
			}
			
			var type:String	= data.type.toLowerCase();
			switch (data.type.toLowerCase()) {
				case 'enum':
				case 'array':
					parameter	= new PluginSWFParameterArray();
					break;
				case 'number':
				case 'uint':
					parameter	= new PluginSWFParameterNumber();
					break;
				case 'status':
					parameter	= new PluginSWFParameterDispatcher();
					break;
				case 'integer':
				case 'int':
					parameter	= new PluginSWFParameterInteger();
					break;
				case 'color':
					
					// test the factory to see if it's a color?
					if (target[prop] is Color) {
						parameter	= new PluginSWFParameterColor();
					} else {
						parameter	= new PluginSWFParameterColorUInt();
					}
					
					break;
				case 'colortransform':
					parameter	= new PluginSWFParameterObject();
					break;
				case 'matrix/scale':
					parameter	= new PluginSWFParameterObject();
					break;
				case 'matrix/translate':
					parameter	= new PluginSWFParameterObject();
					break;
				case 'point':
					parameter	= new PluginSWFParameterObject();
					break;
				case 'matrix':
					parameter	= new PluginSWFParameterObject();
					break;
				case 'transform':
					parameter	= new PluginSWFParameterPlugin(Plugin.TRANSFORM);
					type		= 'array';
					break;
				case 'blendmode':
					parameter	= new PluginSWFParameterPlugin(Plugin.BLENDMODE);
					type		= 'array';
					break;
				case 'playmode':
					parameter	= new PluginSWFParameterPlugin(Plugin.PLAYMODE);
					break;
				case 'font':
					parameter	= new PluginSWFParameterFont();
					type		= 'array';
					break;
				case 'boolean':
					parameter	= new PluginSWFParameterBoolean();
					type		= 'array';
					break;
				case 'channelcpu':
					parameter	= new PluginSWFParameterChannel(Plugin.CPU);
					type		= 'array';
					break;
				case 'channelgpu':
					parameter	= new PluginSWFParameterChannel(Plugin.GPU);
					type		= 'array';
					break;
				case 'function':
					parameter	= new PluginSWFParameterFunction();
					break;
				case 'text':
				case 'string':
					parameter	= new PluginSWFParameter();
					break;
				default:
					Console.LogError('ERROR!', 'unknown parameter type', data);
					return null;
			}
			
			if (parameter) {

				parameter.initialize(target, prop, type, data);
				
				return parameter;
			} else {
				Console.LogError('ERROR!', parameter);
			}
			
			return null;
		}
		
		/**
		 * 	@public
		 */
		public function get extensions():Vector.<String> {
			return Vector.<String>(['swf']);
		}
	}
}