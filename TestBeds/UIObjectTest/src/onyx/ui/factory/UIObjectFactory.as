package onyx.ui.factory {
	
	import avmplus.*;
	
	import flash.events.*;
	import flash.system.*;
	import flash.utils.*;
	
	import onyx.ui.component.*;
	import onyx.ui.core.*;
	import onyx.ui.utils.*;
	
	use namespace skin;
	
	final public class UIObjectFactory implements IFactory {
		
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
		private static function getMetaData(definition:Class):Object {
			var meta:Object	= METADATA[definition];
			if (meta) {
				return clone(meta);
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
							meta[key.key]	= key.value;
						}
						
						break;
					case 'UISkinPart':
						param = {};
						for each (key in node.value) {
							param[key.key]	= key.value;
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
		private static const FACTORIES:Object	= {
			'text':		new UIObjectFactory(UITextField),
			'window':	new UIObjectFactory(UIWindow),
			'skin':		new UIObjectFactory(UISkin, SKIN_INITIALIZER)
		};
		
		/**
		 * 	@private
		 */
		private static function SKIN_INITIALIZER(ui:UISkin, data:Object):void {
			if (data.skinClass) {
				ui.skinObject	= ui.addChild(UIObjectFactory.CreateAsset(data.skinClass));
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
			return FACTORIES[type].createInstance(token);
		}
		
		/**
		 * 	@private
		 */
		private var definition:Class;
		
		/**
		 * 	@public
		 */
		private var data:Object;
		
		/**
		 * 	@public
		 */
		public var children:Vector.<UIObjectFactory>;
		
		/**
		 * 	@private
		 */
		private var initializer:Function;
		
		/**
		 * 	@private
		 */
		public function UIObjectFactory(c:Class, initializer:Function = null):void {
			this.definition		= c;
			this.initializer	= initializer;
		}
		
		/**
		 * 	@public
		 */
		public function unserialize(token:Object):void {
			
			if (!data) {
				data = getMetaData(definition);
			}
			
			// todo, depending on the token, we should concat/find/etc
			for (var i:String in token) {
				data[i] = token[i];
			}

		}
		
		/**
		 * 	@public
		 */
		public function clone():UIObjectFactory {
			const fact:UIObjectFactory	= new UIObjectFactory(definition, initializer);
			fact.data					= data;
			return fact;
		}
		
		/**
		 * 	@public
		 */
		public function createInstance(token:Object = null):* {
			
			if (token) {
				const factory:UIObjectFactory = clone();
				factory.unserialize(token);
				return factory.createInstance();
			}
			
			// create the instance, wait for added, then init here
			const c:UIObject		= new definition();
			c.addEventListener(Event.ADDED_TO_STAGE, handleInitialize);
			
			// return the object
			return c;
		}
		
		/**
		 * 	@private
		 */
		private function handleInitialize(e:Event):void {
			
			// all ui objects do this, can't be overridden
			const ui:UIObject 		= e.currentTarget as UIObject;
			ui.removeEventListener(Event.ADDED_TO_STAGE, handleInitialize);
			
			if (!data) {
				data = getMetaData(definition);
			}
			
			// unserialize the constraint
			ui.constraint.unserialize(data);
			
			// initializer
			if (initializer !== null) {
				initializer(ui, data);
			}
			
			// ok now arrange it
			var parent:UIObject = ui.parent as UIObject;
			trace('arrange?', ui, parent);
			if (parent && parent.bounds) {
				ui.arrange(ui.constraint.measure(parent.bounds));
			}
			
			// children?
			var children:Array = data.skins;
			
			// create the children?
			if (children) {
				for each (var child:Object in children) {
					ui.addSkinPart(new QName(skin, child.id), UIObjectFactory.CreateInstance(child.type, child));
				}
			}
			
			
			// initialize
			ui.initialize(data);
		}
	}
}