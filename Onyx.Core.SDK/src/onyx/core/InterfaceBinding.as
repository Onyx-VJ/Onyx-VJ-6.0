package onyx.core {
	
	final public class InterfaceBinding {
		
		/**
		 * 	@public
		 */
		public var origin:IPluginModuleInterface;
		
		/**
		 * 	@public
		 */
		public var key:uint;
		
		/**
		 * 	@public
		 */
		public function InterfaceBinding(origin:IPluginModuleInterface = null, key:uint = 0x00):void {
			this.origin	= origin;
			this.key	= key;
		}
		
		/**
		 * 	@public
		 */
		public function serialize(options:uint = 0xFFFFFFFF):Object {
			return {
				id: 	origin.id,
				key:	'0x' + key.toString(16)
			}
		}
		
		/**
		 * 	@public
		 */
		public function unserialize(token:*):void {
			if (token) {
				origin	= Onyx.GetModule(token.id) as IPluginModuleInterface;
				key		= token.key;
			}
		}
		
		/**
		 * 	@final
		 */
		final public function unbind():void {
			if (origin) {
				origin.unbind(key);
			}
		}
		
		/**
		 * 	@final
		 */
		final public function bind(data:*):void {
			if (origin) {
				origin.bind(key, data);
			}
		}
		
		/**
		 * 	@public
		 */
		public function toString():String {
			return (origin ? origin.formatMessage(key) : '');
		}
	}
}