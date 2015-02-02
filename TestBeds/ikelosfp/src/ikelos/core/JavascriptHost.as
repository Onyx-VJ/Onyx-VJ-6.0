package ikelos.core {

	import flash.events.Event;
	import flash.external.ExternalInterface;

	final public class JavascriptHost {

		/**
		 * 	@private
		 */
		private var id:String;

		/**
		 * 	@private
		 */
		private const methods:Object	= {};

		/**
		 * 	@public
		 */
		public function initialize(id:String):Boolean {

			this.id	= id;

			// test for the container
			if (!ExternalInterface.available) {
				return false;
			}


			// try sending an initialization callback that we're ready
			try {

				CONFIG::DEBUG {
					Debug.Log('Adding host interface: callFromJS');
				}
				
				ExternalInterface.addCallback('callFromJS', this.handleJavascriptCall);

				// initialize!
				ExternalInterface.call('ikelos', 'call', this.id, 'handleFlashEvent', ['initialize', true]);

			} catch (e:Error) {
			
				CONFIG::DEBUG {
					Debug.Log(e.name, e.message);
				}
				
				return false;
			}

			// we were able to call successfully, go ahead and allow stuff to bind
			return true;
		}

		/**
		 * 	@public
		 */
		public function triggerEvent(e:Event):void {
			try {
				ExternalInterface.call('ikelos', 'call', this.id, 'handleFlashEvent', [e.type, null]);
			} catch (e:Error) {
				this.triggerError(e);
			}
		}
		
		/**
		 * 	@public
		 */
		public function triggerError(e:Error):void {
			
			CONFIG::DEBUG {
				Debug.Log('err:', e);
			}
		
			try {
				ExternalInterface.call('ikelos', 'call', this.id, 'handleError', [e.message, null]);
			} catch (e:Error) {
			}
		}

		/**
		 * 	@public
		 */
		public function triggerType(type:String, data:Object = null):void {
			try {
				ExternalInterface.call('ikelos', 'call', this.id, 'handleFlashEvent', [type, data]);
			} catch (e:Error) {
				this.triggerError(e);
			}
		}

		/**
		 * 	@private
		 */
		private function handleJavascriptCall(args:Array):* {

			var name:String			= args.shift();
			var callback:Function	= this.methods[name];
			if (callback === null) {
				CONFIG::DEBUG {
					Debug.Log('no method named:', name);
				}
				return null;
			}

			try {
				return callback.apply(null, args);
			} catch (e:Error) {
				CONFIG::DEBUG {
					Debug.Log(e.message);
				}
				return null;
			}
		}

		/**
		 * 	@public
		 */
		public function bind(name:String, method:Function):void {

			// fn
			this.methods[name] = method;

		}
	}
}
