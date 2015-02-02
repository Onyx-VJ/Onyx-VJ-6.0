package onyxui.parameter {
	
	import flash.display.*;
	import flash.events.*;
	import flash.geom.Rectangle;
	import flash.utils.*;
	
	import onyx.core.*;
	import onyx.event.*;
	import onyx.parameter.*;
	import onyx.util.*;
	
	import onyxui.core.*;

	public class UIParameter extends UIObject {

		/**
		 * 	@private
		 */
		private static const ACTIVE_CONTROLS:Dictionary	= new Dictionary(true);
		
		/**
		 * 	@private
		 */
		public static function show():Vector.<UIParameter> {
			
			const controls:Array = [];
			
			for (var i:Object in ACTIVE_CONTROLS) {
				var control:UIParameter			= i as UIParameter;
				if (control) {
					control.highlightForBind(true);
					controls.push(control);
				}
			}
			return Vector.<UIParameter>(controls);
		}
		
		/**
		 * 	@public
		 */
		public static function hide():void {
			for (var i:Object in ACTIVE_CONTROLS) {
				var control:UIParameter		= i as UIParameter;
				control.highlightForBind(false);
			}
		}

		/**
		 * 	@protected
		 */
		protected var parameter:Parameter;
		
		/**
		 * 	@protected
		 */
		protected const bounds:Rectangle	= new Rectangle();
		
		/**
		 * 	@public
		 */
		public function UIParameter():void {
			
			// delete
			ACTIVE_CONTROLS[this] = 1;
			
			// watch gc
			CONFIG::DEBUG { GC.watch(this); }
			
		}
		
		/**
		 * 	@protected
		 */
		protected function highlightForBind(show:Boolean):void {
			
			if (show) {
				
				var overlay:DisplayObject	= getChildByName('overlay') || addChild(new UIParameterOverlay(parameter));
				overlay.width				= bounds.width + 1;
				overlay.height				= bounds.height;
				
			} else {
				
				overlay						= getChildByName('overlay');
				if (overlay && contains(overlay)) {
					removeChild(overlay);
					(overlay as IControlParameterProxy).dispose();
				}
			}
		}
		
		/**
		 * 	@public
		 */
		public function showLabel():Boolean {
			return true;
		}

		/**
		 * 	@public
		 */
		public function attach(param:Parameter):void {
			
			CONFIG::DEBUG {
				if (parameter) {
					throw new Error('Already has a parameter!');
				}
			}
			
			if (param) {
				
				// bind
				parameter = param;
				parameter.listen(update, true);
				
				// update
				update();
			}
		}
		
		/**
		 * 	@public
		 */
		final public function getDisplayName():String {
			return parameter ? parameter.name : 'NOT DEFINED';
		}
		
		/**
		 * 	@public
		 */
		public function update(e:ParameterEvent = null):void {}
		
		/**
		 * 	@public
		 */
		override public function resize(width:int, height:int):void {
			bounds.width	= width;
			bounds.height	= height;
		}
		
		/**
		 * 	@public
		 */
		override public function dispose():void {
			
			// parameter
			if (parameter) {
				parameter.listen(update, false);
			}
			
			// release
			delete ACTIVE_CONTROLS[this];

		}
	}
}