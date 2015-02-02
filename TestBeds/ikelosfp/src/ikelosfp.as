package {

	import flash.display.*;
	import flash.events.*;
	import flash.external.*;
	import flash.system.*;
	import flash.text.*;
	
	import ikelos.core.*;

	[SWF(width='1024', height='768', frameRate="30", backgroundColor='0x222222')]
	final public class ikelosfp extends Sprite {

		/**
		 * 	@private
		 */
		private const playerHost:PlayerHost	= new PlayerHost();

		/**
		 * 	@private
		 */
		CONFIG::DEBUG {
			private const debugOutput:TextField	= new TextField();
		}

		/**
		 * 	@public
		 */
		public function ikelosfp():void {

			CONFIG::DEBUG {

				// set the callback
				Debug.setCallback(addLog);

				debugOutput.text		= 'STARTING\n';
				debugOutput.textColor	= 0xFFFFFF;
				debugOutput.width		= stage.stageWidth;
				debugOutput.height		= stage.stageHeight;
				debugOutput.appendText('ExternalInterface:' + ExternalInterface.available + '\n');

				for (var i:String in stage.loaderInfo.parameters) {
					debugOutput.appendText(i + ':' + stage.loaderInfo.parameters[i] + '\n');
				}

				// add debug output
				stage.addChild(debugOutput);
				stage.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, function(e:UncaughtErrorEvent):void {
					addLog('error', e.text);
				});
			}

			// allow
			Security.allowDomain("*");

			stage.scaleMode	= StageScaleMode.NO_SCALE;
			stage.align		= StageAlign.TOP_LEFT;

			// add the player
			addChild(playerHost);

			// initialize
			playerHost.initialize(stage.loaderInfo.parameters, stage);

		}

		CONFIG::DEBUG {

			/**
			 * 	@private
			 */
			private function addLog(...args:Array):void {

				debugOutput.appendText(args.join(' ') + '\n');
				debugOutput.scrollV = debugOutput.maxScrollV;

			}
		}
	}
}
