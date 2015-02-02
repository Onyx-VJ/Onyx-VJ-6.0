package onyx.plugin {
	
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	
	import onyx.core.*;
	import onyx.display.*;
	import onyx.event.*;
	import onyx.parameter.*;
	
	use namespace onyx_ns;
	use namespace parameter;
	
	// TODO
	// PUT THIS IN THE APPLICATION
	internal class PluginPatchBase extends Sprite {
		
		/**
		 * 	@protected
		 */
		protected var data:Object;
		
		/**
		 *	@public
		 */
		protected var file:IFileReference;

		/**
		 * 	@protected
		 */
		protected var parameters:ParameterList;
		
		/**
		 * 	@protected
		 */
		protected var invalid:Boolean				= true;
		
		/**
		 * 	@protected
		 */
		protected var content:Object;
		
		/**
		 * 	@protected
		 */
		private var invalidParameters:Object		= {};
		
		/**
		 * 	@protected
		 */
		protected const dimensions:Dimensions		= new Dimensions();
		
		/**
		 * 	@final
		 */
		final onyx_ns function setupParameters():void {
			
			var host:IPluginHost	= Onyx.GetPluginHost('swf');
			parameters				= new ParameterList(host.createParameters(this));
			
			// listen for changes
			for each (var parameter:IParameter in parameters.iterator) {
				
				// listen
				parameter.addEventListener(ParameterEvent.VALUE_CHANGE, parameterChange);
				
				// hmm
				invalidParameters[parameter.id] = parameter;
			}
			
			invalid = true;
		}
		
		/**
		 * 	@private
		 */
		final private function parameterChange(e:ParameterEvent):void {
			
			var parameter:IParameter			= e.parameter;
			if (!invalidParameters[parameter.id]) {
				invalidParameters[parameter.id]		= parameter;
			}
			invalid								= true;
			
			// dispatch
			dispatchEvent(e);
		}
		
		/**
		 * 	@public
		 */
		final protected function invalidate(parameter:IParameter):void {
			invalidParameters[parameter.id]		= parameter ? parameter.value : null;
			invalid								= true;
		}
		
		/**
		 * 	@public
		 */
		final public function checkValidation():void {
			
			if (invalid) {
				
				// validate!
				validate(invalidParameters);
				
				// reset stuff
				invalid				= false;
				invalidParameters	= {};

			}
		}

		/**
		 * 	@public
		 */
		public function getDimensions():Dimensions {
			return dimensions;
		}
		
		/**
		 * 	@public
		 */
		public function update(time:Number):Boolean {
			return invalid;
		}
		
		/**
		 * 	@public
		 */
		public function get plugin():IPluginDefinition {
			return null;
		}
		
		/**
		 * 	@public
		 */
		public function getTotalTime():int {
			return 0;
		}
		
		/**
		 *	@public
		 */
		final public function setParameterValue(id:String, value:*):void {
			
			var index:int		= id.indexOf('/');
			if (index > 1) {
				var prop:String = id.substr(index + 1);
				id = id.substr(0, index);
			}
			
			const p:IParameter	= parameters.hash[id];
			CONFIG::DEBUG {
				if (!p) {
					throw new Error(id + ' Not Found.');
				}
			}
			
			// parameters
			if (prop && p is IParameterObject) {
				var children:Vector.<IParameter> = (p as IParameterObject).getChildParameters();
				for each (var child:IParameter in children) {
					if (child.id === prop) {
						child.value = value;
						return;
					}
				}
			}
			
			p.value = value;
		}
		
		final public function getParameter(id:String):IParameter {
			return parameters.hash[id];
		}
		
		/**
		 *	@public
		 */
		final public function getParameterValue(id:String):* {
			
			var index:int		= id.indexOf('/');
			if (index > 1) {
				var prop:String = id.substr(index + 1);
				id = id.substr(0, index);
			}
			
			const p:Parameter	= parameters.hash[id];
			CONFIG::DEBUG {
				if (!p) {
					throw new Error(id + ' Not Found.');
				}
			}
			
			// parameters
			if (prop && p is IParameterObject) {
				var children:Vector.<IParameter> = (p as IParameterObject).getChildParameters();
				for each (var child:IParameter in children) {
					if (child.id === prop) {
						return child.value;
					}
				}
			}
			
			return p.value;
		}
		
		/**
		 * 	@public
		 */
		final public function getFile():IFileReference {
			return file;
		}
		
		/**
		 * 	@public
		 */
		public function hasNewFrame():Boolean {
			return invalid;
		}
		
		/**
		 * 	@public
		 */
		protected function validate(invalidParameters:Object):void {}
		
		/**
		 * 	@public
		 */
		final public function getParameters():ParameterList {
			return parameters;
		}
		
		/**
		 * 	@public
		 */
		final public function get id():String {
			return file.path;
		};
		
		/**
		 * 	@public
		 */
		override final public function get name():String {
			var name:String	= file.name;
			return name.substr(0, name.length - file.extension.length - 1);
		}
		
		/**
		 * 	@public
		 */
		public function unserialize(token:*):void {
			
			if (token && parameters) {
				parameters.unserialize(token.parameters);
			}
		}
		
		/**
		 * 	@public
		 */
		public function serialize(options:uint = 0xFFFFFFFF):Object {
			return {
				path:		file.path,
				parameters:	parameters.serialize(options)
			};
		}
		
		/**
		 * 	@public
		 */
		public function hasParameter(name:String):Boolean {
			return parameters && parameters.hash[name] !== undefined;
		}
		
		/**
		 * 	@public
		 */
		public function dispose():void {
			
			for each (var parameter:IParameter in parameters) {
				parameter.removeEventListener(ParameterEvent.VALUE_CHANGE, parameterChange);
			}
			
			parameters.dispose();

		}
	}
}