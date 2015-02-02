package onyx.display {
	
	import flash.geom.*;
	
	import onyx.core.*;
	
	public interface ILayerRenderMode {
				
		/**
		 * 	@publci
		 */
		function getChannel():IChannel;
		
		/**
		 * 	@public
		 */
		function getGenerator():IPluginGenerator;
		
		/**
		 * 	@public
		 */
		function setBlendMode(value:IPlugin):Boolean;
		
		/**
		 * 	@public
		 */
		function getBlendMode():IPlugin;
		
		/**
		 * 	@public
		 */
		function render():Boolean;
		
		/**
		 *	@public
		 */
		function clearFilters():void;
		
		/**
		 * 	@public
		 */
		function get type():uint;
		
		/**
		 * 	@public
		 */
		function draw(transform:ColorTransform):Boolean;
		
		/**
		 * 	@public
		 */
		function update(time:Number):Boolean;
		
		/**
		 * 	@public
		 */
		function getTotalTime():int;
		
		/**
		 * 	@public
		 */
		function dispose():void;
		
		/**
		 * 	@public
		 */
		function serialize(options:uint = 0xFFFFFFFF):Object;
		
		/**
		 * 	@public
		 */
		function unserialize(token:Object):void;
		
		/**
		 * 	@public
		 */
		function updateChannelName():void;
	}
}