package onyx.ui.parameter {
	
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.text.*;
	
	import onyx.core.*;
	import onyx.event.*;
	import onyx.parameter.*;
	import onyx.ui.core.*;
	import onyx.ui.factory.*;
	import onyx.ui.renderer.*;
	
	final public class UIParameterDropDown extends UIParameterDisplayBase implements IUIParameter {
		
		/**
		 * 	@private
		 */
		private const selectionFactory:UIFactory 						= new UIFactory(UIParameterDropDownSelection);

		/**
		 * 	@private
		 */
		private var target:Object;
		
		/**
		 * 	@private
		 */
		private var renderer:UIFactory;
		
		/**
		 * 	@private
		 */
		private var selected:UIRenderer;
		
		/**
		 * 	@private
		 */
		private var selection:UIParameterDropDownSelection;
		
		/**
		 * 	@public
		 */
		override public function initialize(data:Object):void {
			
			// initialize
			super.initialize(data);
			
			switch (data.renderType) {
				case 'icon':
					renderer		= new UIFactory(UIRendererIcon);
					break;
				default:
					renderer		= new UIFactory(UIRendererText, { textAlign: data.textAlign });
					break;
			}
			
			buttonMode		= useHandCursor = true;
			
			addEventListener(MouseEvent.MOUSE_DOWN,			handleMouse);
			addEventListener(MouseEvent.MOUSE_OVER,			handleMouse);
			addEventListener(MouseEvent.MOUSE_OUT,			handleMouse);
			addEventListener(MouseEvent.RIGHT_CLICK,		handleMouse);
			
			// add selected
			addChild(selected = renderer.createInstance());
		}
		
		/**
		 * 	@private
		 */
		private function handleMouse(event:MouseEvent):void {
			
			const parameter:IParameterIterator = this.parameter as IParameterIterator;
			if (!parameter) {
				return;
			}
			
			event.stopPropagation();

			var index:int, currentIndex:int;
			
			switch (event.type) {
				case MouseEvent.MOUSE_OVER:
					
					stage.addEventListener(MouseEvent.MOUSE_WHEEL,		handleMouse);
					
					return;
					
				case MouseEvent.MOUSE_OUT:
					
					stage.removeEventListener(MouseEvent.MOUSE_WHEEL,	handleMouse);
					
					return;
					
				case MouseEvent.MOUSE_WHEEL:
					
					var iterator:*	= parameter.iterator;
					
					currentIndex	= parameter.currentIndex;
					if (event.delta > 0 && currentIndex > 0) {
						parameter.value = iterator[currentIndex - 1];
					} else if (event.delta < 0 && currentIndex < iterator.length - 1) {
						parameter.value = iterator[currentIndex + 1];
					}
					
					break;
				case MouseEvent.RIGHT_CLICK:
					
					this.parameter.reset();
					
					break;
				case MouseEvent.MOUSE_DOWN:
					
					stage.addEventListener(MouseEvent.MOUSE_UP, handleMouse);
					
					iterator = parameter.iterator;
					
					const rect:Rectangle	= this.getRect(stage);
					index					= parameter.currentIndex;
					
					// resize the selection
					stage.addChild(selection = selectionFactory.createInstance());
					
					var size:int				=  Math.max(bounds.width, 120);
					
					// move it
					selection.arrange(new UIRect(rect.x - (size * 0.5 - bounds.width * .5) - 1, rect.y -(index * bounds.height) - 1, size, iterator.length * bounds.height + 2));
					
					// set the data
					selection.show(parameter, renderer);
					
					break;
				case MouseEvent.MOUSE_UP:
					
					iterator = parameter.iterator;
					
					index					= selection.getSelectedIndex();
					currentIndex			= parameter.currentIndex;
					
					if (index !== -1 && index !== currentIndex && index < iterator.length) {
						var value:*		= iterator[index];
						parameter.value = value;
					}
					
					stage.removeEventListener(MouseEvent.MOUSE_UP, handleMouse);
					
					if (stage.contains(selection)) {
						stage.removeChild(selection);
					}
					
					break;
			}
		}
		
		/**
		 * 	@public
		 */
		override public function update():void {
			selected.update(parameter as IParameterIterator, parameter.value)
		}
		
		/**
		 * 
		 */
		override public function arrange(rect:UIRect):void {
			
			super.arrange(rect);
			
			if (selected) {
				selected.arrange(rect.identity());
			}
		}
		
		/**
		 * 	@public
		 */
		override public function dispose():void {
			
			removeEventListener(MouseEvent.MOUSE_DOWN,			handleMouse);
			removeEventListener(MouseEvent.MOUSE_OVER,			handleMouse);
			removeEventListener(MouseEvent.MOUSE_OUT,			handleMouse);
			removeEventListener(MouseEvent.RIGHT_CLICK,			handleMouse);
			
			stage.removeEventListener(MouseEvent.MOUSE_UP,		handleMouse);
			stage.removeEventListener(MouseEvent.MOUSE_WHEEL,	handleMouse);
			
			// remove
			super.dispose();

		}
	}
}