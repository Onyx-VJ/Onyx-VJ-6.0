package {
	
	import flash.utils.*;

	final public class FLVTagReader {
		
		/**
		 * 	@public
		 */
		public function analyze(data:ByteArray):Vector.<FLVTag> {
			
			const tags:Array = [];
			
			readHeader(data);
			
			var index:uint;
			
			while (data.position < data.length - 4) {
				tags.push(readTag(index++, data));
			}
			
			return Vector.<FLVTag>(tags);
		}
		
		/**
		 * 	@private
		 */
		private function readHeader(data:ByteArray):void {
			
			data.position		= 0;
			data.endian			= Endian.BIG_ENDIAN;
			
			var tag:String		= data.readUTFBytes(3);			// FLV
			var version:uint	= data.readUnsignedByte();		// version=1
			var flags:uint		= data.readUnsignedByte();		// flags =?
			var length:uint		= data.readUnsignedInt();		// length=11

		}
		
		/**
		 * 	@private
		 */
		private function readTag(index:uint, data:ByteArray):FLVTag {
			
			var previousTagSize:uint	= data.readUnsignedInt();

			// TAG BOUNDARIES
			// byte 0:	tag
			// byte 1,2,3:	size
			// byte 4-5-6:  stamp
			var position:uint			= data.position;
			
			var tag:uint				= data.readUnsignedByte();				// 0
			var type:uint				= tag & 0x000FFFFF;
			
			var size:uint				= data.readUnsignedByte() << 16 | data.readUnsignedByte() << 8 | data.readUnsignedByte();		// 6-8
			var stamp:uint				= data.readUnsignedByte() << 16 | data.readUnsignedByte() << 8 | data.readUnsignedByte();		// 9-11
			var ext:uint				= data.readUnsignedByte();
			var streamID:uint			= data.readUnsignedByte() << 16 | data.readUnsignedByte() << 8 | data.readUnsignedByte();		// always 0?
			var flags:uint				= 0x00;
			
			// our size is a lot bigger
			if (ext > 0) {
				throw new Error('LARGE FRAMES UNHANDLED');
			}
			
			switch (type) {
				case FLVTag.VIDEO:
					
					var codec:uint				= data.readByte();
					var codecid:uint			= (codec & 0x0F) >> 0;
					flags						= (codec & 0xF0) >> 4
					
					if (false && index < 15) {
						trace(	
							'\nTAG:\t\t', 			index,
							'\nPosition:\t',		position,
							'\nSize:\t\t', 			size,
							'\nPrevious Size:\t',	previousTagSize,
							'\nType:\t\t', 			type,
							'\nFlag:\t\t', 			flags
						);
					}
					
					// minus 1, because we read a byte
					data.position				+= (size - 1);
					
					break;
				default:
					
					data.position				+= size;
					
					break;
			}

			// return
			return new FLVTag(index, type, position, size + 11, flags);
		}
	}
}