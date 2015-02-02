package {

	import flash.display.*;
	import onyx.generator.*;
	
	final public class CoreGenerators extends Sprite {
		
		/**
		 * 	@public
		 */
		public const plugins:Vector.<Class> = Vector.<Class>([
			GeneratorImage, GeneratorSWFMovie, GeneratorMovie
		]);

	}
}