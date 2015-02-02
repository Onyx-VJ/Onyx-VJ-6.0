package onyx.ui.interaction {
	
	import onyx.ui.core.UIObject;
	
	public interface IInteraction {
		
		function bind(target:UIObject):void;
		
		function unbind(target:UIObject):void;
		
		function get type():int;
		
	}
}