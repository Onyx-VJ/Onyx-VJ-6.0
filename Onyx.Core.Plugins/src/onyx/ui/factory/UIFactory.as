package onyx.ui.factory {
	
	import avmplus.*;
	
	import flash.events.*;
	import flash.system.*;
	import flash.utils.*;
	
	import onyx.core.Console;
	import onyx.ui.component.*;
	import onyx.ui.core.*;
	import onyx.ui.parameter.*;
	import onyx.util.ObjectUtil;
	import onyx.util.encoding.Serialize;
	
	use namespace skinPart;
	
	public class UIFactory implements IFactory {
		
		/**
		 * 	@private
		 */
		private static const HASH:Dictionary	= new Dictionary(true);
		
		/**
		 * 	@private
		 */
		protected var definition:Class;
		
		/**
		 * 	@private
		 */
		protected var data:Object;
		
		/**
		 * 	@private
		 */
		public function UIFactory(c:Class, token:Object = null):void {

			// store definition
			this.definition		= c;
			
			// clone to begin with
			this.data			= ObjectUtil.Clone(UIFactoryDefinitions.getMetaData(definition));
			
			if (token) {
				for (var i:String in token) {
					this.data[i] = token[i];
				}
			}
		}
		
		/**
		 * 	@public
		 */
		public function get id():String {
			
			if (data.id === undefined) {
				throw new Error('ID NOT DEFINED!');
			}
			
			return data.id;
		}
		
		/**
		 * 	@public
		 */
		public function unserialize(token:Object):void {
			
			for (var i:String in token) {
				switch (i) {
					case 'skins':
						
						var skinUpdate:Object = token[i];
						if (data.skins) {
							for each (var skin:Object in data.skins) {
								ObjectUtil.Merge(skinUpdate[skin.id], skin);
							}
						}
						
						break;
					default:
						
						this.data[i] = token[i];
						break;
				}
			}
		}
		
		/**
		 * 	@public
		 */
		public function createInstance(token:Object = null):* {

			var data:Object = ObjectUtil.Clone(this.data);
			if (token) {
				for (var i:String in token) {
					data[i] = token[i];
				}
			}
			
			// create the instance, wait for added, then init here
			const component:UIObject		= new definition();
			component.addEventListener(Event.ADDED_TO_STAGE,	componentInitialize);
			HASH[component] = data; 
			
			// return the object
			return component;
		}
		
		/**
		 * 	@private
		 */
		protected function componentInitialize(e:Event):void {
			
			// all ui objects do this, can't be overridden
			const component:UIObject 	= e.currentTarget as UIObject;
			component.removeEventListener(Event.ADDED_TO_STAGE, componentInitialize);
			
			// initialize
			component.initialize(HASH[component]);
			
			delete HASH[component];
		}
		
		CONFIG::DEBUG public function toString():String {
			return '[Factory:' + definition.toString() + ']';
		}
	}
}