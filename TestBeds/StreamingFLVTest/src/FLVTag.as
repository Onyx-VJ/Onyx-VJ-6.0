package {
	
	import flash.display.*;
	import flash.utils.*;
	
	public final class FLVTag {
		
		public static const AUDIO:uint			= 8;
		public static const VIDEO:uint			= 9;
		public static const SCRIPT:uint			= 18;
		
		public static const FRAMETYPE_MASK:uint		= 0xFFFFFFFF;
		public static const FLAG_KEYFRAME:uint		= 0x00000001;
		public static const FLAG_INTERFRAME:uint	= 0x00000002;
		
		private static const blockWidth:int = 32;
		private static const blockHeight:int = 32;
		
		private static function writeUI4_12(stream:IDataOutput, p1:uint, p2:uint):void {
			
			// writes a 4-bit value followed by a 12-bit value in two sequential bytes
			
			var byte1a:int = p1 << 4;
			var byte1b:int = p2 >> 8;
			var byte1:int = byte1a + byte1b;
			var byte2:int = p2 & 0xff;
			
			stream.writeByte(byte1);
			stream.writeByte(byte2);
		}
		
		private static function writeUI16(stream:IDataOutput, p:uint):void {
			stream.writeByte( p >> 8 )
			stream.writeByte( p & 0xff );                   
		}
		
		public static function createVideoData(b:BitmapData):ByteArray {
			
			var v:ByteArray = new ByteArray;
			
			const frameWidth:int	= b.width;
			const frameHeight:int	= b.height;
			
			// VIDEODATA 'header'
			v.writeByte(0x13); // frametype (1) + codecid (3)
			
			// SCREENVIDEOPACKET 'header'                   
			// blockwidth/16-1 (4bits) + imagewidth (12bits)
			writeUI4_12(v, int(blockWidth/16) - 1,  frameWidth);
			// blockheight/16-1 (4bits) + imageheight (12bits)
			writeUI4_12(v, int(blockHeight/16) - 1, frameHeight);                   
			
			// VIDEODATA > SCREENVIDEOPACKET > IMAGEBLOCKS:
			
			var yMax:int = int(frameHeight/blockHeight);
			var yRemainder:int = frameHeight % blockHeight; 
			if (yRemainder > 0) yMax += 1;
			
			var xMax:int = int(frameWidth/blockWidth);
			var xRemainder:int = frameWidth % blockWidth;                           
			if (xRemainder > 0) xMax += 1;
			
			for (var y1:int = 0; y1 < yMax; y1++) {
				
				for (var x1:int = 0; x1 < xMax; x1++)  {
					// create block
					var block:ByteArray = new ByteArray();
					
					var yLimit:int = blockHeight;   
					if (yRemainder > 0 && y1 + 1 == yMax) {
						yLimit = yRemainder;
					}
					
					for (var y2:int = 0; y2 < yLimit; y2++)  {
						
						var xLimit:int = blockWidth;
						if (xRemainder > 0 && x1 + 1 == xMax) {
							xLimit = xRemainder;
						}
						
						for (var x2:int = 0; x2 < xLimit; x2++)  {
							var px:int = (x1 * blockWidth) + x2;
							var py:int = frameHeight - ((y1 * blockHeight) + y2); // (flv's save from bottom to top)
							var p:uint = b.getPixel(px, py);
							
							//problem point..
							block.writeByte( p & 0xff );            // blue 
							block.writeByte( p >> 8 & 0xff );       // green
							block.writeByte( p >> 16 );             // red
							//..problem point
						}
					}
					block.compress();
					
					writeUI16(v, block.length); // write block length (UI16)
					v.writeBytes( block ); // write block
				}
			}
			
			b.dispose()
			return v;
		}
		
		/**
		 * 	@public
		 */
		public var type:uint;
		
		/**
		 * 	@public
		 */
		public var length:uint;
		
		/**
		 * 	@public
		 */
		public var position:uint;
		
		/**
		 * 	@public
		 */
		public var flags:uint;
		
		/**
		 * 	@public
		 */
		public var index:uint;
		
		/**
		 * 	@public
		 */
		public function FLVTag(index:uint, type:uint, position:uint, length:uint, flags:uint = 0x00):void {
			this.index		= index;
			this.type		= type;
			this.position	= position;
			this.length		= length;
			this.flags		= flags;
		}
		
		public function toString():String {
			return '[Tag:' + type + ', position:' + position + ', length: ' + length + ']';
		}
	}
}


//						case FLVTag.FLAG_INTERFRAME:
//							
//							bytes.writeBytes(videoBytes, tag.position, tag.length);
//							bytes.position	= 0;
//							
//							trace('type', bytes.readUnsignedByte());
//							trace('size', bytes.readUnsignedByte() << 16 | bytes.readUnsignedByte() << 8 | bytes.readUnsignedByte());
//							trace('stamp', bytes.readUnsignedByte() << 16 | bytes.readUnsignedByte() << 8 | bytes.readUnsignedByte());
//							trace('ext', bytes.readUnsignedByte());
//							trace('streamID', bytes.readUnsignedByte() << 16 | bytes.readUnsignedByte() << 8 | bytes.readUnsignedByte());
//							
//							// ok header starts
//							var codec:uint				= bytes.readByte();
//							trace('codecid', 	(codec & 0x0F) >> 0);
//							trace('frametype',	(codec & 0xF0) >> 4);
//							
//							var adjust:uint				= bytes.readByte();
//							trace('adjusth', 	(adjust & 0x0F) >> 0);
//							trace('adjustv',	(adjust & 0xF0) >> 4);
//							
//							trace(bytes.readByte().toString(16));
//							trace(bytes.readByte().toString(16));
//							
//							// trace('column', bytes.readUnsignedInt());
//							// trace('row', bytes.readDouble());
//							
//							// the rest
//							while (bytes.position < bytes.length - 4) {
//								trace(bytes.position, pad(bytes.readUnsignedInt().toString(16)));
//							}
////							
////							var adjust:uint				= bytes.readByte();
////							trace('horiz', 	(adjust & 0x0F) >> 0);
////							trace('vert', (adjust & 0xF0) >> 4);
////							
////							trace(bytes.position, bytes.readUnsignedInt().toString(16));
//							
//							// goto exit;