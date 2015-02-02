package onyx.ui.parameter {
	
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.utils.*;
	
	import onyx.core.*;
	import onyx.event.*;
	import onyx.parameter.*;
	import onyx.ui.component.*;
	import onyx.ui.core.*;
	import onyx.ui.factory.*;
	import onyx.util.*;
	
	[UIComponent(id='parameter')]
	
	final public class UIParameter extends UIObject {
		
		// register defaults
		registerDefaultFactories();
		
		/**
		 * 	@private
		 */
		private static const FACTORIES:Object	= {};
		
		/**
		 * 	@private
		 */
		private static function registerDefaultFactories():void {
			
			registerFactory(
				new UIFactory(UIParameterDropDown, { renderType: 'text', textAlign: 'center' }),
				'array', 'enum'
			);
			
			registerFactory(new UIFactory(UIParameterDropDown, { renderType: 'icon' }), 'playmode');
			registerFactory(new UIFactory(UIParameterDropDown, { renderType: 'text', textAlign: 'left' }), 'channel');
			registerFactory(new UIFactory(UIParameterSlider,	{ textAlign: 'center' }), 'number', 'integer', 'int');
			registerFactory(
				new UIFactory(UIParameterSliderGroup),
				'matrix/scale', 'matrix/translate', 'point'
			);
			
			registerFactory(new UIFactory(UIParameterColorTransform),	'colortransform');
			registerFactory(new UIFactory(UIParameterButton),			'function');
			registerFactory(new UIFactory(UIParameterColorPicker),		'color');
			registerFactory(new UIFactory(UIParameterText, { textAlign: 'center' }),				'text');
			registerFactory(new UIFactory(UIParameterStatus,  { textAlign: 'center' }),				'status');
			
		}
		
		/**
		 * 	@private
		 */
		private static function registerFactory(factory:IFactory, ... args:Array):void {
			for each (var name:String in args) {
				FACTORIES[name] = factory;
			}
		}
		
		/**
		 * 	@private
		 */
		private static const ACTIVE_CONTROLS:Dictionary	= new Dictionary(true);
		
		/**
		 * 	@private
		 */
		private static var showing:Boolean				= false; 
		
		/**
		 * 	@private
		 */
		public static function show():void {
			
			showing = true;
			for (var i:Object in ACTIVE_CONTROLS) {
				var control:UIParameter			= i as UIParameter;
				if (control && control.display) {
					control.display.highlightForBind(true);
				}
			}
		}
		
		/**
		 * 	@public
		 */
		public static function hide():void {
			
			showing = false;
			
			for (var i:Object in ACTIVE_CONTROLS) {
				var control:UIParameter		= i as UIParameter;
				if (control && control.display) {
					control.display.highlightForBind(false);
				}
			}
		}
		
		/**
		 * 	@protected
		 */
		private var parameter:IParameter;
		
		/**
		 * 	@private
		 */
		private var display:IUIParameter;
		
		/**
		 * 	@protected
		 */
		private const bounds:UIRect			= new UIRect();
		
		/**
		 * 	@private
		 */
		private var label:UITextField;
		
		/**
		 * 	@private
		 */
		private var data:Object;
		
		/**
		 * 	@public
		 */
		public function UIParameter():void {
			
			// delete
			ACTIVE_CONTROLS[this] = 1;
			
			// watch gc
			CONFIG::DEBUG { GC.watch(this); }
			
		}
		
		/**
		 * 	@public
		 */
		public function get controlHeight():int {
			return 16;
		}
		
		/**
		 * 	@public
		 */
		public function attach(param:IParameter):void {
			
			if (parameter) {
				parameter.removeEventListener(ParameterEvent.VALUE_CHANGE, update);
			}
			
			if (!param) {
				
				if (display) {
					display.dispose();
					removeChild(display as DisplayObject);
					display = null;
				}
				
				return;
			}
			
			if (!param.type) {
				return;
			}
			
			var factory:UIFactory = FACTORIES[param.type.toLowerCase()];
			if (factory) {
				display = factory.createInstance(data);
				addChild(display as DisplayObject);
				display.attach(param);
				if (bounds) {
					display.arrange(bounds);
				}
			} else {
				throw new Error('factory does not exist' + param.type);
			}

			if (param) {
				
				// bind
				parameter = param;
				parameter.addEventListener(ParameterEvent.VALUE_CHANGE, update);
				
				if (label) {
					label.text = param.name;
				}
				
				// update
				update();
				
				if (showing && display) {
					display.highlightForBind(true);
				}
			}
		}
		
		/**
		 * 	@public
		 */
		final public function getDisplayName():String {
			return parameter ? parameter.name : 'NOT DEFINED';
		}
		
		/**
		 * 	@public
		 */
		public function update(e:ParameterEvent = null):void {

			application.invalidate(new Callback(display.update));

		}
		
		/**
		 * 	@public
		 */
		override public function initialize(data:Object):void {

			// initialize
			super.initialize(this.data = data);
			
			if (data.showLabel) {
				addChild(label = UIFactoryDefinitions.CreateInstance('text', { textAlign: 'left' } ));
			}
		}
		
		/**
		 * 	@public
		 */
		override public function arrange(rect:UIRect):void {
			
			// arrange
			super.arrange(rect);
			
			bounds.width	= rect.width;
			bounds.height	= rect.height;
			
			if (display) {
				if (label) {
					display.arrange(new UIRect(70, 0, bounds.width - 70, bounds.height));
				} else {
					display.arrange(rect.identity());
				}
			}
		}
		
		/**
		 * 	@public
		 */
		override public function dispose():void {
			
			// parameter
			if (parameter) {
				parameter.removeEventListener(ParameterEvent.VALUE_CHANGE, update);
			}
			
			// release
			delete ACTIVE_CONTROLS[this];
			
			// dispose
			super.dispose();
		}
		
		/**
		 * 	@public
		 */
		override public function toString():String {
			return '[UI: ' + (parameter ? parameter.toString().substr(0, -1) : 'not set') + ',' + String(display) + ']';
		}
	}
}