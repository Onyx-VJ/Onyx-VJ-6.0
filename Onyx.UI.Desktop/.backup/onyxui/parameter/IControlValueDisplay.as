package onyxui.parameter {
	
	import onyx.parameter.*;

	public interface IControlValueDisplay {
		
		function updateDisplay():void;
		function attach(p:Parameter):void;
		function resize(width:int, height:int):void;

	}
}