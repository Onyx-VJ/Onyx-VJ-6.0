package onyx.tests {
	
	import flash.display.*;
	import flash.display3D.*;
	import flash.events.Event;
	
	import onyx.display.*;
	
	public class TestBaseGL {
		
		/**
		 * 	@private
		 */
		protected const assets:Object	= {};
		
		/**
		 * 	@protected
		 */
		protected var context:ContextGL;
		
		/**
		 * 	@protected
		 */
		protected var stage:Stage;
		
		/**
		 * 	@constructor
		 */
		public function TestBaseGL(assets:Object):void {
			for (var i:String in assets) {
				this.assets[i] = assets[i];
			}
		}
		
		/**
		 * 	@public
		 */
		public function setup(stage:Stage, context:ContextGL):void {
			this.stage		= stage;
			this.context	= context;
			this.context.addEventListener(Event.CONTEXT3D_CREATE, handleContext);
		}
		
		/**
		 *	@private 
		 */
		private function handleContext(event:Event):void {
			initialize();
		}
		
		/**
		 * 	@public
		 */
		public function initialize():void {
		}
		
		/**
		 * 	@public
		 */
		public function render():void {
		}
		
		/**
		 * 	@public
		 */
		public function getAssets():Object {
			return assets;
		}
		
		/**
		 * 	@public
		 */
		public function dispose():void {
			context.removeEventListener(Event.CONTEXT3D_CREATE, handleContext);
		}
	}
}