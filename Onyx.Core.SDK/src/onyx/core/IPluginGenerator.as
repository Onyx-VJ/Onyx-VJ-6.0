package onyx.core {
	
	import flash.display.*;
	import flash.geom.*;
	
	import onyx.core.*;
	import onyx.display.*;
	import onyx.parameter.*;
	import onyx.plugin.*;
	
	public interface IPluginGenerator extends IPlugin {
		
		/**
		 * 	@public
		 */
		function getFile():IFileReference;
		
		/**
		 * 	@public
		 */
		function getChannel():IChannel;
		
		/**
		 * 	@public
		 */
		function getDimensions():Dimensions;
		
		/**
		 * 	@public
		 * 	Time passed in is value of 0 to 1.
		 */
		function update(time:Number):Boolean;

		/**
		 * 	@public
		 * 	Returns the total time in milliseconds
		 */
		function getTotalTime():int;

	}
}