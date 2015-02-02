package onyxui.assets {
	
	import flash.text.*;

	[Embed(
		source				='src/AvenirLTStd-Roman.otf',
		fontName			='UIPixelFont',
		advancedAntiAliasing='true',
		mimeType			='application/x-font',
		embedAsCFF			='true',
		unicodeRange		='U+0000-U+00FF'			// embed all 1 byte characters
	)]
	[ExcludeClass]
	final public class UIAssetPixelFont extends Font {
	}
}