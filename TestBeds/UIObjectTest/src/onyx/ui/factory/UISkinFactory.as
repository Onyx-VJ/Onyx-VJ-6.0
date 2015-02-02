package onyx.ui.factory {
	
	import flash.events.*;
	
	import onyx.ui.core.*;

	final public class UISkinFactory implements IFactory {
		
		/**
		 * 	@private
		 */
		private var c:Class;
		
		/**
		 * 	@private
		 */
		private var data:Object;
		
		/**
		 * 	@public
		 */
		public function UISkinFactory(c:Class):void {
			this.c	= c;
		}
		
		/**
		 * 	@public
		 */
		public function createInstance(token:Object = null):* {
			const obj:UIObject	= new c();
			obj.addEventListener(Event.ADDED_TO_STAGE, handleInitialize);
			return obj;
		}
		
		/**
		 * 	@private
		 */
		private function handleInitialize(e:Event):void {
			
			// all ui objects do this, can't be overridden
			const ui:UIObject 		= e.currentTarget as UIObject;
			ui.removeEventListener(Event.ADDED_TO_STAGE, handleInitialize);
			
			// unserialize the constraint
			ui.constraint.unserialize(data);
			
			// ok now arrange it
			var parent:UIObject = ui.parent as UIObject;
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