// http://wonderfl.net/c/4VE6

package onyx.patch.gpu {
	
	import com.adobe.utils.*;
	
	import flash.display.*;
	import flash.display3D.*;
	import flash.display3D.textures.*;
	import flash.geom.*;
	import flash.utils.*;
	
	import onyx.core.*;
	import onyx.display.*;
	import onyx.event.*;
	import onyx.plugin.*;
	
	use namespace parameter;
	
	[Parameter(id='reset', type='function')]
	
	final public class MoreFast extends PluginPatchGPU {
		
		/**
		 * 	@private
		 */
		private var dummy:Shape	= new Shape();
		private var ROT_STEPS:int = 0;
		
		private var num_limit:uint = 2000;
		
		private var forceMap:BitmapData;
		private var randomSeed:uint = Math.floor( Math.random() * 0xFFFF );
		private var particleList:Vector.<Arrow> = new Vector.<Arrow>(num_limit, true);
		private var rect:Rectangle;
		private var seed:Number = Math.floor( Math.random() * 0xFFFF );
		private var offset:Array = [new Point(), new Point()];
		private var timer:Timer;
		private var world:Sprite = new Sprite();
		private var rotBmp:DisplaySurface;
		
		private var program:IDisplayProgramGPU;
		
		private var iBuffer:IndexBuffer3D;
		private var vBuffer:VertexBuffer3D;
		private var uvBuffer:VertexBuffer3D;
		private var texture:DisplayTexture;
		private var forceTex:DisplayTexture;
		
		private var ortho:Matrix3D				= new Matrix3D();
		private var r_rot_steps:Vector.<Number>	= Vector.<Number>([0,0,0,0]);
		
		private var vb:Vector.<Number>			= new Vector.<Number>();
		private var uvb:Vector.<Number>			= new Vector.<Number>();
		private var ib:Vector.<uint>			= new Vector.<uint>();
		private const vunit:int					= 4;
		private const uvunit:int				= 2;
		
		private var uirect:Sprite				= new Sprite();
		
		/**
		 * 	@public
		 */
		override public function initialize(context:IDisplayContextGPU, channel:IChannelGPU, file:IFileReference, content:Object):PluginStatus {
			
			rect		= new Rectangle(0, 0, context.textureWidth, context.textureHeight);
			forceMap	= new BitmapData( context.textureWidth >> 1, context.textureHeight >> 1, false, 0x000000 )
			
			// reset
			reset();
			
			// draw dummy
			dummy.graphics.beginFill(0xFFFFFF, 1);
			dummy.graphics.lineStyle(1, 0x0, 1);
			
			dummy.graphics.moveTo(2, 4);
			dummy.graphics.lineTo(8, 4);
			dummy.graphics.lineTo(8, 0);
			dummy.graphics.lineTo(20, 7);
			dummy.graphics.lineTo(8, 14);
			dummy.graphics.lineTo(8, 10);
			dummy.graphics.lineTo(2, 10);
			dummy.graphics.lineTo(2, 4);
			
			var assembler:AGALMiniAssembler = new AGALMiniAssembler();
			program = context.requestProgram(
				assembler.assemble(Context3DProgramType.VERTEX,
					'm44 op, va0, vc0			\n' +
					'mov v0, va2				\n' +
					'mul vt0.x, va1.x, vc4.x	\n' +
					'add v0.x, va2.x, vt0.x'
				),
				assembler.assemble(Context3DProgramType.FRAGMENT, 
					'mov ft0, v0				\n' +
					'tex oc, ft0.xy, fs1 <2d,repeat,nearest>\n'
				)
			);
			
			// success
			var status:PluginStatus = super.initialize(context, channel, file, context);
			
			ortho = new Matrix3D(Vector.<Number>([
				2.0 / context.textureWidth,		0.0,	0.0,	0.0,
				0.0,	2.0 / context.textureHeight,	0.0,	0.0,
				0.0,	0.0,							1.0,	0.0,
				0.0,	0.0,							0.0,	1.0
			]));
			
			ROT_STEPS = context.textureWidth / 16; 
			var matrix:Matrix;
			rotBmp = new DisplaySurface(context.textureWidth, 16, true, 0x0);
			var i:int = ROT_STEPS;
			while (i--) {
				matrix = new Matrix();
				matrix.translate( -11, -7);
				matrix.rotate( ( 360 / ROT_STEPS * i )* Math.PI / 180);
				matrix.scale(0.75, 0.75); // ちょっと縮小
				matrix.translate( 8+i*16, 8);
				
				rotBmp.draw(dummy, matrix);
			}
			
			forceMap.draw(rotBmp);
			
			// パーティクルを生成します
			for (i = 0; i < num_limit; i++) {
				var px:Number = Math.random() * context.textureWidth;
				var py:Number = Math.random() * context.textureHeight;
				particleList[i] = new Arrow(px, py);
			}
			
			// listen for invalidation
			context.addEventListener(OnyxEvent.GPU_CONTEXT_CREATE, handleContext);
			if (context.isValid()) {
				handleContext();
			}
			
			return status;
		}
		
		/**
		 * 	@private
		 */
		private function handleContext(e:* = null):void {
			
			vb.length	= 0;
			uvb.length	= 0;
			ib.length	= 0;
			
			for (var i : int = 0; i < num_limit; i++) {
				vb.push( -8, -8,  0, 0);
				vb.push(  8, -8,  0 ,0);
				vb.push(  8,  8,  0 ,0);
				vb.push( -8,  8,  0, 0);
				
				uvb.push( 0,          0);
				uvb.push( 1/ROT_STEPS,0);
				uvb.push( 1/ROT_STEPS,1);
				uvb.push( 0,          1);
				
				// create dual triangle quad
				ib.push( i*4+0, i*4+1, i*4+2, i*4+0, i*4+2, i*4+3 );
			}
			
			vBuffer = context.createVertexBuffer(vb.length / vunit, vunit);
			vBuffer.uploadFromVector(vb, 0, vb.length / vunit);
			
			uvBuffer = context.createVertexBuffer(uvb.length / uvunit, uvunit);
			uvBuffer.uploadFromVector(uvb, 0, uvb.length / uvunit);
			
			iBuffer = context.createIndexBuffer(ib.length);
			iBuffer.uploadFromVector(ib,0,ib.length);
			
			texture = context.requestTexture(rotBmp.width, 16, false);
			texture.upload(rotBmp);
			
			forceTex = context.requestTexture(forceMap.width, forceMap.height);
			forceTex.upload(forceMap);
			
			trace('upload');
		}
		
		/**
		 * 	@public
		 * 	Update every frame
		 */
		override public function update(time:Number):Boolean {
			return true;
		}
		
		/**
		 * 	@public
		 */
		override public function render(context:IDisplayContextGPU):Boolean {
			
			var transform:ColorTransform= new ColorTransform(1.0,1.0,1.0,1.0);
			
			context.setBlendFactor(Context3DBlendFactor.SOURCE_ALPHA, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);
			context.clear(Color.CLEAR);
			context.blit(forceTex);
			
			var len:uint = num_limit < particleList.length ? num_limit : particleList.length ;
			var col:uint;
			var index:uint = 0;
			for (var i:uint = 0; i < len; i++) {
				var arrow:Arrow = particleList[i];
				
				var oldX:Number = arrow.x;
				var oldY:Number = arrow.y;
				
				col = forceMap.getPixel( arrow.x >> 1, arrow.y >> 1);
				arrow.ax += ( (col      & 0xff) - 0x80 ) * .00025;		// blue value left / right
				arrow.ay += ( (col >> 8 & 0xff) - 0x80 ) * .00025;		// green value up down
				arrow.vx += arrow.ax;
				arrow.vy += arrow.ay;
				arrow.x += arrow.vx;
				arrow.y += arrow.vy;
				
				var _posX:Number = arrow.x;
				var _posY:Number = arrow.y;
				var rot:Number = - Math.atan2((_posX - oldX), (_posY - oldY)) * 180 / Math.PI + 90;
				var angle:int = rot / 360 * ROT_STEPS | 0;
				// Math.absの高速化ね
				angle = (angle ^ (angle >> 31)) - (angle >> 31);
				//arrow.rot += (angle - arrow.rot) * 0.2;
				//arrow.bitmapData = rotBmp;
				var x:Number	= rect.width;
				var y:Number	= rect.height;
				
				arrow.ax *= .96;
				arrow.ay *= .96;
				arrow.vx *= .92;
				arrow.vy *= .92;
				
				// あと配置座標を整数化しておきます
				//arrow.x = arrow.x | 0;
				//arrow.y = arrow.y | 0;
				
				( _posX > x ) ? arrow.x = 0 :
					( _posX < 0 ) ? arrow.x = x : 0;
				( _posY > rect.height ) ? arrow.y = 0 :
					( _posY < 0 ) ? arrow.y = y : 0;
				
				vb[index++] = (_posX - x/2)-8;
				vb[index++] = (_posY - y/2)-8;
				vb[index++] = angle >> 0;
				index++;
				
				vb[index++] = (_posX - x/2)+8;
				vb[index++] = (_posY - y/2)-8;
				vb[index++] = angle >> 0;
				index++;
				
				vb[index++] = (_posX - x/2)+8;
				vb[index++] = (_posY - y/2)+8;
				vb[index++] = angle >> 0;
				index++;
				
				vb[index++] = (_posX - x/2)-8;
				vb[index++] = (_posY - y/2)+8;
				vb[index++] = angle >> 0;
				index++;
			}
			
			vBuffer.uploadFromVector(vb, 0, num_limit*4); 
			
			// set texture
			context.bindProgram(program);
			context.setTextureAt(0, null);
			context.setTextureAt(1, texture);
			
			context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, ortho, true);
			context.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 4, r_rot_steps);
			
			context.setVertexBufferAt(0, vBuffer, 0, Context3DVertexBufferFormat.FLOAT_2);
			context.setVertexBufferAt(1, vBuffer, 2, Context3DVertexBufferFormat.FLOAT_2);
			context.setVertexBufferAt(2, uvBuffer, 0, Context3DVertexBufferFormat.FLOAT_2);
			
			context.drawTriangles(iBuffer, 0, 2*num_limit);
			
			return true;
		}
		
		/**
		 * 	@public
		 */
		override public function dispose():void {
			
			// release the program
			context.releaseProgram(program);
			
			// remove listener
			context.removeEventListener(OnyxEvent.GPU_CONTEXT_CREATE, handleContext);
			
			// dispose
			super.dispose();
			
		}
		
		parameter function reset():void {
			
			forceMap.perlinNoise(117, 117, 3, seed, false, true, 6, false, offset);
			
			offset[0].x += 1.5;
			offset[1].y += 1;
			seed = Math.floor( Math.random() * 0xFFFFFF );
			
			if (forceTex) {
				forceTex.upload(forceMap);
			}
		}
	}
}

final class Arrow { 
	
	public var rot:int = 0;
	public var vx:Number = 0;
	public var vy:Number = 0;
	public var ax:Number = 0;
	public var ay:Number = 0;
	public var x:Number = 0;
	public var y:Number = 0;
	
	function Arrow( x:Number, y:Number) {
		this.x = x;
		this.y = y;
	}
}