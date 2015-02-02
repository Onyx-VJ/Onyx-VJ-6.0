package onyx.display {
	
	final public class LayerTime {
		
		/**
		 * 	@private
		 * 	The loop beginning point
		 */
		public var playStart:Number					= 0.0;
		
		/**
		 * 	@private
		 * 	The loop ending point
		 */
		public var playEnd:Number					= 1.0;
		
		/**
		 * 	The framerate
		 */
		public var playSpeed:Number					= 1.0;
		
		/**
		 * 	@private
		 */
		public var playDirection:Number				= 1.0;
		
		/**
		 * 	The actual time (not 0-1);
		 */
		public var actualTime:Number				= 0.0;
		
		/**
		 * 	The total time in seconds
		 */
		public var totalTime:Number					= 0;

	}
}