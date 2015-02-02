package onyx.module.midi {
	
	import onyx.parameter.*;
	
	public final class MidiNumericBinding implements IMidiBinding {

		/**
		 * 	@public
		 */
		private var parameter:IParameterNumeric;
		
		/**
		 * 	@public
		 */
		public function MidiNumericBinding(parameter:IParameterNumeric):void {
			this.parameter = parameter;
		}
		
		/**
		 * 	@public
		 */
		public function exec(value:Number):void {
			var max:Number	= parameter.max;
			var min:Number	= parameter.min;
			parameter.value = min + ((max - min) * value); 
		}
		
		/**
		 * 	@public
		 */
		public function dispose():void {
			parameter.bindInterface(null);
		}
	}
}