package com.danielhai.gpu {
	
	import com.adobe.utils.*;
	
	import flash.display.BitmapData;
	import flash.display3D.*;
	import flash.display3D.textures.*;
	import flash.geom.*;
	
	import onyx.core.*;
	import onyx.display.*;

	/**
	 * 	Sprite sheet
	 */
	public final class GPUSpriteSheetBatch {
		
		/**
		 * 	@private
		 */
		private const vertex:Vector.<Number>	= new Vector.<Number>();
		
		/**
		 * 	@private
		 */
		private const index:Vector.<uint>		= new Vector.<uint>();
		
		/**
		 * 	@private
		 */
		private const uv:Vector.<Number>		= new Vector.<Number>();
		
		/**
		 * 	@private
		 */
		private var invalidateVBO:Boolean		= true;
		
		/**
		 * 	@private
		 */
		private var sheet:GPUSpriteSheet;
		
		/**
		 * 	@private
		 */
		private var iBuffer:IndexBuffer3D;
		
		/**
		 * 	@private
		 */
		private var vBuffer:VertexBuffer3D;
		
		/**
		 * 	@private
		 */
		private var uvBuffer:VertexBuffer3D;
		
		/**
		 * 	@private
		 */
		private var texture:DisplayTexture;
		
		/**
		 * 	@private
		 */
		private var shaderProg:IDisplayProgramGPU;
		
		/**
		 * 	@private
		 */
		private const children:Vector.<GPUSprite>	= new Vector.<GPUSprite>();
		
		/**
		 * 	@public
		 */
		public function GPUSpriteSheetBatch(sheet:GPUSpriteSheet):void {
			this.sheet	= sheet;
		}
		
		/**
		 * 	@public
		 */
		public function get numSprites():int {
			return sheet.length;
		}
		
		/**
		 * 	@public
		 */
		public function get bitmapData():BitmapData {
			return sheet.data;
		}
		
		/**
		 * 	@public
		 */
		public function createChild(index:int):GPUSprite {
			return addChild(new GPUSprite(index, sheet.getRect(index)));
		}
		
		/**
		 * 	@private
		 */
		private function addChild(sprite:GPUSprite):GPUSprite {
			
			const currentIndex:int			= ((children.push(sprite) - 1) * 12) / 3;
			const spriteUV:Vector.<Number>	= sheet.getUVCoords(sprite);
			vertex.push(0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1);
			index.push(
				currentIndex,	currentIndex+1, currentIndex+2,
				currentIndex,	currentIndex+2, currentIndex+3
			);
			
			uv.push(
				spriteUV[0], spriteUV[1],
				spriteUV[2], spriteUV[3],
				spriteUV[4], spriteUV[5],
				spriteUV[6], spriteUV[7]
			);
			
			// our size has changed, so we need to update the size
			invalidateVBO	= true;
			
			// return
			return sprite;
		}
		
		/**
		 * 	@private
		 */
		public function initializeContext(context:IDisplayContextGPU):void {
			
			if (!texture) {
				texture = context.requestTexture(sheet.width, sheet.height, false, Context3DTextureFormat.BGRA);
			}
			
			if (!shaderProg) {
				var assembler:AGALMiniAssembler = new AGALMiniAssembler();
				shaderProg = context.requestProgram(
					assembler.assemble( Context3DProgramType.VERTEX,
						"dp4 op.x, va0, vc0 \n"+ // transform from stream 0 to output clipspace
						"dp4 op.y, va0, vc1 \n"+ // do the same for the y coordinate
						"mov op.z, vc2.z    \n"+ // we don't need to change the z coordinate
						"mov op.w, vc3.w    \n"+ // unused, but we need to output all data
						"mov v0, va1.xy     \n"+ // copy UV coords from stream 1 to fragment program
						"mov v0.z, va0.z    \n"  // copy alpha from stream 0 to fragment program
					),
					assembler.assemble( Context3DProgramType.FRAGMENT,
						"tex ft0, v0, fs0 <2d,clamp,nearest,mipnone> \n" +
						"mul oc, ft0, v0.zzzz"	// multiply by alpha
					)
				)
			}
			
			texture.upload(sheet.data);
		}
		
		/**
		 * 	@private
		 */
		public function render(context:IDisplayContextGPU, matrix:Matrix3D):void {
			
			if (!children.length) {
				return;
			}
			
			// need to update
			
			// update the vertex buffers
			var currentIndex:int = 0;
			for each (var sprite:GPUSprite in children) {
				
				sprite.position.x		= Math.random() * sheet.width;
				sprite.position.y		= Math.random() * sheet.height;

				var vIndex:int			= currentIndex * 12;
				var x:Number			= sprite.position.x;
				var y:Number			= sprite.position.y;
				var rect:Rectangle		= sprite.rect;
				var sinT:Number			= Math.sin(0);
				var cosT:Number			= Math.cos(0);
				var alpha:Number		= 1.0;
				
				var scaledWidth:Number	= rect.width * sprite.scale.x;
				var scaledHeight:Number = rect.height * sprite.scale.y;
				var centerX:Number		= scaledWidth * 0.5;
				var centerY:Number		= scaledHeight * 0.5;
				
				vertex[vIndex] = x - (cosT * centerX) - (sinT * (scaledHeight - centerY));
				vertex[vIndex+1] = y - (sinT * centerX) + (cosT * (scaledHeight - centerY));
				vertex[vIndex+2] = alpha;
				
				vertex[vIndex+3] = x - (cosT * centerX) + (sinT * centerY);
				vertex[vIndex+4] = y - (sinT * centerX) - (cosT * centerY);
				vertex[vIndex+5] = alpha;
				
				vertex[vIndex+6] = x + (cosT * (scaledWidth - centerX)) + (sinT * centerY);
				vertex[vIndex+7] = y + (sinT * (scaledWidth - centerX)) - (cosT * centerY);
				vertex[vIndex+8] = alpha;
				
				vertex[vIndex+9] = x + (cosT * (scaledWidth - centerX)) - (sinT * (scaledHeight - centerY));
				vertex[vIndex+10] = y + (sinT * (scaledWidth - centerX)) + (cosT * (scaledHeight - centerY));
				vertex[vIndex+11] = alpha;
				
				++currentIndex;
			}
			
			// set prog
			context.bindProgram(shaderProg);
			
			// premultiplied
			context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, matrix, false);
			context.setTextureAt(0, texture);
			
			if (invalidateVBO) {
				
				iBuffer 	= context.createIndexBuffer(index.length);
				vBuffer		= context.createVertexBuffer(vertex.length / 3, 3);
				uvBuffer	= context.createVertexBuffer(uv.length / 2, 2);
				
				iBuffer.uploadFromVector(index, 0, index.length);
				uvBuffer.uploadFromVector(uv, 0, uv.length / 2);
				
				// invalidate
				invalidateVBO = false;
			}
			
			// upload the vertex buffer
			vBuffer.uploadFromVector(vertex, 0, vertex.length / 3);
			context.setVertexBufferAt(0, vBuffer, 0, Context3DVertexBufferFormat.FLOAT_3);
			context.setVertexBufferAt(1, uvBuffer, 0, Context3DVertexBufferFormat.FLOAT_2);
			context.drawTriangles(iBuffer, 0, children.length * 2);

		}
	}
}