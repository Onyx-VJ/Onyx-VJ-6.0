package onyx.ui.core {
	
	import onyx.parameter.*;

	public interface IUIParameter extends IUIObject {
		
		function attach(parameter:IParameter):void;
		function update():void;
		function highlightForBind(value:Boolean):void;
		
	}
}