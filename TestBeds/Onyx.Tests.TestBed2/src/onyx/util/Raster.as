package onyx.util {
	
	import flash.display.*;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	public class Raster {
		
		public static function text(target:BitmapData, text:String, format:TextFormat):void {
			const field:TextField	= new TextField();
			field.defaultTextFormat	= format;
			field.text = text;
			target.draw(field);
		}
	}
}