package onyxui.window.mixer {
	
	import flash.events.*;
	
	import onyx.core.*;
	import onyx.event.*;
	import onyx.host.*;
	import onyx.parameter.*;
	import onyx.plugin.*;
	
	import onyxui.core.*;
	import onyxui.parameter.*;
	
	final public class BindingPanel extends UIObject {
		
		/**
		 * 	@private
		 */
		private var command:UITextField		= new UITextField();
		private var control:UITextField		= new UITextField();
		private var saveBtn:UIButton		= new UIButton('Bind');
		private var cancel:UIButton			= new UIButton('Cancel');
		
		/**
		 * 	@private
		 */
		private var parameter:IParameter;
		
		/**
		 * 	@private
		 */
		private var last:InterfaceMessage;
		
		/**
		 * 	@public
		 */
		override public function initialize():void {

			command.resize(80, 16);
			addChild(command);
			control.resize(100, 16);
			control.moveTo(82, 0);
			addChild(control);

			saveBtn.visible	= false;
			saveBtn.moveTo(184, 0);
			saveBtn.resize(50, 16);
			saveBtn.addEventListener(MouseEvent.CLICK, handleClick);
			addChild(saveBtn);

			cancel.visible	= false;
			cancel.moveTo(240, 0);
			cancel.resize(50, 16);
			cancel.addEventListener(MouseEvent.CLICK, handleClick);
			addChild(cancel);

		}
		
		/**
		 * 	@public
		 */
		public function listen(listen:Boolean = true):void {
			
			if (listen) {
				
				// show
				UIParameter.show();
				
				// override events
				AppStage.addEventListener(MouseEvent.CLICK,			handleBind, true);
				AppStage.addEventListener(MouseEvent.MOUSE_DOWN,	handleBind, true);
				AppStage.addEventListener(MouseEvent.MOUSE_OVER,	handleBind, true);
				AppStage.addEventListener(MouseEvent.MOUSE_OUT,		handleBind, true);
				AppStage.addEventListener(MouseEvent.ROLL_OVER,		handleBind, true);

			} else {
				
				// hide
				UIParameter.hide();
				
				// override events
				AppStage.removeEventListener(MouseEvent.CLICK,		handleBind, true);
				AppStage.removeEventListener(MouseEvent.MOUSE_DOWN,	handleBind, true);
				AppStage.removeEventListener(MouseEvent.MOUSE_OVER,	handleBind, true);
				AppStage.removeEventListener(MouseEvent.MOUSE_OUT,	handleBind, true);
				AppStage.removeEventListener(MouseEvent.ROLL_OVER,	handleBind, true);
				
			}
		}
		
		/**
		 * 	@private
		 */
		private function handleBind(e:Event):void {
			
			// stop it from going down
			e.stopImmediatePropagation();
			e.preventDefault();
			
			// click?
			if (e.type === MouseEvent.CLICK) {
				
				var target:IControlParameterProxy	= e.target as IControlParameterProxy;
				if (target) {
					var parameter:Parameter			= target.getParameter();
				}
				
				// we have a target, so 
				attach(parameter || null);

				// dispose
				listen(false);
			}
		}
		
		/**
		 * 	@public
		 */
		public function attach(p:Parameter):void {
			
			parameter = p;

			var show:Boolean	= p !== null;
			if (show) {

				command.text	= p.name;
				control.text	= '';
				
				Onyx.addEventListener(InterfaceMessageEvent.MESSAGE,		handleMessage);
				
			} else {
				
				command.text	= '';
				control.text	= '';
				Onyx.removeEventListener(InterfaceMessageEvent.MESSAGE,		handleMessage);

			}
			
			// save
			saveBtn.visible = show;
			cancel.visible	= show;

		}
		
		/**
		 * 	@private
		 */
		private function handleMessage(event:InterfaceMessageEvent):void {
			
			// don't let it go through
			event.preventDefault();
			
			var message:InterfaceMessage	= event.message;
			if (!message || !message.origin) {
				Console.LogError('No message origin');
				return;
			}
			
			if (!message.origin.canBindParameter(parameter)) {
				trace('can\'t bind: ' + message.toString() + ' to: ' + parameter.toString());
			}
			
			
			// store the last
			last = event.message;
			
			// store
			control.text			= String(last) || '';
			
		}
		
		/**
		 * 	@private
		 */
		private function handleClick(event:MouseEvent):void {
			switch (event.currentTarget) {
				case saveBtn:
					if (parameter && last && last.origin) {
						
						// bind the parameter
						last.origin.bindParameter(parameter, last);

//						
//						const module:IPluginParameterInterface = last.plugin;
//						if (!module.bindParameter(parameter, last.key)) {
//							control.text = 'CANNOT BIND THIS PARAMETER TO KEYBOARD';
//							return;
//						} else {
//							parameter	= null;
//							last		= null;
//							attach(null);
//							return;
//						}
					}

					listen(false);
					attach(null);
					
					break;
				case cancel:
					
					listen(false);
					attach(null);
					
					break;
			}
		}
		
		/**
		 * 	@public
		 */
		override public function dispose():void {
			

			// dispose
			listen(false);
			
			saveBtn.removeEventListener(MouseEvent.CLICK,	handleClick);
			cancel.removeEventListener(MouseEvent.CLICK,	handleClick);
			
			// dispose
			super.dispose();
		}
	}
}