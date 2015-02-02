package onyx.plugin {
	
	import flash.display.*;
	import flash.system.*;
	import flash.utils.*;
	
	import onyx.core.*;
	import onyx.display.*;
	
	/**
	 * 	plugin types
	 */
	final public class Plugin {
		
		/**
		 * 	@public
		 */
		public static const SERIALIZE_ALL:uint					= 0xFFFFFFFF;
		
		/**
		 * 	@public
		 */
		public static const SERIALIZE_PARAMETERS:uint			= 0x00000001;
		
		/**
		 * 	@public
		 */
		public static const SERIALIZE_BINDINGS:uint				= 0x00000002;
		
		/**
		 * 	@public
		 */
		public static const CPU:uint							= 0x00;
		
		/**
		 * 	@public
		 */
		public static const GPU:uint							= 0x01;
		
		/**
		 * 	@public
		 */
		public static const HOST:uint							= 0x00;	// host
		public static const PROTOCOL:uint						= 0x01;	// protocols 
		public static const MODULE:uint							= 0x02;	// in memory running modules
		public static const INTERFACE:uint						= 0x03;	// also an interface
		public static const DISPLAY:uint						= 0x04;	// display-based (channels, layers, etc, whatever else)
		
		public static const MACRO:uint							= 0x06;	// keyboard macro
		public static const GENERATOR:uint						= 0x07;	// generators
		public static const PLAYMODE:uint						= 0x08;	// time playmode
		
		/**
		 * 	@public	Fonts
		 */
		public static const FONT:uint							= 0x09;
		
		/**
		 * 	@public
		 * 	Plugins that can alter matrices
		 */
		public static const TRANSFORM:uint						= 0x0A;	// transform
		
		/**
		 * 	@public	Plugins that alter bitmap/texture information
		 */
		public static const FILTER:uint							= 0x0B;	// surface filters
		
		/**
		 * 	@public	Plugins that blend 2 channels together
		 */
		public static const BLENDMODE:uint						= 0x0C;

	}
}