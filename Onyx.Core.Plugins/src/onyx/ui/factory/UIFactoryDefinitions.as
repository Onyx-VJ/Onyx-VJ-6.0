package onyx.ui.factory {
	
	import avmplus.*;
	
	import flash.events.*;
	import flash.system.*;
	import flash.utils.*;
	
	import onyx.ui.component.*;
	import onyx.ui.core.*;
	import onyx.ui.parameter.*;
	
	use namespace skinPart;
	
	public final class UIFactoryDefinitions {
		
		/**
		 * 	@private
		 */
		public static const ASSET_DOMAIN:ApplicationDomain	= new ApplicationDomain(ApplicationDomain.currentDomain);
		
		/**
		 * 	@private
		 */
		private static const METADATA:Dictionary			= new Dictionary(true);
		
		/**
		 * 	@private
		 */
		public static function getMetaData(definition:Class):Object {
			
			var meta:Object	= METADATA[definition];
			if (meta) {
				return meta;
			}
			
			var desc:Object	= describeClass(definition)
			meta			= {};
			
			// parse
			// add the metdata, delete the name since it's stored as the key
			for each (var node:Object in desc.metadata) {
				var name:String	= node.name;
				switch (name) {
					
					case 'UIConstraint':
						
						var param:Object = {};
						for each (var key:Object in node.value) {
							param[key.key] = key.value;
						}
						meta.constraint	= param;
						
						break;
					case 'UIComponent':
						
						for each (key in node.value) {
							meta[key.key] = key.value;
						}
						
						break;
					
					// parse skins
					case 'UISkinPart':
						
						param = {};
						var constraint:Object		= {};
						var hasConstraint:Boolean	= false;
						
						for each (key in node.value) {
							switch (key.key) {
								case 'constraint':
									constraint.type = key.value;
									hasConstraint	= true;
									continue;
								case 'bounds':
								case 'left':
								case 'right':
								case 'top':
								case 'bottom':
								case 'width':
								case 'height':
								case 'x':
								case 'y':
									constraint[key.key] = key.value;
									continue;
							}
							param[key.key]	= key.value;
						}
						
						if (hasConstraint) {
							param.constraint = constraint;
						}
						
						if (!meta.skins) {
							meta.skins = [];
						}
						
						meta.skins.unshift(param);
						
						break;
				}
			}

			return METADATA[definition] = meta;
		}

		/**
		 * 	@private
		 */
		private static const FACTORIES:Object	= {};
		
		/**
		 * 	@public
		 */
		public static function registerFactories(... factories:Array):void {
			
			for each (var factory:IFactory in factories) {
				FACTORIES[factory.id]	= factory;
			}
		}
		
		/**
		 * 	@public
		 */
		public static function Unserialize(id:String, token:Object):void {
			var factory:UIFactory = FACTORIES[id];
			if (factory) {
				factory.unserialize(token);
			}
		}
		
		/**
		 * 	@public
		 */
		public static function CreateAsset(name:String):* {
			if (ASSET_DOMAIN.hasDefinition(name)) {
				const c:Class = ASSET_DOMAIN.getDefinition(name) as Class;
				return new c();
			}
			return null;
		}
		
		/**
		 * 	@public
		 */
		public static function CreateInstance(type:String, token:Object = null):* {
			
			if (!FACTORIES[type]) {
				throw new Error('No type! ' + type);
			}
			
			return FACTORIES[type].createInstance(token);
		}
	}
}