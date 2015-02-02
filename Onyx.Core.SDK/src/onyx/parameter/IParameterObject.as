package onyx.parameter {
	
	import flash.events.*;
	
	import onyx.parameter.*;
	
	public interface IParameterObject extends IParameter {
		
		/**
		 * 	@public
		 */
		function getChildParameters():Vector.<IParameter>;
		
	}
}