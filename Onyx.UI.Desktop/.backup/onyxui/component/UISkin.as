package onyxui.component {
	
	import flash.display.*;
	import flash.geom.*;
	
	import onyx.plugin.*;
	import onyx.util.*;
	
	import onyxui.core.*;
		
	public class UISkin extends UIObject {
		
		/**
		 * 	@private
		 */
		protected var mc:MovieClip;
		
		/**
		 * 	@public
		 */
		override public function unserialize(token:Object):void {
			
			// top left right bottom
			constraint.unserialize(token);
			
			// add a skin?
			if (token.skin) {
				var c:Class	= PluginDomain.getDefinition(token.skin) as Class;
				addChild(mc = new c()); 
			}
		}
		
		/**
		 *	@public 
		 */
		override public function arrange(rect:Rectangle):void {
			
			super.arrange(rect);
			
			if (mc && rect.width && rect.height) {
				mc.width	= rect.width;
				mc.height	= rect.height;
			}
		}
	}
}