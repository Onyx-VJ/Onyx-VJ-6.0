package onyx.util {
	
	public class Tokenizer {
		
		/**
		 * 	@private
		 * 	Tokenizes a text file into usable
		 */
		public static function tokenize(data:String):Object {
			
			const reg:RegExp 		= /\[(.+?)\]/g;
			const serialized:Object	= {};
			var match:Array;
			var token:String;
			var last:int;
			
			// look for tokens
			while (match = reg.exec(data)) {
				if (last) {
					serialized[token] = data.substr(last, reg.lastIndex - last - match[0].length);
				}
				
				token	= match[1];
				last	= reg.lastIndex;
			}
			serialized[token] = data.substr(last);
			
			// not valid
			if (!serialized['Plugin.Shader.Vertex'] || !serialized['Plugin.Shader.Fragment']) {
				return null;
			}
			
			return serialized;
		}
	}
}