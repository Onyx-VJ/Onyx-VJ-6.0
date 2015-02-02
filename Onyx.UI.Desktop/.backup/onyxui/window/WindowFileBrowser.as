package onyxui.window {
	
	import flash.display.*;
	import flash.events.*;
	import flash.utils.*;
	
	import onyx.core.*;
	import onyx.data.*;
	import onyx.display.*;
	import onyx.plugin.*;
	import onyx.util.*;
	
	import onyxui.parameter.*;
	import onyxui.core.*;
	import onyxui.interaction.*;
	import onyxui.window.browser.*;
	import onyxui.window.layer.*;
	
	public final class WindowFileBrowser extends UIWindow {
		
		/**
		 * 	@private
		 */
		private static const FILTER:Callback	= new Callback(function(hash:Object, ref:IFileReference):Boolean {
			return ref.isDirectory || hash[ref.extension] !== undefined;
		}, [{
			jpg:	true,
			swf:	true,
			flv:	true,
			f4v:	true,
			onx:	true,
			mp4:	true,
			png:	true
		}]);
		
		/**
		 * 	@private
		 */
		private const button:UIButton			= new UIButton('Files');
		
		/**
		 * 	@private
		 */
		private const hash:Dictionary			= new Dictionary(true);
		
		/**
		 * 	@private
		 */
		private const protoButtons:Vector.<UIProtocolControl>	= new Vector.<UIProtocolControl>();
		
		/**
		 * 	@private
		 */
		private var filePane:UIScrollPane;
		private var dirsPane:UIScrollPane;
		
		/**
		 * 	@public
		 */
		override public function initialize():void {
			
			// create children and stuff
			super.initialize();
			
			// init
			filePane	= getChild('filePane');
			dirsPane	= getChild('dirsPane');
			dirsPane.setGridSize(135, 25);
			
			// query?
			query(FileSystem.GetFileReference('/library'));
			
			// add
			addProtocolButtons();
			
		}
		
		/**
		 * 	@private
		 */
		private function addProtocolButtons():void {
			
			var p:UIProtocolControl = new UIProtocolControl('Library');
			var y:int				= bounds.height - 22;
			var x:int				= 4;
			
			p.resize(100,18);
			p.moveTo(x, y);
			addChild(p);
			
			// push
			protoButtons.push(p);
			
			var protocols:Vector.<IPluginProtocol> = FileSystem.EnumerateProtocols(Plugin.PROTOCOL);
			for each (var protocol:IPluginProtocol in protocols) {
				
				x += 102;
				p = new UIProtocolControl(protocol.name, protocol);
				p.resize(100,18);
				p.moveTo(x, y);
				addChild(p);
				protoButtons.push(p);
			}
			
			for each (p in protoButtons) {
				p.addEventListener(MouseEvent.CLICK, handleProto);
			}
		}
		
		/**
		 * 	@private
		 */
		private function handleProto(e:MouseEvent):void {
			const p:UIProtocolControl = e.currentTarget as UIProtocolControl;
			if (p.protocol) {
				p.protocol.query(null, new Callback(handleFiles, [null]));
			} else {
				// query?
				query(FileSystem.GetFileReference('/library'));
			}
		}
		
		/**
		 * 	@private
		 */
		private function query(ref:IFileReference):void {
			
			// query default
			FileSystem.Query(ref, new Callback(handleFiles, [ref]));
			
		}
		
		/**
		 * 	@private
		 */
		private function queryProtocol():void {
			
		}
		
		/**
		 * 	@private
		 */
		private function handleFiles(ref:IFileReference, list:Vector.<IFileReference>):void {
			
			// remove
			removeListeners();
			
			// add a file up?
			if (ref && ref.getParent()) {
				control = new UIFileControl(ref.getParent());
				control.addEventListener(MouseEvent.CLICK,		handleMouse);
				dirsPane.addChild(control);
			}
			
			var control:UIFileControl;
			
			for each (var file:IFileReference in list) {
				
				control = new UIFileControl(file);
				if (file.isDirectory) {
					control.addEventListener(MouseEvent.CLICK,		handleMouse);
					dirsPane.addChild(control);
				} else {
					control.addEventListener(MouseEvent.MOUSE_DOWN, handleMouse);
					filePane.addChild(control);
				}
			}
			
		}
		
		/**
		 * 	@private
		 */
		private function removeListeners():void {
			const children:Array = filePane.getChildren().concat(dirsPane.getChildren());
			for each (var control:UIFileControl in children) {
				control.removeEventListener(MouseEvent.CLICK,		handleMouse);
				control.removeEventListener(MouseEvent.MOUSE_DOWN,	handleMouse);
			}
			
			filePane.remChildren();
			dirsPane.remChildren();
		}
		
		/**
		 * 	@private
		 */
		private function handleMouse(e:MouseEvent):void {
			
			const control:UIFileControl = e.currentTarget as UIFileControl;
			switch (e.type) {
				case MouseEvent.CLICK:
					query(control.file);
					break;
				case MouseEvent.MOUSE_DOWN:
					
					const window:WindowLayer = OnyxUI.GetWindow('WindowLayer') as WindowLayer;
					if (window) {
						DragManager.start(e.currentTarget as UIObject, e, window.getControls(), new Callback(handleDrag, [control]));
					}
					
					break;
			}
		}
		
		/**
		 * 	@private
		 */
		private function handleDrag(control:UIFileControl, layer:UILayer):void {
			layer.layer.load(control.file, {});
		}
		
		/**
		 * 	@public
		 */
		override public function dispose():void {
			
			for each (var p:UIProtocolControl in protoButtons) {
				p.removeEventListener(MouseEvent.CLICK, handleProto);
			}
			
			super.dispose();
		}
	}
}