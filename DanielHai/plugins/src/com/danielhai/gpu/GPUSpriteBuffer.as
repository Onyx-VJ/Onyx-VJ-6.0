package com.danielhai.gpu {
	
	import flash.display.*;
	import flash.geom.*;
	
	import onyx.core.*;
	import onyx.display.*;
	
	public final class GPUSpriteBuffer {

		/**
		 * 	@public
		 */
		private var matrix:Matrix	= new Matrix();
		
		/**
		 * 	@public
		 */
		private var surface:BitmapData;
		
		/**
		 * 	@public
		 */
		private var currentIndex:int;
		
		/**
		 * 	@private
		 */
		private var maxFrames:int;
		
		/**
		 * 	@private
		 */
		private var gridWidth:int;
		private var gridHeight:int;
		
		/**
		 * 	@private
		 */
		private var gridCols:int;
		private var gridRows:int;
		
		/**
		 * 	@public
		 */
		public function GPUSpriteBuffer(scale:Number = 0.5, maxFrames:int = -1):void {
			matrix.a		= matrix.d	= scale;
			this.maxFrames	= maxFrames;
		}
		
		/**
		 * 	@public
		 */
		public function initialize(context:IDisplayContextCPU):void {
			
			gridWidth			= context.width		* matrix.a;
			gridHeight			= context.height	* matrix.d;
			
			if (maxFrames === -1) {
				
				// automatically set maxframes -- based on texture size
				gridCols			= Math.floor(2048 / gridWidth);
				gridRows			= Math.floor(2048 / gridHeight);
				
				maxFrames			= gridCols * gridRows;
				surface				= new DisplaySurface(gridCols * gridWidth, gridRows * gridHeight, false, 0x00);

			}
		} 
		
		/**
		 * 	@public
		 */
		public function addFrame(channel:IChannelCPU):Boolean {
			
			var data:BitmapData = new BitmapData(gridWidth, gridHeight, false, 0x00);
			var p:Point			= new Point();
			p.x					= (currentIndex % gridCols) * gridWidth;
			p.y					= Math.floor(currentIndex / gridCols) * gridHeight;
			data.draw(channel.surface, matrix, null, null, null, true);
			
			// copy the pixels
			this.surface.copyPixels(data, data.rect, p);
			
			// should we stop?
			return (++currentIndex >= maxFrames);
		}
		
		/**
		 * 	@public
		 */
		public function createSheet():GPUSpriteSheet {
			var sheet:GPUSpriteSheet = new GPUSpriteSheet();
			sheet.initialize(this.surface, gridWidth, gridHeight);
			return sheet;
		}
	}
}