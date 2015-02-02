package onyx.extension
{
	import flash.events.EventDispatcher;
	import flash.external.ExtensionContext;

	public class HelloWorldExtension extends EventDispatcher
	{
		
		private static var isInstantiated:Boolean = false;
		private static var context:ExtensionContext;
		
		public function HelloWorldExtension()
		{
			super();
			
			if (isInstantiated)
				return;
			
			try
			{
				context = ExtensionContext.createExtensionContext("onyx.extension.HelloWorldExtension", ""); 
				isInstantiated = true;
			}
			catch (e:Error)
			{
			}
		}
		
		public function helloWorld(message:String):*
		{
			return context.call("helloWorld", message);
		}
	}
}