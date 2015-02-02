package {
	
	import flash.display.*;
	import flash.display3D.*;
	import flash.display3D.textures.Texture;
	import flash.events.*;
	import flash.geom.*;
	import flash.media.*;
	import flash.utils.*;
	
	import onyx.assets.*;
	import onyx.display.*;
	
	[SWF(width='100', height='100', frameRate='30', backgroundColor='0x000000')]
	final public class GPUSpriteTest extends Sprite {
		
		/**
		 * 	@private
		 */
		private const stage3D:Stage3D	= stage.stage3Ds[0];
		
		/**
		 * 	@private
		 */
		private var context:Context3D;
		
		/**
		 * 	@private
		 */
		private const sheet:GPUSpriteSheet		= new GPUSpriteSheet();
		
		/**
		 * 	@private
		 */
		private const batches:Vector.<GPUSpriteSheetBatch>	= Vector.<GPUSpriteSheetBatch>([new GPUSpriteSheetBatch(sheet)]);
		
		/**
		 * 	@private
		 */
		private const modelViewMatrix:Matrix3D		= new Matrix3D();
		
		/**
		 * 	@private
		 */
		private var objects:Vector.<FlockItem>		= new Vector.<FlockItem>();
		
		/**
		 * 	@private
		 */
		private var attractor:ObjectAttractor;
		
		/**
		 * 	@private
		 */
		private var offset:int					= -1;
		
		private var target:BitmapData			= new BitmapData(1920, 1080, false, 0x00);
		private var video:Video					= new Video(1920, 1080);
		
		/**
		 * 	@public
		 */
		public function GPUSpriteTest():void {
			
			stage.align			= StageAlign.TOP_LEFT;
			stage.scaleMode		= StageScaleMode.NO_SCALE;
			stage.quality		= StageQuality.LOW;
			stage.displayState	= StageDisplayState.FULL_SCREEN_INTERACTIVE;
			stage.nativeWindow.activate();
			
			var cam:Camera	= Camera.getCamera('0');
			cam.setMode(1920, 1080, 30);
			video.attachCamera(cam);
			
			var shader:Shader					= new Shader(new PBAsset());
			var asset:BitmapData				= new SpriteSheetAsset().bitmapData;
			
			shader.data.src.input				= asset;
			shader.data.keyColor.value			= [0.0, 0.0, 0.0, 1.0];
			shader.data.range.value				= [0.25];
			
			var job:ShaderJob		= new ShaderJob(shader, asset, asset.width, asset.height);
			job.start(true);
			
			init(asset);
			
		}
		
		/**
		 * 	@private
		 */
		private function init(data:BitmapData):void {
			
			var mat:Matrix	= new Matrix(0.05, 0, 0, 0.05);
			
			attractor = new ObjectAttractor(1920, 1080, mat);
			mat.invert();
			
			// unmultiple the spritesheet data
			sheet.initialize(data, 192, 108);

			var num:int	= 250;
			while (num--) {
				var item:FlockItem	= new FlockItem(batches[0].createChild(Math.random() * sheet.length)); 
				item.sprite.index		= Math.random() * 24;
				item.position.x			= Math.random() * 1920;
				item.position.y			= Math.random() * 1080;
				item.sprite.scale		= Math.random() * .2 + .1;
				objects.push(item);
			}
			
			// stage.addEventListener(Event.RESIZE,				handleContext);
			stage3D.addEventListener(Event.CONTEXT3D_CREATE,	handleContext);
			stage3D.requestContext3D();
			
			var dsp:DisplayObject = addChild(new Bitmap(attractor.bmp));
			dsp.transform.matrix = mat;
			dsp.alpha			= 0.25;
			// video.alpha	= 0.2;
			
			addChild(new Stats());
			
		}
		
		/**
		 * 	@private
		 */
		private function handleContext(e:Event):void {
			
			// context
			context	= stage3D.context3D;
			context.configureBackBuffer(stage.stageWidth, stage.stageHeight, 0, false);
			context.enableErrorChecking = true;
			
			var screenX:Number	= 2.0 / stage.stageWidth;
			var screenY:Number	= -2.0 / stage.stageHeight;
			
			modelViewMatrix.rawData	= Vector.<Number>([
				
				screenX,	0.0,		0.0,	screenX - 0.875,
				0.0,		screenY,	0.0,	0.88 - screenY,
				0.0,		0.0,		1.0,	0.0,
				0.0,		0.0,		0.0,	1.0
				
			]);
			
			if (e.type == Event.CONTEXT3D_CREATE) {
				
				for each (var batch:GPUSpriteSheetBatch in batches) {
					batch.initializeContext(context);
				}
				
				// listen
				stage.addEventListener(Event.ENTER_FRAME, handleFrame);
			}
		}
		
		/**
		 * 	@private
		 */
		private function handleFrame(e:Event):void {

			if (context.driverInfo === 'Disposed') {
				return stage.removeEventListener(Event.ENTER_FRAME, handleFrame);;
			}
			
			switch (++offset % 3) {
				case 0:
					target.draw(video);
					break;
				case 1:
					attractor.resample(target, objects.length);
					break;
				case 2:
					for each (item in objects) {
						item.target = attractor.getNearestPoint(item.position);
					}
					break;
			}
			
			// move all the items and stuff
			for each (var item:FlockItem in objects) {
				
				var before:Point 			= item.position.clone();
				var position:Point			= item.position.clone();
				var nearest:Point			= item.target || new Point();
				var turnSpeed:Number		= item.turnSpeed;
				
				var dx:Number				= nearest.x - position.x;
				var dy:Number				= nearest.y - position.y;
				var goal:Number				= Math.atan2(dy, dx);
				var diff:Number				= clamp(goal - item.heading);
				var difference:Number		= Math.max(-turnSpeed, Math.min(turnSpeed, diff));

				item.heading			= clamp(item.heading + difference);
				
				item.position.x			+= Math.cos(item.heading) * item.speed;
				item.position.y			+= Math.sin(item.heading) * item.speed;
				
				item.sprite.rotation = Math.random();
				item.sprite.index++;
				
				item.sprite.position.x = item.position.x;
				item.sprite.position.y = item.position.y;
				
			}

			// clear
			context.clear(0.0, 0.0, 0.0, 1);
			
			for each (var batch:GPUSpriteSheetBatch in batches) {
				batch.render(context, modelViewMatrix);
			}
			
			context.present();
			
		}
		
		/**
		 * 	@private
		 */
		private function clamp(radians:Number):Number {
			
			const pi2:Number = Math.PI * 2;
			
			while(radians < -Math.PI) radians += pi2;
			while(radians > Math.PI) radians -= pi2;
			
			return radians;
			
		}
	}
}