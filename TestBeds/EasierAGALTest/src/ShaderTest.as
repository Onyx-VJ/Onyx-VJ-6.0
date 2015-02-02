package
{
	import com.barliesque.agal.*;
	import com.barliesque.shaders.macro.Blend;

	public final class ShaderTest extends EasierAGAL {
		
		private var blend:String	 = '';

		override protected function _fragmentShader():void {
			
			
			sampleTexture(TEMP[0], VARYING[0], SAMPLER[0], [TextureFlag.TYPE_2D, TextureFlag.MIP_NO, TextureFlag.FILTER_NEAREST]);
			sampleTexture(TEMP[1], VARYING[0], SAMPLER[1], [TextureFlag.TYPE_2D, TextureFlag.MIP_NO, TextureFlag.FILTER_NEAREST]);
			
			// premultiply
			multiply(TEMP[2], TEMP[1].rgb, CONST[0]._('www'));
			multiply(TEMP[1], TEMP[2].rgb, CONST[0].rgb);
			
			switch (blend) {
				case 'overlay':
					
					Blend.overlay(TEMP[6], TEMP[0], TEMP[1], CONST[1].r, CONST[2].r, TEMP[3], TEMP[4], TEMP[5]);
					move(OUTPUT, TEMP[6]);
					break;
				case 'hardlight':
					
					Blend.hardLight(TEMP[6], TEMP[0], TEMP[1], CONST[1].r, CONST[2].r, TEMP[3], TEMP[4], TEMP[5]);
					move(OUTPUT, TEMP[6]);
					
					break;
				case 'darkerColor':
					
					Blend.darkerColor(TEMP[4], TEMP[0], TEMP[1], TEMP[2], TEMP[3]);
					move(OUTPUT, TEMP[4]);
					
					break;
				case 'difference':
					Blend.difference(TEMP[2], TEMP[0], TEMP[1]);
					break;
				case 'colorDodge':
					
					Blend.colorDodge(TEMP[2], TEMP[0], TEMP[1], CONST[1].r);
					break;
				case 'colorBurn':
				
					Blend.colorBurn(TEMP[2], TEMP[0], TEMP[1], CONST[1].r);
					break;
				case 'hardmix':
					
					// varies a bit
					Blend.hardMix(TEMP[3], TEMP[0], TEMP[1], CONST[1].r);
					break;
				case 'vividlight':
					Blend.vividLight(TEMP[6], TEMP[0], TEMP[1], CONST[1].r, CONST[2].r, TEMP[2], TEMP[3], TEMP[4]);
					break;
				case 'softlight':
					Blend.softLight(TEMP[2], TEMP[0], TEMP[1]);
					break;
				
				case 'phoenix':
					Blend.phoenix(TEMP[3], TEMP[0], TEMP[1], TEMP[2]);
					break;
				case 'negation':
					Blend.negation(TEMP[2], TEMP[0], TEMP[1], CONST[1].r);
					break;
				
				default:
					Blend.average(TEMP[2], TEMP[0], TEMP[1], CONST[1].r);
					break;
			}
		}
	}
}