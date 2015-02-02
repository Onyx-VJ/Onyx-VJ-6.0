package onyxui.factory {
	
	import flash.utils.*;
	
	import onyx.plugin.*;
	
	import onyxui.core.*;
	
	final public class UIFactory {
		
		/**
		 * 	@private
		 */
		private var c:Class;
		
		/**
		 * 	@private
		 */
		public var data:Object;
		
		/**
		 * 	@public
		 */
		public function UIFactory(c:Class):void {
			this.c		= c;
			this.data	= OnyxUI.GetMetaData(c);
			
		}
		
		/**
		 * 	@public
		 */
		public function createInstance(token:Object = null):* {

			const window:UIObject = new c();
			
			if (token) {
				window.unserialize(token);
			}
			
			for each (var child:Object in data.UISkinPart) {

				if (child.definition) {
					
					var childClass:Class	= PluginDomain.getDefinition(child.definition) as Class;
					var childObj:UIObject	= new childClass();
					childObj.unserialize(child);
					
					// add skin
					window.addSkinPart(child.id, childObj);

				}
			}
			
			return window;
		}
	}
}