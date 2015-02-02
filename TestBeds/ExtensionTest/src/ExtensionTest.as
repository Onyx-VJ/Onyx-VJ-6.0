package {
	
	import flash.display.*;
	import be.aboutme.extensions.HelloWorldExtension;
	import flash.text.*;
	
	final public class ExtensionTest extends Sprite {
		
		private var ext:HelloWorldExtension;
		private var txt:TextField	= new TextField(); 
		
		public function ExtensionTest():void {
			
			addChild(txt);
			
			ext = new HelloWorldExtension();
			txt.text = ext.talkBack('hi there');
			
			stage.nativeWindow.activate();
		}
	}
}