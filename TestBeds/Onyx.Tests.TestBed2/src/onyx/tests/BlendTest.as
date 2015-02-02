package onyx.tests {
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display3D.*;
	import flash.display3D.textures.*;
	import flash.geom.Matrix;
	import flash.text.TextFormat;
	
	import onyx.display.Color;
	import onyx.util.Raster;
	
	final public class BlendTest extends TestBaseGL {
		
		private var blendProg:Program3D;
		private const layers:Vector.<Texture>	= new Vector.<Texture>(2, true);
		
		/**
		 * 	@public
		 */
		public function BlendTest():void {

			super({
				'grid':			'assets/grid.png',
				// 'blend':		'assets/blend.png',
				// 'overlay':		'assets/overlay.png',
				'blend':		'assets/test-alpha.png',
				'overlay':		'assets/overlay.png',
				'lighten':		'render/Onyx.BlendGL.Lighten.onx',
				'premultiply':	'render/Onyx.BlendGL.Premultiply.onx'
			});
			
		}
		
		/**
		 * 	@public
		 */
		override public function initialize():void {
			
			layers[0]	= context.createTexture(assets.blend.bitmapData);
			layers[1]	= context.createTexture(assets.overlay.bitmapData);
			
			blendProg	= context.createProgram(assets.lighten);
			
			// create a test
			const data:BitmapData	= new BitmapData(640, 480, true, 0);
			data.draw(assets.blend);
			data.draw(assets.overlay, null, null, 'lighten');
			
			// raster
			Raster.text(data, 'FLASH', new TextFormat('Arial', 14, 0xFFFFFF));
			
			context.stage.addChild(new Bitmap(data)).transform.matrix = new Matrix(1,0,0,1,640, 0);
			
		}
		
		/**
		 * 	@public
		 */
		override public function render():void {

			if (!context.isValid()) {
				return;
			}
			
			context.bindBuffer();
			context.setBlendFactor(Context3DBlendFactor.ONE, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);
			context.draw(layers[0]);
			context.swapBuffer();
			
			// normal
			//context.setBlendFactor(Context3DBlendFactor.SOURCE_ALPHA, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);
			//context.exec(blendProg, context.getBuffer(), layers[1]);
			//context.swapBuffer();
			
			// normal
//			context.setBlendFactor(Context3DBlendFactor.ONE, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);
//			context.draw(context.getBuffer());
//			context.draw(overlay);
//			context.swapBuffer();
			
			// present
			context.present();
		}
	}
}

/*
	context.setBlendFactor(Context3DBlendFactor.ONE, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);
	context.draw(grid);
	
	context.setBlendFactor(Context3DBlendFactor.ONE, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);
	context.draw(blend);
	
	context.setBlendFactor(Context3DBlendFactor.ONE, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);
	context.draw(overlay);
*/