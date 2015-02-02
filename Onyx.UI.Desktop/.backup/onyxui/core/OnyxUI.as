/**
 *	This is the base root container
 */
package onyxui.core {
	
	import avmplus.*;
	
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.utils.*;
	
	import onyx.core.*;
	import onyx.host.*;
	import onyx.plugin.*;
	import onyx.util.*;
	import onyx.util.metadata.*;
	
	import onyxui.component.*;
	import onyxui.factory.*;
	
	[PluginInfo(
		type		= 'container',
		top			= '10',
		left		= '10',
		bottom		= '10',
		right		= '10'
	)]

	final public class OnyxUI extends UIContainer {
		
		/**
		 * 	@private 
		 */
		private static const META_CACHE:Dictionary		= new Dictionary();
		
		/**
		 * 	@private
		 */
		private static const METADATA_DEF:Object		= {
			'UISkinPart':	MetaDataUtil.NAMED_OBJECT,
			'PluginInfo':	MetaDataUtil.MERGED
		};

		/**
		 * 	@public
		 */
		public static function GetMetaData(c:Class):Object {
			return META_CACHE[c] || CacheMetaData(c);
		}
		
		/**
		 * 	@private
		 */
		private static function CacheMetaData(c:Class):Object {
			return META_CACHE[c] = MetaDataUtil.Merge(describeClass(c).metadata, METADATA_DEF);
		}
		
		/**
		 * 	@public
		 */
		override protected function initialize():void {
			
			// set boudns to stage bounds
			arrange(constraint.measure(new Rectangle(0,0,stage.stageWidth, stage.stageHeight)));


		}
		
		override public function arrange(rect:Rectangle):void {
			super.arrange(rect);
		}
		
		/**
		 * 	@private
		 */
		private function resize(e:Event):void {
		}
	}
}