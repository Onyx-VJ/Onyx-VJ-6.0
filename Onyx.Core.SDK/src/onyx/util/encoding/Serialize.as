package onyx.util.encoding {
	
	import flash.system.*;

	final public class Serialize {
		
		/**
		 *	@private 
		 */
		private static const JSON_COMMENT:RegExp			= /\/\*([^\/]*)\*\//g;
		
		/**
		 * 	@public
		 */
		public static function toJSON(object:Object, formatted:Boolean = false, newLine:String = '\n'):String {
			return formatted ? format(JSON.stringify(object), newLine) : JSON.stringify(object);
		}
		
		/**
		 * 	@public
		 */
		public static function fromJSON(input:String):Object {
			try {
				var data:Object = JSON.parse(input.replace(JSON_COMMENT, ''));
				return data;
			} catch (e:Error) {
			}
			return null;
		}
		
		/**
		 * 	@public
		 */
		public static function replaceComments(input:String):String {
			return input.replace(JSON_COMMENT, '');
		}
		
		/**
		 * 	@public
		 */
		public static function tokenize(data:String):Object {
			
			const reg:RegExp 		= /\[(.+?)\]/g;
			const serialized:Object	= {};
			var match:Array;
			var token:String;
			var last:int;
			
			while (match = reg.exec(data)) {
				if (last) {
					serialized[token] = data.substr(last, reg.lastIndex - last - match[0].length);
				}
				
				token	= match[1];
				last	= reg.lastIndex;
			}
			serialized[token] = data.substr(last);
			
			// not valid
			if (!serialized['Plugin.Shader.Info'] || !serialized['Plugin.Shader.Vertex'] || !serialized['Plugin.Shader.Fragment']) {
				return null;
			}
			
			const obj:Object	= Serialize.fromJSON(serialized['Plugin.Shader.Info']);			
			
			// copy the shader data
			obj['Plugin.Shader.Vertex']		= serialized['Plugin.Shader.Vertex'];
			obj['Plugin.Shader.Fragment']	= serialized['Plugin.Shader.Fragment'];
			
			return obj;
		}
		
		/**
		 * 	@private
		 */
		private static function repeat(s:String, count:int):String {
			return new Array(count).join(s);
		}
		
		/**
		 * 	@private
		 */
		public static function format(json:String, newLine:String = '\n'):String {
			
			var i:int,
				il:int,
				tab:String      	= "\t",
				newJson:String  	= "",
				indentLevel:int		= 1,
				inString:Boolean,
				currentChar:String;
			
			for (i = 0, il = json.length; i < il; ++i) { 
				currentChar = json.charAt(i);
				switch (currentChar) {
					case '{': 
					case '[': 
						if (!inString) { 
							newJson += currentChar + newLine + repeat(tab, indentLevel + 1);
							indentLevel += 1; 
						} else { 
							newJson += currentChar; 
						}
						break; 
					case '}': 
					case ']': 
						if (!inString) { 
							indentLevel -= 1; 
							newJson += newLine + repeat(tab, indentLevel) + currentChar; 
						} else { 
							newJson += currentChar; 
						} 
						break; 
					case ',': 
						if (!inString) { 
							newJson += "," + newLine + repeat(tab, indentLevel); 
						} else { 
							newJson += currentChar; 
						} 
						break; 
					case ':': 
						if (!inString) { 
							newJson += ": "; 
						} else { 
							newJson += currentChar; 
						} 
						break; 
					case ' ':
					case "\n":
					case "\t":
						if (inString) {
							newJson += currentChar;
						}
						break;
					case '"': 
						if (i > 0 && json.charAt(i - 1) !== '\\') {
							inString = !inString; 
						}
						newJson += currentChar; 
						break;
					default: 
						newJson += currentChar; 
						break;                    
				} 
			} 
			
			return newJson; 
		}
		
		/**
		 * 	@public
		 */
		public static function fromMetaData(list:XMLList):Object {
			const token:Object	= {};
			for each (var arg:XML in list) {
				token[String(arg.@key)] = String(arg.@value);
			}
			return token;
		}
		
		CONFIG::DEBUG public function toJSON(object:Object):void {
			trace(Serialize.toJSON(object, true));
		}
	}
}