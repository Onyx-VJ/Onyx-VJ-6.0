package onyxui.core {
	
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	
	import onyx.core.IDisposable;
	
	import onyxui.assets.*;
	import onyxui.core.*;
	
	public class UIScrollPane extends UIObject {
		
		/**
		 * 	@private
		 */
		protected const scroll:UIScrollBar			= new UIScrollBar();;
		
		/**
		 * 	@private
		 */
		protected const holder:Sprite				= super.addChild(new Sprite()) as Sprite;
		
		/**
		 * 	@private
		 */
		protected const gridSize:Rectangle			= new Rectangle(0,0,100,75);
		
		/**
		 * 	@protected
		 */
		protected var reservedScrollWidth:Number	= 12;
		protected var scrollWidth:Number			= 10;
		protected var scrollPos:Number				= 0;

		/**
		 * 	@private
		 */
		protected const bounds:Rectangle			= new Rectangle();
		
		/**
		 * 	@private
		 */
		protected var content:Rectangle;
		
		/**
		 * 	@private
		 */
		protected var gap:int						= 2;
		
		/**
		 * 	@private
		 */
		protected var scrollV:Number				= 0;
		
		/**
		 * 	@protected
		 */
		protected const children:Array				= []; 
		
		/**
		 * 	@public
		 */
		override public function initialize():void {
			
			holder.x = holder.y = 4;
			
			addEventListener(MouseEvent.MOUSE_OVER, handleMouse);
				
		}
		
		/**
		 * 	@private
		 */
		private function handleMouse(event:Event):void {
			
		}
		
		/**
		 * 	@public
		 */
		public function signal(ratio:Number):void {
			scrollV = ratio;
			holder.scrollRect = new Rectangle(0, ratio * content.height, bounds.width, bounds.height);
		}
		
		/**
		 * 	@private
		 */
		protected function invalidate():void {}
		
		/**
		 * 	@publci
		 */
		final public function setGridSize(width:int, height:int):void {
			gridSize.width	= width;
			gridSize.height	= height;
			invalidate();
		}
		
		/**
		 * 	@private
		 */
		private function calculate(add:Boolean):void {

			var scrolling:Boolean	= super.contains(scroll);
			
			// contains scroll?
			if (scrolling && !add) {
				
				holder.scrollRect		= null;
				content = holder.getRect(null);
				
				if (content.height <= bounds.height) {
					scroll.setRatio(1 - ((content.height - bounds.height) / content.height), scrollV);
					super.removeChild(scroll);
				} else {
					holder.scrollRect	= new Rectangle(0, scrollV * content.height, bounds.width, bounds.height)
				}
				
			} else if (add && !scrolling) {
				
				holder.scrollRect		= null;
				content = holder.getRect(null);
				
				if (content.height > bounds.height) {
					holder.scrollRect	= new Rectangle(0, scrollV * content.height, bounds.width, bounds.height);
					scroll.setRatio(1 - ((content.height - bounds.height) / content.height), scrollV);
					super.addChild(scroll);
				}
			}
		}

		/**
		 * 	@public
		 */
		override public function resize(width:int, height:int):void {
			
			scroll.resize(scrollWidth, height);
			scroll.moveTo(width - scrollWidth + scrollPos, 0);
			
			bounds.width	= width - reservedScrollWidth;
			bounds.height	= height;
			
			// invalidate all the children
			invalidate()
			
		}

		/**
		 * 	@public
		 */
		override public function addChild(child:DisplayObject):DisplayObject {
			
			var itemsPerRow:int	= bounds.width / (gridSize.width + gap);
			var obj:UIObject	= child as UIObject;
			var index:int		= holder.numChildren;
			
			obj.moveTo((index % itemsPerRow) * (gridSize.width + gap), Math.floor(index / itemsPerRow) * (gridSize.height + gap));
			obj.resize(gridSize.width, gridSize.height);
			
			holder.addChild(child);
			children.push(child);
			
			calculate(true);
		
			return child;
		}
		
		/**
		 * 	@public
		 */
		public function remChildren():void {
			while (holder.numChildren) {
				var d:IDisposable = holder.removeChildAt(0) as IDisposable;
				if (d) {
					d.dispose();
				}
			}
			
			children.splice(0, children.length);
			
			// calculate
			calculate(false);
		}
		
		/**
		 * 	@public
		 */
		public function getChildren():Array {
			return children;
		}
		
		/**
		 * 	@public
		 */
		override public function removeChild(child:DisplayObject):DisplayObject {
			
			holder.removeChild(child);
			
			calculate(false);
			
			return child;
		}
	}
}