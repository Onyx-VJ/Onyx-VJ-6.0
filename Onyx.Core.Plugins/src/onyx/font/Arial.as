package onyx.font {
	
	import flash.text.*;
	
	[PluginInfo(
		id			= 'Onyx.Font.Arial',
		name		= 'Onyx.Font.Arial',
		vendor		= 'Daniel Hai',
		version		= '1.0'
	)]

	[Embed(
		source				='c:\\windows\\fonts\\Arial.ttf',
		fontName			='Onyx.Font.Arial',
		advancedAntiAliasing='true',
		mimeType			='application/x-font',
		embedAsCFF			='false',
		unicodeRange		='U+0020-007E' // embed all 1 byte characters
	)]
	
	final public class Arial extends Font {
	}
}