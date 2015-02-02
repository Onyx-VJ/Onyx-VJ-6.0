package onyx.core {
	
	import flash.events.*;
	
	import onyx.core.*;
	import onyx.parameter.*;
	import onyx.plugin.*;
	
	public interface IChannel extends IPlugin {
		
		/**
		 * 	@public
		 * 	Adds a filter
		 */
		function addFilter(instance:IPluginFilter):Boolean;
		
		/**
		 * 	@public
		 * 	Removes a filter
		 */
		function removeFilter(instance:IPluginFilter):Boolean;
		
		/**
		 * 	@public
		 * 	Swaps filter indices
		 */
		function swapFilters(a:IPluginFilter, b:IPluginFilter):Boolean;
		
		/**
		 * 	@public
		 * 	Returns the index for a specified filter
		 */
		function getFilterIndex(filter:IPluginFilter):int;
		
		/**
		 * 	@public
		 * 	Returns all filters
		 */
		function getFilters():Vector.<IPluginFilter>;
		
		/**
		 * 	@public
		 * 	Clears and disposes all the filters
		 */
		function clearFilters():void;

	}
}