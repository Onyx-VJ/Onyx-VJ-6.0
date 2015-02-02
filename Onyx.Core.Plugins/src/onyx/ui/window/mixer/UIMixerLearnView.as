package onyx.ui.window.mixer {
	
	import flash.events.*;
	
	import onyx.core.*;
	import onyx.event.*;
	import onyx.parameter.*;
	import onyx.ui.component.*;
	import onyx.ui.core.*;
	import onyx.ui.parameter.*;
	
	use namespace skinPart;
	
	[UIConstraint(type='relative', top='22', left='4', right='4', bottom='4')]
	
	[UISkinPart(id='command',		type='text',	 		constraint='relative', left='0', top='0', width='100', height='16')]
	[UISkinPart(id='control',		type='text',	 		constraint='relative', left='0', top='16', width='100', height='16')]
	[UISkinPart(id='saveBtn',		type='button',	 		constraint='relative', right='0', bottom='0', width='100', height='16', label='Save Binding')]

	final public class UIMixerLearnView extends UIObject {
		
		/**
		 * 	@private
		 */
		skinPart var command:UITextField;

		/**
		 * 	@private
		 */
		skinPart var control:UITextField;

		/**
		 * 	@private
		 */
		skinPart var saveBtn:UIButton;
		
		/**
		 * 	@private
		 */
		private var target:IControlParameterProxy;
		
		/**
		 * 	@private
		 */
		private var last:InterfaceMessage;
		
		/**
		 * 	@public
		 */
		override public function initialize(data:Object):void {
			
			// initialize
			super.initialize(data);
			
			// show
			UIParameter.show();
			
			// override events
			AppStage.addEventListener(MouseEvent.CLICK,			handleBind, true);
			AppStage.addEventListener(MouseEvent.MOUSE_DOWN,	handleBind, true);
			AppStage.addEventListener(MouseEvent.MOUSE_OVER,	handleBind, true);
			AppStage.addEventListener(MouseEvent.MOUSE_OUT,		handleBind, true);
			AppStage.addEventListener(MouseEvent.ROLL_OVER,		handleBind, true);
			AppStage.addEventListener(MouseEvent.ROLL_OUT,		handleBind, true);
			
			// handle message
			Onyx.addEventListener(InterfaceMessageEvent.MESSAGE, handleMessage);
			
			// add listeners
			saveBtn.addEventListener(MouseEvent.CLICK,	handleClick);
			
			command.text	= 'Select a parameter';
		}
		
		/**
		 * 	@private
		 */
		private function handleClick(event:MouseEvent):void {
			switch (event.currentTarget) {
				case saveBtn:
					
					if (target && last && last.origin) {
						
						target.getParameter().bindInterface(new InterfaceBinding(last.origin, last.key));
						target.update();
						
					}
					
					// allow fall through
				default:
					
					attach(null);
					
					// issues with keyboard not getting focus again, so re-focus
					AppStage.focus	= AppStage;
					
					break;
			}
		}
		
		
		/**
		 * 	@private
		 */
		private function handleBind(e:Event):void {
			
			// exit
			var target:IControlParameterProxy	= e.target as IControlParameterProxy;
			if (target) {
				
				// stop it from going down
				e.stopPropagation();
				e.preventDefault();
				
				if (e.type === MouseEvent.CLICK) {
					
					// we have a target, so 
					attach(target);

				}
			}
		}
		
		/**
		 * 	@public
		 */
		public function attach(t:IControlParameterProxy):void {
			
			target = t;
			
			var show:Boolean	= (t && t.getParameter()) !== null;
			if (show) {
				
				command.text	= t.getParameter().name;
				control.text	= '';
				
			} else {
				
				command.text	= 'Select a parameter';
				control.text	= '';
				
			}
			
			// unbind last
			last = null;
			
			// save
			saveBtn.visible = show;
			
		}
		
		/**
		 * 	@private
		 */
		private function handleMessage(event:InterfaceMessageEvent):void {
			
			// don't let it go through
			event.preventDefault();
			
			// nothing bound
			if (!target) {
				return;
			}
			
			var message:InterfaceMessage	= event.message;
			if (!message || !message.origin) {
				Console.LogError('No message origin');
				return;
			}
			
			if (!message.origin.canBind(target.getParameter())) {
				control.text		= 'Cannot bind: ' + event.message.toString();
				return;
			}
			
			// store the last
			last					= event.message;
			
			// store
			control.text			= String(last) || '';

		}
		
		/**
		 * 	@public
		 */
		override public function arrange(rect:UIRect):void {
			
			super.arrange(rect);
			super.arrangeSkins(rect.identity());
		}
		
		/**
		 * 	@public
		 */
		override public function dispose():void {
			
			Onyx.removeEventListener(InterfaceMessageEvent.MESSAGE, handleMessage);
			
			AppStage.removeEventListener(MouseEvent.CLICK,			handleBind, true);
			AppStage.removeEventListener(MouseEvent.MOUSE_DOWN,		handleBind, true);
			AppStage.removeEventListener(MouseEvent.MOUSE_OVER,		handleBind, true);
			AppStage.removeEventListener(MouseEvent.MOUSE_OUT,		handleBind, true);
			AppStage.removeEventListener(MouseEvent.ROLL_OVER,		handleBind, true);
			AppStage.removeEventListener(MouseEvent.ROLL_OUT,		handleBind, true);
			
			UIParameter.hide();

			super.dispose();
		}
	}
}