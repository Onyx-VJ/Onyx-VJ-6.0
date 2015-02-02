package onyx.parameter {
	
	public interface IParameterIterator extends IParameter {
		
		/**
		 * 	@public
		 * 	Formats the object
		 */
		function format(value:*):String;
		
		/**
		 * 	@public
		 */
		function get currentIndex():int;
		
		/**
		 * 	@public
		 * 	Gets the list of stuff
		 */
		function get iterator():*;
		
	}
}