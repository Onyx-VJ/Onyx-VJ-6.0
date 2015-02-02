package onyx.host.swf {

	/**
	 * 	@dynamic!
	 */
	dynamic public class PluginSWFDefinition {
		
		/**
		 * 	@public
		 */
		public var id:String;
		
		/**
		 * 	@public
		 */
		public var type:String;
		
		/**
		 * 	@public
		 */
		public var target:String;
		
		/**
		 * 	@public
		 */
		public var children:Vector.<PluginSWFDefinition>;
		
		/**
		 * 	@constructor
		 */
		public function PluginSWFDefinition(id:String = null, type:String = null, target:String = null, alt:Object = null):void {

			this.id			= id;
			this.type		= type;
			this.target		= target;

			if (alt) {
				for (var i:String in alt) {
					this[i] = alt[i];
				}
			}
		}

		/**
		 * 	@public
		 */
		CONFIG::DEBUG public function toString():String {
			var out:String = '[ParameterDef id=' + id + ', target=' + target + ', type=' + type;
			for (var i:String in this) {
				out += ' ' + i + '=' + this[i];
			}
			return out + ']';
		}
	}
}