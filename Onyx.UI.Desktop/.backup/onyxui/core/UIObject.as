package onyxui.core {
	
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.text.*;
	
	import onyx.core.*;
	
	import onyxui.assets.*;
	import onyxui.component.*;
	import onyxui.core.*;
	
	use namespace skin;
	
	public class UIObject extends Sprite implements IDisposable {
		
		/**
		 * 	@private
		 */
		private static function handleStage(e:Event):void {
			const target:UIObject	= e.currentTarget as UIObject;
			target.removeEventListener(Event.ADDED_TO_STAGE, handleStage);
			target.initialize();
			
			trace(target, 'initialize');
		}
		
		/**
		 * 	@protected
		 */
		public const constraint:UIConstraint	= new UIConstraint();
		
		/**
		 * 	@public
		 */
		public function UIObject():void {
			
			// add listener!
			addEventListener(Event.ADDED_TO_STAGE, handleStage);
			
		}
		
		/**
		 * 	@protected
		 */
		protected function initialize():void {}
		
		/**
		 * 	@final
		 */
		final public function addSkinPart(id:String, component:UIObject):void {
			
			// store it
			// TODO, REFLECTION!
			this[id]	= component;
			
			// add the component
			addChild(component);

		}
		
		/**
		 * 	@public
		 */
		public function arrange(rect:Rectangle):void {
			
			x = rect.x;
			y = rect.y;
		}
		
		/**
		 * 	@public
		 */
		public function unserialize(token:Object):void {
			
			// top left right bottom
			constraint.unserialize(token);

		}
		
		/**
		 * 	@public
		 */
		public function dispose():void {}
	}
}