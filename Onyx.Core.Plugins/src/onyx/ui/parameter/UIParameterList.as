package onyx.ui.parameter {
	
	import flash.display.*;
	
	import onyx.core.*;
	import onyx.parameter.*;
	import onyx.ui.component.*;
	import onyx.ui.core.*;
	import onyx.ui.factory.*;
	import onyx.util.Callback;
	
	[UIComponent(id='parameterList')]
	
	final public class UIParameterList extends UIContainer {
		
		/**
		 * 	@private
		 */
		private var list:ParameterList;
		
		/**
		 * 	@public
		 */
		public function clear():void {
			
			while (numChildren) {
				var disposable:IDisposable = getChildAt(0) as IDisposable;
				if (disposable) {
					disposable.dispose();
				}
				removeChildAt(0);
			}
		}
			
		/**
		 * 	@public
		 */
		public function attach(parameters:ParameterList):void {
			
			// clear
			clear();
			
			// valid parameters?
			if (!parameters) {
				return;
			}
			
			// loop
			const iter:Vector.<IParameter> = parameters.iterator;
			for each (var parameter:IParameter in iter) {
				if (parameter.isHidden()) {
					continue;
				}
				var control:UIParameter = UIFactoryDefinitions.CreateInstance('parameter', { showLabel: true });
				if (control) {
					addChild(control);
					control.attach(parameter);
				}
			}
			
			// arrange
			application.invalidate(new Callback(arrangeChildren));
		}
		
		/**
		 * 	@public
		 */
		override public function arrangeChildren():void {
			
			var rect:UIRect = new UIRect(0, 0, bounds.width, 16);
			for (var count:int = 0; count < numChildren; ++count) {
				var component:UIParameter = getChildAt(count) as UIParameter;
				
				CONFIG::DEBUG if (!component) {
					throw new Error('NOT A COMPONENT!');
				}
				
				component.arrange(rect);
				
				rect.y += component.controlHeight;
			}
		}
	}
}