package {
	
	import flash.display.*;
	import flash.media.*;
	
	import onyx.playmode.*;
	
	final public class PlayModes extends Sprite {
		
		PlayModeBounceIcon;
		PlayModeLinearIcon;
		PlayModeRandomIcon;
		
		/**
		 * 	@private
		 */
		public const plugins:Vector.<Class> = Vector.<Class>([
			
			/*******************************
			 * 
			 * 			PLAYBACK
			 * 
			 *******************************/
			
			PlayModeLinear,
			PlayModeBounce,
			PlayModeRandom,
			
		]);
	}
}