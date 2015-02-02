package onyxui.interaction {
	
	import flash.events.*;
	import flash.geom.*;
	import flash.utils.*;
	
	import onyx.util.*;
	
	import onyxui.core.*;
	import onyxui.event.*;
	
	/**
	 * 	@public
	 */
	final public class Interaction {
		
		public static const LEFT_DOWN:int			= 0;		// mouse down, stage.move/up
		public static const LEFT_DRAG:int			= 1;		// mouse down, stage.move/up
		public static const LEFT_CLICK:int			= 2;		// double only
		public static const LEFT_DOUBLE:int			= 3;		// double only
		public static const RIGHT_CLICK:int			= 4;		// right click only
		public static const RIGHT_DOUBLE:int		= 5;		// right click double
		public static const WHEEL:int				= 6;		// mouse over, stage.wheel, stage.mouseup
		
		/**
		 * 	@private
		 */
		private static const Interactions:Vector.<IInteraction> = Vector.<IInteraction>([
			new InteractionClick(MouseEvent.MOUSE_DOWN,			LEFT_DOWN),
			new InteractionDrag(),
			new InteractionClick(MouseEvent.CLICK,				LEFT_CLICK),
			new InteractionClick(MouseEvent.DOUBLE_CLICK,		LEFT_DOUBLE),
			new InteractionClick(InteractionEvent.RIGHT_CLICK,	RIGHT_CLICK),
			new InteractionClick(InteractionEvent.RIGHT_CLICK,	RIGHT_DOUBLE),
			new InteractionWheel(),
		]);
		
		/**
		 * 	@private
		 */
		internal static const Bindings:Dictionary	= new Dictionary(true);
		
		/**
		 * 	@private
		 * 	TODO: make a different target for every interaction type
		 */
		private static var currentTarget:UIObject;
		
		/**
		 * 	@private
		 */
		private static var currentAction:String;
		
		/**
		 * 	@private
		 */
		private static var currentCallback:Function;
		
		/**
		 * 	@private
		 */
		private static var lastDown:int;

		/**
		 * 	@publci
		 */
		public static function Bind(target:UIObject, callback:Function, ... types:Array):void {
			
			const binding:InteractionBinding	= new InteractionBinding();
			binding.types						= Vector.<int>(types);
			binding.callback					= callback;
			
			// loopy
			for each (var type:String in types) {
				Interactions[type].bind(target);
			}
			
			Bindings[target]					= binding;
		}
		
		
		/**
		 * 	@public
		 */
		public static function Unbind(target:UIObject):void {
			
			var binding:InteractionBinding = Bindings[target];
			for each (var type:int in binding.types) {
				Interactions[type].unbind(target);
			}
			
			delete Bindings[target];
		}
	}
}
