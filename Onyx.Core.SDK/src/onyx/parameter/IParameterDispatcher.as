package onyx.parameter {
	
	public interface IParameterDispatcher extends IParameter {
		
		/**
		 * 	@public
		 */
		function dispatch(... args:Array):void;
		
	}
}