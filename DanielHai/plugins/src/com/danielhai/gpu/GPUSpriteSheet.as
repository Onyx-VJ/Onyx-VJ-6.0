package com.danielhai.gpu {
	
	import flash.display.*;
	import flash.display3D.textures.*;
	import flash.geom.*;

	final public class GPUSpriteSheet {

		/**
		 * 	@private
		 */
		public var data:BitmapData;
		
		/**
		 * 	@private
		 */
		private const coords:Vector.<Number>	= new Vector.<Number>();
		
		/**
		 * 	@private
		 */
		private const rect:Vector.<Rectangle>	= new Vector.<Rectangle>();
		
		/**
		 * 	@private
		 */
		private var texture:Texture;
		
		/**
		 * 	@public
		 */
		public var width:int;
		
		/**
		 * 	@public
		 */
		public var height:int;
		
		/**
		 * 	@public
		 */
		public var length:int;
		
		/**
		 * 	@public
		 */
		public function initialize(data:BitmapData, gridWidth:int, gridHeight:int):void {
			
			this.data			= data;
			
			// initialize the grids
			const bmpw:int		= width		= data.width;
			const bmph:int		= height	= data.height;
			
			const cols:int		= bmpw / gridWidth; 
			const rows:int		= bmph / gridHeight;
			const length:int	= cols * rows;
			
			coords.length		= length * 8;
			rect.length			= length;
			this.length			= length;
			
			for (var index:int	= 0; index < length; ++index) {
				
				var xMin:Number		= ((index % cols) * gridWidth) / bmpw;
				var xMax:Number		= (((index % cols) + 1) * gridWidth) / bmpw;
				
				var yMin:Number		= (Math.floor(index / cols) * gridHeight) / bmph;
				var yMax:Number		= ((Math.floor(index / cols) + 1) * gridHeight) / bmph;
				var offset:uint		= index * 8;
				
				//BL
				coords[offset]		= xMin;
				coords[offset+1]	= yMax;
				
				//TL
				coords[offset+2]	= xMin;
				coords[offset+3]	= yMin;
				
				//TR
				coords[offset+4]	= xMax;
				coords[offset+5]	= yMin;
				
				//BR
				coords[offset+6]	= xMax;
				coords[offset+7]	= yMax;
				
				// rect
				rect[index]			= new Rectangle(0, 0, gridWidth, gridHeight);
				
			}
		}
		
		/**
		 * 	@public
		 */
		public function getRect(index:int):Rectangle {
			return rect[index];
		}
		
		/**
		 * 	@private
		 */
		public function getUVCoords(sprite:GPUSprite):Vector.<Number> {
			const position:int	= sprite.index * 8;
			return coords.slice(position, position + 8);
		}
	}
}