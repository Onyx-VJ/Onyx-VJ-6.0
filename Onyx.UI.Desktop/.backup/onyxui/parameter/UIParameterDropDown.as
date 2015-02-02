package onyxui.parameter {
	
	import flash.display.*;
	import flash.events.*;
	import flash.geom.Rectangle;
	import flash.text.*;
	
	import onyx.core.*;
	import onyx.event.*;
	import onyx.parameter.*;
	
	import onyxui.assets.*;
	import onyxui.core.*;
	import onyxui.event.*;
	import onyxui.renderer.*;

	
	final public class UIParameterDropDown extends UIParameter {
		
		/**
		 * 	@private
		 */
		private static const selection:UIParameterDropDownSelection = new UIParameterDropDownSelection();
		
		/**
		 * 	@private
		 */
		private var target:Object;
		
		/**
		 * 	@private
		 */
		private var renderer:Class;
		
		/**
		 * 	@private
		 */
		private var selected:UIRenderer;
		
		/**
		 * 	@public
		 */
		public function UIParameterDropDown(renderer:Class = null):void {
			this.renderer	= renderer || UIRendererText;
			this.selected	= new this.renderer();
			this.selected.x = 1;
			this.selected.y = 1;
			buttonMode = useHandCursor = true;
		}
		
		/**
		 * 	@public
		 */
		override public function initialize():void {
			
			addEventListener(MouseEvent.MOUSE_DOWN,		handleMouse);
			addEventListener(MouseEvent.MOUSE_OVER,		handleMouse);
			addEventListener(MouseEvent.MOUSE_OUT,		handleMouse);
			addEventListener(InteractionEvent.RIGHT_CLICK,	handleMouse);
			
			addChild(selected);

			// update
			update();
		
		}
		
		/**
		 * 	@private
		 */
		private function handleMouse(event:MouseEvent):void {
			
			const parameter:IParameterIterator = this.parameter as IParameterIterator;
			if (!parameter) {
				return;
			}
			
			const iterator:*	= parameter.iterator;

			var index:int, currentIndex:int;
			
			switch (event.type) {
				
				case MouseEvent.MOUSE_OVER:
					
					stage.addEventListener(MouseEvent.MOUSE_WHEEL,		handleMouse);
					return;
					
				case MouseEvent.MOUSE_OUT:
					
					stage.removeEventListener(MouseEvent.MOUSE_WHEEL,	handleMouse);
					return;
					
				case MouseEvent.MOUSE_WHEEL:
					currentIndex	= iterator.indexOf(parameter.value);
					if (event.delta > 0 && currentIndex > 0) {
						parameter.value = iterator[currentIndex - 1];
					} else if (event.delta < 0 && currentIndex < iterator.length - 1) {
						parameter.value = iterator[currentIndex + 1];
					}
					
					// set value
					selected.data = parameter.value;
					
					break;
				case InteractionEvent.RIGHT_CLICK:
					
					this.parameter.reset();
					
					break;
				case MouseEvent.MOUSE_DOWN:
					
					stage.addEventListener(MouseEvent.MOUSE_UP, handleMouse);
					
					const rect:Rectangle	= this.getRect(stage);
					index					= iterator.indexOf(parameter.value);
					
					// resize the selection
					stage.addChild(selection);
					selection.resize(bounds.width, iterator.length * bounds.height + 2);
					selection.moveTo(rect.x - 1, rect.y -(index * bounds.height) - 1);
					
					// set the data
					selection.show(parameter, renderer);

					
					break;
				case MouseEvent.MOUSE_UP:
					index					= selection.getSelectedIndex();
					currentIndex			= iterator.indexOf(parameter.value);
					
					if (index !== -1 && index !== currentIndex && index < iterator.length) {
						var value:*		= iterator[index];
						parameter.value = value;
						selected.data	= value;
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
		override public function resize(width:int, height:int):void {
			
			bounds.width	= width;
			bounds.height	= height;
			
			selected.resize(width, height);
		}
		
		/**
		 * 	@public
		 */
		override public function update(e:ParameterEvent = null):void {
			if (parameter) {
				selected.data = parameter.value;
			}
		}
		
		/**
		 * 	@public
		 */
		override public function dispose():void {
			
			removeEventListener(MouseEvent.MOUSE_DOWN,		handleMouse);
			removeEventListener(MouseEvent.MOUSE_UP,		handleMouse);
			
			// remove
			super.dispose();

		}
	}
}