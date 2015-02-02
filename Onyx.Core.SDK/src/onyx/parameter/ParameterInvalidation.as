package onyx.parameter {
	
	public final class ParameterInvalidation {
		
		/**
		 * 	@public
		 */
		public var parameter:IParameter;
		
		/**
		 * 	@public
		 */
		public var previousValue:*;
		
		/**
		 * 	@public
		 */
		public function ParameterInvalidation(parameter:IParameter, previousValue:*):void {
			this.parameter		= parameter;
			this.previousValue	= previousValue;
		}
	}
}