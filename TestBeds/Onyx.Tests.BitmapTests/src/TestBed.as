package
{
	import flash.display.*;
	
	[SWF(width='640', height='480')]
	final public class TestBed extends Sprite
	{
		private const buffer:BitmapData	= new BitmapData(640,480,true,0x00);
		private const base:BitmapData	= new AssetBase().bitmapData;
		private const blend:BitmapData	= new AssetBlend().bitmapData;
		
		public function TestBed()
		{
			buffer.draw(base, null, null, BlendMode.DIFFERENCE);
			
			addChild(new Bitmap(buffer));
			
			stage.nativeWindow.activate();
			
		}
	}
}