package
{
	import com.barliesque.agal.EasyAGAL;
	
	import flash.display.Sprite;
	
	public class EasierAGALTest extends Sprite
	{
		
		private var agal:ShaderTest	= new ShaderTest();
		
		public function EasierAGALTest():void {
			stage.nativeWindow.activate();
			
			trace(agal.getFragmentOpcode());
		}
	}
}