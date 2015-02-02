package onyx.ui.component {
	
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	
	import onyx.core.*;
	import onyx.ui.core.*;
	import onyx.util.*;
	
	use namespace skinPart;
	
	[UIComponent(id='scrollPane')]
	
	[UISkinPart(id='scrollContent', type='scrollContent',	constraint='relative', left='0', right='10', top='0', bottom='0')]
	[UISkinPart(id='scroll',		type='scrollBar',		constraint='relative', right='0', top='0', bottom='0', width='10')]
	
	final public class UIScrollPane extends UIContainer {
		
		/**
		 * 	@private
		 */
		skinPart var scroll:UIScrollBar;
		
		/**
		 * 	@private
		 */
		skinPart var scrollContent:UIScrollContent;
		
		/**
		 * 	@private
		 */
		protected const gridSize:UIRect			= new UIRect(0,0,160,90);
		
		/**
		 * 	@protected
		 */
		protected var reservedScrollWidth:Number	= 12;
		protected var scrollWidth:Number			= 10;
		protected var scrollPos:Number				= 0;
		
		/**
		 * 	@private
		 */
		protected var contentRect:Rectangle;
		
		/**
		 * 	@private
		 */
		protected var gap:int						= 2;
		
		/**
		 * 	@private
		 */
		protected var scrollV:Number				= 0;
		
		/**
		 * 	@public
		 */
		override public function initialize(data:Object):void {
			
			// initialize
			super.initialize(data);
			
			// wheel
			scrollContent.addEventListener(MouseEvent.MOUSE_WHEEL, handleMouse);
			
			// invalidating
			invalidateContent();
		}
		
		/**
		 * 	@private
		 */
		private function handleMouse(event:MouseEvent):void {
			
			if (scrollContent.scrollRect) {
				signal(Math.max(Math.min(scrollV - (event.delta / 10), 1), 0));
				
				var height:int = 1 - ((contentRect.height - bounds.height) / contentRect.height);
				// scroll.setRatio(1, scrollV);
			}
		}
		
		/**
		 * 	@public
		 */
		public function signal(ratio:Number):void {
			
			if (!contentRect) {
				return;
			}
			
			scrollV						= ratio;
			scrollContent.scrollRect	= new Rectangle(0, ratio * contentRect.height, bounds.width, bounds.height);
			
		}
		
		/**
		 * 	@publci
		 */
		final public function setGridSize(width:int, height:int):void {
			
			// set grid size
			gridSize.width	= width;
			gridSize.height	= height;
			
			// invalidate the arrange
			invalidateContent();
		}
		
		/**
		 * 	@private
		 */
		private function calculate():void {
			
			var scrolling:Boolean		= scroll.visible;
			scrollContent.scrollRect	= null;
			
			// contains scroll?
			if (scrolling) {
				
				contentRect						= scrollContent.getRect(null);
				
				if (contentRect.height <= bounds.height) {
					scroll.setRatio(1 - ((contentRect.height - bounds.height) / contentRect.height), scrollV);
					scroll.visible				= false;
				} else {
					scrollContent.scrollRect	= new Rectangle(0, scrollV * contentRect.height, bounds.width, bounds.height)
				}
				
			} else if (!scrolling) {
				
				contentRect						= scrollContent.getRect(null);
				
				if (contentRect.height > bounds.height) {
					scrollContent.scrollRect	= new Rectangle(0, scrollV * contentRect.height, bounds.width, bounds.height);
					scroll.setRatio(1 - ((contentRect.height - bounds.height) / contentRect.height), scrollV);
					scroll.visible	= true;
				}
			}
		}

		/**
		 * 	@public
		 */
		override public function addChild(child:DisplayObject):DisplayObject {
			invalidateContent();
			return scrollContent.addChild(child);
		}
		
		/**
		 * 	@protected
		 */
		final protected function invalidateContent():void {
			application.invalidate(new Callback(updateScroll));
		}
		
		/**
		 * 	@private
		 */
		private function updateScroll():void {
			
			if (!bounds) {
				return application.invalidate(new Callback(updateScroll));
			}
			
			arrangeChildren();
			calculate();
		}
		
		/**
		 * 	@public
		 */
		override public function arrangeChildren():void {
			
			if (!bounds) {
				return;
			}
			
			var itemsPerRow:int	= bounds.width / (gridSize.width + gap);
			
			for (var count:int = 0; count < scrollContent.numChildren; ++count) {
				var content:UIObject = scrollContent.getChildAt(count) as UIObject;
				content.arrange(new UIRect((count % itemsPerRow) * (gridSize.width + gap), Math.floor(count / itemsPerRow) * (gridSize.height + gap), gridSize.width, gridSize.height));
			}
			
			scroll.measure(bounds);
			scrollContent.measure(bounds);
			
		}
		
		/**
		 * 	@public
		 */
		public function clearChildren():void {
			
			// destroy
			destroyChildren();
			
			// calculate
			invalidateContent();
		}
		
		/**
		 * 	@public
		 */
		override public function destroyChildren():void {
			
			const numChildren:int = scrollContent.numChildren;
			while (numChildren--) {

				var child:IDisposable	= scrollContent.getChildAt(0) as IDisposable;
				if (child) {
					child.dispose();
				}

				scrollContent.removeChildAt(0);
			}
		}
		
		/**
		 * 	@public
		 */
		override public function addSkinPart(id:String, item:IUIObject):void {
			this[new QName(skinPart, id)] = super.addChild(item as DisplayObject);
		}
		
		public function getChildren():Array {
			const children:Array = [];
			for (var count:int = 0; count < scrollContent.numChildren; ++count) {
				children.push(scrollContent.getChildAt(count));
			}
			return children;
		}
		
		/**
		 * 	@public
		 */
		override public function removeChild(child:DisplayObject):DisplayObject {
			invalidateContent();
			return scrollContent.removeChild(child);
		}
		
		/**
		 * 	@public
		 */
		override public function removeChildAt(index:int):DisplayObject {
			invalidateContent();
			return scrollContent.removeChildAt(index);
		}
	}
}
