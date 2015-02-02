package {
	
	import flash.display.*;
	import flash.events.Event;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;
	
	import onyx.ui.core.*;
	import onyx.ui.factory.*;
	
	final public class UIObjectTest extends Sprite {
		
		/**
		 * 	@private
		 */
		public function UIObjectTest():void {
			
			stage.align					= StageAlign.TOP_LEFT;
			stage.scaleMode				= StageScaleMode.NO_SCALE;
			
			const loader:Loader			= new Loader();
			const context:LoaderContext	= new LoaderContext(false, UIObjectFactory.ASSET_DOMAIN);
			loader.load(new URLRequest('1600x1200.swf'), context);
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, function(e:*):void {
				createChildren();
			});
		}
		
		/**
		 * 	@private
		 */
		private function createChildren():void {
			
			// addChild(UIObjectFactory.CreateAsset('WindowBackground'));
			
			const factory:UIObjectFactory	= new UIObjectFactory(UIObjectStage);
			const root:UIObject				= factory.createInstance(); 
			stage.addChild(root);
			
			root.addChild(UIObjectFactory.CreateInstance('window', {
				top:	100,
				left:	100,
				right:	100,
				bottom:	100,
				title:	'HI MOM'
			}));
//			
//			root.addChild(UIObjectFactory.CreateInstance('window', {
//				top:	100,
//				left:	220,
//				width:	100,
//				height:	100,
//				title:	'HI MOM 2'
//			}));
		}
	}
}