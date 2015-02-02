package onyxui.interaction {
	
	import onyxui.core.UIObject;
	
	public interface IInteraction {
		
		function bind(target:UIObject):void;
		function unbind(target:UIObject):void;
		function get type():int;
		
	}
}