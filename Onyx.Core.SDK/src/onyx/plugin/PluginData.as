package onyx.plugin {
	
	import avmplus.*;
	
	import flash.system.*;
	import flash.utils.*;
	import onyx.util.encoding.*;
	
	/**
	 *	@private 
	 */
	dynamic public final class PluginData {
		
		/**
		 * 	@private
		 * 	Stores a cache of objects by package name
		 */
		private static const DEFINITION_CACHE:Object		= {};
		
		/**
		 * 	@public
		 */
		public static function getMetaData(c:Class):PluginData {
			return DEFINITION_CACHE[avmplus.getQualifiedClassName(c)] || parseFactory(c);
		}
		
		/**
		 * 	@private
		 */
		private static function parseFactory(c:Class, domain:ApplicationDomain = null):PluginData {
			
			const factory:Object				= describeClass(c);
			const data:PluginData				= new PluginData();
			data.parameters						= {};
			
			var length:int						= 0;
			
			// By default, we go up the chain and cache parents
			// parameters are inherited
			for each (var name:String in factory.bases) {
				
				// break out if we're a base class
				if (name.length < 5 || name.indexOf('::') === -1 || name.substr(0, 6) == 'flash.') {
					break;
				}
				
				try {
					var parentClass:Class				= ApplicationDomain.currentDomain.getDefinition(name) as Class;
				} catch (e:Error) {
					break;
				}
				if (!parentClass) {
					break;
				}
				
				// parameters/skins inherit
				var parent:PluginData				= getMetaData(parentClass);
				if (parent.parameters) {
					
					for (var i:String in parent.parameters) {
						// copy parameters?
						data.parameters[i] = parent.parameters[i];
						++length;
					}
				}
			}
			
			// add the metdata, delete the name since it's stored as the key
			for each (var node:Object in factory.metadata) {
				switch (node.name) {
					case 'Parameter':
						
						// loop through the parameter keys
						var param:Object = {};
						for each (var key:Object in node.value) {
							param[key.key]	= key.value;
						}
						param.sort	= (param.sort === undefined) ? ++length : param.sort;
						
						// store the parameter
						data.parameters[param.id]	= param;
						
						break;
					case 'PluginInfo':
						
						for each (key in node.value) {
							data[key.key]	= key.value;
						}
						break;
				}
			}
			
			// test parameters, if there are none, delete the object
			var hasLength:Boolean = false;
			for each (var obj:Object in data.parameters) {
				hasLength = true;
				break;
			}
			
			if (!hasLength) {
				data.parameters = null;
			}
			
			return DEFINITION_CACHE[getQualifiedClassName(c)] = data;
		}
		
		/**
		 * 	@public
		 * 	Returns metdata for a specific key from an object
		 */
		public static function parseMetaKey(o:Object, type:String):Object {
			
			const factory:Object = describeObject(o);
			
			// add the metdata, delete the name since it's stored as the key
			for each (var node:Object in factory.metadata) {
				if (node.name === type) {
					
					const info:Object = {}
					for each (var key:Object in node.value) {
						info[key.key]	= key.value;
					}
					
					return info;
				}
			}
			return null;
		}
		
		/**
		 * 	@public
		 */
		public var name:String;
		
		/**
		 * 	@public
		 */
		public var id:String;
		
		/**
		 * 	@public
		 */
		public var depends:String;
		
		/**
		 * 	@public
		 */
		public var vendor:String;
		
		/**
		 * 	@public
		 * 	parameters
		 */
		public var parameters:Object;
		
		/**
		 * 	@public
		 * 	settings (loaded conf files)
		 */
		public var settings:Object;
		
		/**
		 * 	@public
		 */
		CONFIG::DEBUG public function toString():String {
			return JSON.stringify(this);
		}
	}
}