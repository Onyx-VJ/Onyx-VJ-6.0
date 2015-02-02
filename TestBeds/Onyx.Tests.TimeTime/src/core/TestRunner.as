package core {
	
	public final class TestRunner {
		
		public var name:String;
		public var method:Function;
		public var args:Array;
		public var iterations:int;
		
		public const tested:Array	= [];
		
		/**
		 * 	@public
		 */
		public function TestRunner(name:String, iterations:int, method:Function, ... args:Array):void {
			this.name		= name;
			this.iterations	= iterations;
			this.method		= method;
			this.args		= args.length ? args : null;
		}
	}
}