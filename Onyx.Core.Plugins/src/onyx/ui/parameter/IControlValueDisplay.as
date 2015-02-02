package onyx.ui.parameter {
	
	import onyx.parameter.*;
	import onyx.ui.core.*;

	public interface IControlValueDisplay {
		
		function update(value:*):void;
		function arrange(rect:UIRect):void;

	}
}