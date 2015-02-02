package {
	
	import avmplus.*;
	
	import com.adobe.utils.AGALMiniAssembler;
	
	import flash.display.*;
	
	import onyx.core.*;
	import onyx.display.*;
	import onyx.event.*;
	import onyx.host.gl.PluginGLHost;
	import onyx.media.*;
	import onyx.parameter.*;
	import onyx.plugin.*;
	import onyx.protocol.filesystem.*;
	import onyx.service.*;
	import onyx.util.*;
	import onyx.util.encoding.*;
	import onyx.util.filesystem.*;
	import onyx.util.geom.*;
	import onyx.util.metadata.*;
	import onyx.util.tween.*;
	
	import onyxui.screens.*;
	import onyxui.state.*;

	[PluginInfo(manifest='onyx.protocol.filesystem::FileSystemProtocol;onyx.host.gl.PluginGLHost;')]
	
	final public class OnyxCore extends Sprite {

		
		// Core Onyx Classes
		Onyx;
		
		// FileSystem
		FileSystem;
		FileSystemProtocol;
		
		// glhost
		PluginGLHost;
		
		//
		InitScreen;
		
		// debug!
		CONFIG::DEBUG { Debug; }
		
		// agal!
		com.adobe.utils.AGALMiniAssembler;
		
		// avmplus.describeClass;
		// avmplus.describeObject;
		onyx.core.Console
		onyx.core.FileSystem
		onyx.core.IDisplay
		onyx.core.IDisplayCPU
		onyx.core.IDisplayChannel
		onyx.core.IDisplayContext
		onyx.core.IDisplayContextCPU
		onyx.core.IDisplayContextGPU
		onyx.core.IDisplayContextGPUBuffer
		onyx.core.IDisplayGPU
		onyx.core.IDisplayLayer
		onyx.core.IDisplayProgramGPU
		onyx.core.IDisplayScreen
		onyx.core.IDisplayWindow
		onyx.core.IDisposable
		onyx.core.IFileReference
		onyx.core.IFileStream
		onyx.core.IMediaStream
		onyx.core.IOnyxHost
		onyx.core.IPlugin
		onyx.core.IPluginBlend
		onyx.core.IPluginBlendCPU
		onyx.core.IPluginBlendGPU
		onyx.core.IPluginCPU
		onyx.core.IPluginDefinition
		onyx.core.IPluginFileProtocol
		onyx.core.IPluginFilter
		onyx.core.IPluginFilterCPU
		onyx.core.IPluginFilterGPU
		onyx.core.IPluginGPU
		onyx.core.IPluginGenerator
		onyx.core.IPluginHost
		onyx.core.IPluginMacro
		onyx.core.IPluginModule
		onyx.core.IPluginModuleInterface
		onyx.core.IPluginPlayMode
		onyx.core.IPluginProtocol
		onyx.core.ISerializable
		onyx.core.ISharedCache
		onyx.core.InterfaceBinding
		onyx.core.InterfaceMessage
		onyx.core.Onyx
		onyx.core.TimeStamp
		onyx.core.VERSION
		onyx.core.onyx_ns
		onyx.core.parameter
		onyx.display.CONST_IDENTITY
		onyx.display.CONST_RECT
		onyx.display.Color
		onyx.display.Dimensions
		onyx.display.ContentTransform
		onyx.display.DisplaySurface
		onyx.display.LayerTime
		onyx.display.DisplayTexture
		//onyx.display.utils.SurfaceBuffer
		onyx.event.DataEvent
		onyx.event.EventBinding
		onyx.event.InteractionEvent
		onyx.event.InterfaceMessageEvent
		onyx.event.OnyxEvent
		onyx.event.ParameterEvent
		onyx.event.PluginStatusEvent
		onyx.media.MediaStream
		onyx.parameter.IParameter
		onyx.parameter.IParameterExecutable
		onyx.parameter.IParameterIterator
		onyx.parameter.IParameterNumeric
		onyx.parameter.IParameterObject
		onyx.parameter.Parameter
		onyx.parameter.ParameterBase
		onyx.parameter.ParameterList
		onyx.plugin.Plugin;
		onyx.plugin.PluginBase;
		onyx.plugin.PluginBlendGPU;
		onyx.plugin.PluginData;
		onyx.plugin.PluginDomain;
		onyx.plugin.PluginFilterBase;
		onyx.plugin.PluginFilterCPU;
		onyx.plugin.PluginFilterGPU;
		onyx.plugin.PluginGenerator;
		onyx.plugin.PluginGeneratorTransformCPU;
		onyx.plugin.PluginInterfaceContext;
		onyx.plugin.PluginModule;
		onyx.plugin.PluginPatchCPU;
		onyx.plugin.PluginPatchGPU;
		onyx.plugin.PluginPatchTransformCPU;
		onyx.plugin.PluginPatchTransformGPU;
		onyx.plugin.PluginStatus;
		onyx.service.IThumbnailService;
		onyx.service.IRecordService;
		onyx.util.Callback;
		onyx.util.Delay;
		CONFIG::DEBUG { onyx.util.GC; }
		onyx.util.GUID;
		onyx.util.Initializer;
		onyx.util.ObjectUtil;
		onyx.util.PriorityQueue;
		onyx.util.SharedCache;
		onyx.util.SimpleCache;
		onyx.util.StringUtil;
		onyx.util.tween.Easing;
		onyx.util.encoding.Base64
		onyx.util.encoding.Serialize
		onyx.util.filesystem.RecursiveQuery
		onyx.util.geom.GeomUtil
		onyx.util.metadata.MetaDataUtil
		onyx.util.tween.Tween
	}
}