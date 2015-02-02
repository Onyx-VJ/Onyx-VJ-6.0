package onyx.ui.core {
	
	import flash.display.*;
	import flash.events.*;
	import flash.utils.*;
	
	import onyx.ui.component.*;
	import onyx.ui.factory.*;
	import onyx.util.*;
	
	final public class UIStage extends UIContainer {
		
		/**
		 * 	@private
		 */
		private const background:Shape	= new Shape();
		
		/**
		 * 	@private
		 */
		private var modal:UIModalWindow;
		
		/**
		 * 	@private
		 */
		private var minWidth:int		= 500;

		/**
		 * 	@private
		 */
		private var minHeight:int		= 375;
		
		/**
		 * 	@private
		 */
		private const invalid:Array		= [];
		
		/**
		 * 	@private
		 */
		private const hash:Dictionary	= new Dictionary(true);
		
		/**
		 * 	@public
		 */
		public function UIStage():void {
			this.tabChildren	= false;
			this.tabEnabled		= false;
			this.name			= 'STAGE';
		}
		
		/**
		 * 	@public
		 */
		public function setBounds(x:int, y:int, width:int, height:int):void {
			
			const g:Graphics	= background.graphics;
			g.clear();
			g.beginFill(0x333333);
			g.drawRect(0,0,stage.stageWidth, stage.stageHeight);
			g.endFill();
			
			// measure?
			measure(bounds = new UIRect(x, y, width, height));
			
		}
		
		/**
		 * 	@public
		 */
		override public function initialize(data:Object):void {
			
			// add
			// stage.addChildAt(background, 0);

			// cache
			// background.cacheAsBitmap = true;
			
			data.constraint	= {
				type:	'relative',
				top:	8,
				left:	8,
				bottom:	8,
				right:	8
			}
			
			// unserialize the constraint
			super.initialize(data);
			
			// add listener
			stage.addEventListener(Event.RESIZE, resize);
			
			// resize
			resize();
			
		}
		
		/**
		 * 	@public
		 */
		override public function get application():UIStage {
			return this;
		}
		
		/**
		 * 	@public
		 */
		public function createModalDialog(dialogFactory:IFactory, width:int, height:int):UIObject {
			
			if (modal) {
				return null;
			}
			
			stage.addChild(modal = new UIModalWindow());
			modal.init();
			
			var dialog:UIObject = dialogFactory.createInstance({
				constraint: {
					type:	'absolute',
					bounds:		[
						(bounds.width	* .5 - width	* .5),
						(bounds.height	* .5 - height	* .5),
						width,
						height
					].join(',')
				}
			}) ;
			
			modal.addChild(dialog);
			dialog.measure(bounds);
			
			return dialog;
		}
		
		/**
		 * 	@public
		 */
		public function destroyModal():void {
			if (modal) {
				modal.dispose();
				stage.removeChild(modal);
				modal = null;
			}
		}
		
		/**
		 * 	@public
		 */
		public function getWindow(id:String):UIObject {
			var target:UIObject = getChildByName(id) as UIObject;
			if (target is UIWindow) {
				return (target as UIWindow).content;
			}
			return target;
		}
		
		/**
		 * 	@public
		 */
		public function invalidate(callback:Callback):void {
			
			if (hash[callback.method] === undefined) {
				invalid.push(callback);
				hash[callback.method]	= true;
			}
			
			stage.addEventListener(Event.RENDER,		handleInvalidate);
			stage.addEventListener(Event.ENTER_FRAME,	handleInvalidate);
			stage.invalidate();
		}
		
		/**
		 * 	@private
		 */
		private function handleInvalidate(e:Event):void {
			
			const length:uint		= invalid.length;
			const children:Array	= invalid.splice(0, length);
			
			for each (var child:Callback in children) {
				delete hash[child.method];
				child.exec();
			}
			
			if (!invalid.length) {
				stage.removeEventListener(Event.ENTER_FRAME, handleInvalidate);
				stage.removeEventListener(Event.RENDER, handleInvalidate);
			}
		}
		
		/**
		 * 	@private
		 */
		private function resize(e:* = null):void {
			
			setBounds(0, 0, stage.stageWidth, stage.stageHeight);
			
		}
	}
}