package onyx.host.gl {
	
	import com.adobe.utils.*;
	
	import flash.display.*;
	import flash.display3D.*;
	import flash.system.*;
	import flash.utils.*;
	
	import onyx.core.*;
	import onyx.parameter.*;
	import onyx.plugin.*;
	import onyx.util.*;
	import onyx.util.encoding.*;
	
	use namespace onyx_ns;
	
	[PluginInfo(
		id			= 'Onyx.PluginHost.GL',
		name		= 'Onyx.PluginHost.GL',
		vendor		= 'Daniel Hai',
		depends		= 'Onyx.Display.GPU',
		version		= '1.0',
		fileType	= 'onx'
	)]
	
	final public class PluginGLHost extends PluginBase implements IPluginHost {
		
		/**
		 * 	@private
		 */
		private static const DEFINITION_CACHE:Dictionary	= new Dictionary(true);
		
		/**
		 * 	@public
		 */
		public function createDefinitions(data:Object, file:IFileReference, callback:Function):void {
			
			if (!data is String) {
				callback(null);
				return;
			}
			
			callback(Vector.<IPluginDefinition>([createDefinition(file, data as String)]));
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
		public static function Retrieve(target:Object):Vector.<IParameter> {
			
			var plugin:PluginGLBase		= target as PluginGLBase;
			var definition:PluginGL		= plugin.definition as PluginGL;
			
			plugin.dataFrag				= definition.defaultFragment ? definition.defaultFragment.concat() : null;
			plugin.dataVert				= definition.defaultVertex ? definition.defaultVertex.concat() : null;
			
			const params:Vector.<IParameter>	= new Vector.<IParameter>(definition.parameters.length, true);
			
			var count:int = 0;
			for each (var def:PluginGLParameterDef in definition.parameters) {
				params[count++] = new PluginGLParameter(def, def.program === Context3DProgramType.FRAGMENT ? plugin.dataFrag : plugin.dataVert);
			}
			
			// create the parameters
			return params;
		}
		
		/**
		 * 	@public
		 */
		public function createParameters(target:Object, cache:Boolean = true):Vector.<IParameter> {
			return Retrieve(target);
		}
		
		/**
		 * 	@public
		 * 	Creates a plugin
		 */
		private function createDefinition(file:IFileReference, data:String):PluginGL {
			
			const token:Object	= tokenize(data);
			if (!token) {
				return null;
			}
			
			var pluginType:int, vertexData:ByteArray, fragmentData:ByteArray, definition:Class, id:String, parameters:Array = [];
			
			switch (token['Plugin.Type']) {
				case 'Filter':
					pluginType	= 0x10 | Plugin.FILTER;
					definition	= PluginGLFilter;
					break;
				case 'Render':
					pluginType	= Plugin.DISPLAY;
					definition	= PluginGLRender;
					break;
				case 'BlendMode':
					pluginType	= 0x10 | Plugin.BLENDMODE;
					definition	= PluginGLBlend;
					break;
				default:
					CONFIG::DEBUG { throw new Error('Unknown Plugin Type'); }
					return null;
			}
			
			// automatically set the plugin name
			if (file && token['Plugin.ID'] == undefined) {
				token['Plugin.ID'] = file.name.substr(0, -4);
			}
			
			const assembler:AGALMiniAssembler	= new AGALMiniAssembler();
			
			// store
			vertexData							= assembler.assemble(Context3DProgramType.VERTEX,	token['Plugin.Shader.Vertex']);
			fragmentData						= assembler.assemble(Context3DProgramType.FRAGMENT,	token['Plugin.Shader.Fragment']);
			
			// set stuff
			if (vertexData && fragmentData && pluginType && definition && token['Plugin.ID']) {
				
				delete token['Plugin.Shader.Vertex'];
				delete token['Plugin.Shader.Fragment'];
				
				// parameters?
				var paramVert:Vector.<Number> = parseParameters(Context3DProgramType.VERTEX, token['Plugin.Parameters.Vertex'],		parameters);
				var paramFrag:Vector.<Number> = parseParameters(Context3DProgramType.FRAGMENT, token['Plugin.Parameters.Fragment'],	parameters);
				var params:Vector.<PluginGLParameterDef>	= Vector.<PluginGLParameterDef>(parameters);
				params.fixed	= true;
				
				
				// create the parameters, etc
				Initializer	= {
					path:			file.path,
					info:			token,
					vertex:			vertexData,
					fragment:		fragmentData,
					definition:		definition,
					pluginType:		pluginType,
					vertParams:		paramVert,
					fragParams:		paramFrag,
					parameters:		params,
					dependencies:	token['Plugin.Depends']
				};
				
				return new PluginGL();
			}
			
			return null;
		}
		
		/**
		 * 	@private
		 */
		private static const PARAM_TYPES:Object = {
			'matrix4':			16,
			'colorTransform':	4,
			'vec4':				4,
			'float4':			4,
			'matrix3':			9
		};
		
		/**
		 * 	@private
		 */
		private static function parseParameters(program:String, parameters:Array, target:Array):Vector.<Number> {
			
			if (!parameters) {
				return null;
			}
			
			const data:Array = [];
			for each (var param:Object in parameters) {
				
				var definition:PluginGLParameterDef = new PluginGLParameterDef();
				definition.id						= param.id;
				definition.name						= param.name || param.id;
				definition.program					= program;
				
				// invalid parameter type
				if (PARAM_TYPES[param.type] === undefined) {
					
					CONFIG::DEBUG { throw new Error('INVALID PARAMETER TYPE!'); }
					
					return null;
				}
				
				var length:int = PARAM_TYPES[param.type];
				
				if (!param.data || param.data.length !== length) {
					CONFIG::DEBUG { throw new Error('NO PARAMETER DATA OR PARAMETER DATA INVALID'); }
					return null;
				}
				
				// store the start / length
				definition.index	= data.length;
				definition.length	= param.data.length;
				
				// push the data in
				data.push.apply(null, param.data);
				
				// push the parameter
				target.push(definition);
				
			}
			
			return Vector.<Number>(data);
		}
		
		/**
		 * 	@private
		 * 	Tokenizes a text file into usable
		 */
		private static function tokenize(data:String):Object {
			
			const reg:RegExp 		= /\[(.+?)\]/g;
			const serialized:Object	= {};
			var match:Array;
			var token:String;
			var last:int;
			
			// look for tokens
			while (match = reg.exec(data)) {
				if (last) {
					serialized[token] = data.substr(last, reg.lastIndex - last - match[0].length);
				}
				
				token	= match[1];
				last	= reg.lastIndex;
			}
			serialized[token] = data.substr(last);
			
			// not valid
			if (!serialized['Plugin.Shader.Info'] || !serialized['Plugin.Shader.Vertex'] || !serialized['Plugin.Shader.Fragment']) {
				return null;
			}
			const obj:Object 								= Serialize.fromJSON(serialized['Plugin.Shader.Info']);
			
			// copy the shader data
			obj['Plugin.Shader.Vertex']						= serialized['Plugin.Shader.Vertex'];
			obj['Plugin.Shader.Fragment']					= serialized['Plugin.Shader.Fragment'];
			
			// obj
			return obj;
		}
	}
}