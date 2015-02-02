package onyx.ui.core {
	
	public interface IFactory {
		
		function get id():String;
		function createInstance(token:Object = null):*;

	}
}