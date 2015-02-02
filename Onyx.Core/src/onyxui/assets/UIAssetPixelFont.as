package onyxui.assets {
	
	import flash.text.*;

	[Embed(
		source				='src/AvenirLTStd-Roman.otf',
		fontName			='UIPixelFont',
		advancedAntiAliasing='false',
		mimeType			='application/x-font',
		embedAsCFF			='false',
		unicodeRange		='U+0000-U+00FF'			// embed all 1 byte characters
	)]
	final public class UIAssetPixelFont extends Font {
	}
}