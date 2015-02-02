package onyx.ui.factory {
	
	import flash.events.Event;
	
	import onyx.ui.component.*;
	import onyx.ui.core.*;
	import onyx.util.encoding.*;
	
	use namespace skinPart;
	
	public final class UIFactoryWindow extends UIFactory implements IFactory {
		
		/**
		 * 	@private
		 */
		private const windowFactory:UIFactory	= new UIFactory(UIWindow);
		
		/**
		 * 	@public
		 */
		public function UIFactoryWindow(definition:Class):void {
			super(definition);
		}
		
		/**
		 * 	@public
		 */
		override public function createInstance(token:Object = null):* {
			
			const window:UIWindow	= windowFactory.createInstance({
				constraint:	data.constraint,
				title:		data.title
			});
			
			window.name		= data.id;
			window.addEventListener(Event.ADDED_TO_STAGE, handleWindowInit, false, -1);
			
			return window;
		}
		
		/**
		 * 	@private
		 */
		private function handleWindowInit(e:Event):void {
			const window:UIWindow	= e.currentTarget as UIWindow;
			window.removeEventListener(Event.ADDED_TO_STAGE, handleWindowInit);
			window.addChild(super.createInstance({
				constraint:	{
					type:	'relative',
					top:	20,
					left:	4,
					right:	4,
					bottom:	4
				}
			}));
		}
	}
}