package onyx.module.midi {
	
	import onyx.parameter.*;
	
	public final class MidiIteratorBinding implements IMidiBinding {

		/**
		 * 	@public
		 */
		private var parameter:IParameterIterator;
		
		/**
		 * 	@public
		 */
		public function MidiIteratorBinding(parameter:IParameterIterator):void {
			this.parameter = parameter;
		}
		
		/**
		 * 	@public
		 */
		public function exec(value:Number):void {
			var iter:* = parameter.iterator;
			if (iter.length > 0) {
				parameter.value = iter[uint(value * (iter.length - 1))];
			} 
		}
		
		/**
		 * 	@public
		 */
		public function dispose():void {
			
			parameter.bindInterface(null);
			
		}
	}
}