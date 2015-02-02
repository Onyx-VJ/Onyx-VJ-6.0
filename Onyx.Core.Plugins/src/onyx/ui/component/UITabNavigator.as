package onyx.ui.component {
	
	import flash.events.MouseEvent;
	
	import onyx.ui.core.*;
	import onyx.ui.factory.*;
	import onyx.util.Callback;
	
	use namespace skinPart;
	
	public class UITabNavigator extends UIContainer {
		
		/**
		 * 	@private
		 */
		private const tabFactory:UIFactory	= new UIFactory(UITab);
		
		/**
		 * 	@private
		 */
		skinPart var content:UISkin;
		
		/**
		 * 	@private
		 */
		private var selected:UIObject;
		
		/**
		 * 	@private
		 */
		private var factories:Object;
		
		/**
		 * 	@protected
		 */
		protected function createTabs(... factories:Array):void {
			
			this.factories	= {
			};
			
			var x:int		= 0;
			var w:int		= 70;
			
			var first:UIFactory;

			for each (var definition:Object in factories) {
				
				this.factories[definition.title] = definition.factory;
				
				var tab:UITab			= addChild(
					tabFactory.createInstance({
						label:		definition.title,
						factory:	definition.factory,
						constraint:	{
							type:	'absolute',
							bounds:	x + ',0,' + w + ',18'
						}
					})
				) as UITab;
				
				if (!first) {
					first = definition.factory;
				}
				tab.addEventListener(MouseEvent.CLICK, handleClick, true, 10, true);
				
				x += w + 2;
			}
			
			setSelected(first);
		}
		
		private function handleClick(e:MouseEvent):void {
			var tab:UITab			= e.currentTarget as UITab;
			setSelected(factories[tab.label.text]);
		}
		
		/**
		 * 	@public
		 */
		public function setSelected(factory:UIFactory):void {
			
			if (selected && contains(selected)) {
				selected.dispose();
				removeChild(selected);
				selected = null;
			}
			
			if (!factory) {
				return;
			}
			
			selected = addChild(factory.createInstance()) as UIObject;
			
			// invalidate
			invalidateChildren();
		}
		
		/**
		 * 	@public
		 */
		override public function arrange(rect:UIRect):void {
			
			// arrange
			super.arrange(rect);
			if (selected) {
				selected.measure(rect.identity());
			}
		}
	}
}