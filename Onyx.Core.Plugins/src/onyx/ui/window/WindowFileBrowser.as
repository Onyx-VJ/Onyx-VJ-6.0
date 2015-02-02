package onyx.ui.window {
	
	import flash.display.*;
	import flash.events.*;
	import flash.utils.*;
	
	import onyx.core.*;
	import onyx.display.*;
	import onyx.plugin.*;
	import onyx.service.IThumbnailService;
	import onyx.ui.component.*;
	import onyx.ui.core.*;
	import onyx.ui.factory.UIFactory;
	import onyx.ui.interaction.*;
	import onyx.ui.window.browser.*;
	import onyx.ui.window.layer.*;
	import onyx.util.*;
	import onyx.util.encoding.Serialize;
	
	use namespace skinPart;
	
	[UIComponent(
		id		= 'Onyx.UI.Desktop.FileBrowser',
		title	= 'FILE BROWSER'
	)]
	
	[UISkinPart(id='dirsPane',	type='scrollPane')]
	[UISkinPart(id='filePane',	type='scrollPane')]
	
	public final class WindowFileBrowser extends UIContainer {
		
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
		private const hash:Dictionary							= new Dictionary(true);
		
		/**
		 * 	@private
		 */
		private const protoButtons:Vector.<UIButton>			= new Vector.<UIButton>();
		
		/**
		 * 	@private
		 */
		private const fileFactory:IFactory						= new UIFactory(UIFileControl);
		
		/**
		 * 	@private
		 */
		private const dirFactory:IFactory						= new UIFactory(UIDirControl);
		
		/**
		 * 	@public
		 */
		skinPart var filePane:UIScrollPane;
		skinPart var dirsPane:UIScrollPane;
		
		/**
		 * 	@public
		 */
		public var currentPath:IFileReference;
		
		/**
		 * 	@public
		 */
		override public function initialize(data:Object):void {
			
			// create children and stuff
			super.initialize(data);
			
			// set the grid size
			filePane.setGridSize(112, 63);
			dirsPane.setGridSize(112, 20);
			
			// query?
			query(FileSystem.GetFileReference('/library'));
			
			// add
			addProtocolButtons();

		}
		
		/**
		 * 	@public
		 */
		public function update():void {
			query(currentPath);
		}
		
		/**
		 * 	@private
		 */
		private function addProtocolButtons():void {
			
			var factory:UIFactory	= new UIFactory(UIButton);
			var button:UIButton		= factory.createInstance();
			addChild(button);
			button.text				= 'Library';
			button.data				= FileSystem.GetFileReference('/library');
			protoButtons.push(button);
		
			var protocols:Vector.<IPluginProtocol> = FileSystem.EnumerateProtocols(Plugin.PROTOCOL);
			for each (var protocol:IPluginProtocol in protocols) {
				button 					= factory.createInstance();
				protoButtons.push(addChild(button));
				
				button.text				= protocol.name;
				button.data				= protocol;
			}
			
			for each (button in protoButtons) {
				button.addEventListener(MouseEvent.CLICK, handleProto);
			}
		}
		
		override public function arrange(rect:UIRect):void {
			
			super.arrange(rect);
			
			var buttonRect:UIRect	= new UIRect(0, rect.height - 16, 100, 16);
			for each (var button:UIButton in protoButtons) {
				button.arrange(buttonRect);
				buttonRect.x += 102;
			}
		}
		
		
		/**
		 * 	@private
		 */
		private function handleProto(e:MouseEvent):void {
			
			const p:UIButton = e.currentTarget as UIButton;
			if (p.data is IPluginProtocol) {
				p.data.query(null, new Callback(handleFiles, [null]));
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
			FileSystem.Query(currentPath = ref, new Callback(handleFiles, [ref]));
			
		}
		
		/**
		 * 	@private
		 */
		private function handleFiles(ref:IFileReference, list:Vector.<IFileReference>):void {
			
			// remove
			removeListeners();
			
			// add a file up?
			if (ref && ref.getParent()) {
				
				dirControl = dirFactory.createInstance();
				dirsPane.addChild(dirControl);
				
				dirControl.addEventListener(MouseEvent.CLICK,		handleMouse);
				dirControl.file	= ref.getParent();
				
			}
			
			var service:IThumbnailService	= Onyx.GetModule('Onyx.Service.ThumbnailService') as IThumbnailService;
			var callback:Callback			= new Callback(handleThumbnail);
			for each (var file:IFileReference in list) {

				if (file.isDirectory) {
					
					var dirControl:UIDirControl = dirFactory.createInstance();
					dirsPane.addChild(dirControl);
					dirControl.addEventListener(MouseEvent.CLICK,	handleMouse);
					dirControl.file = file;
					
				} else {
					
					var fileControl:UIFileControl = fileFactory.createInstance();
					filePane.addChild(fileControl);
					
					fileControl.addEventListener(MouseEvent.MOUSE_DOWN, handleMouse);
					fileControl.file = file;
					
					hash[file] = fileControl;
					
					if (service && file.path.substr(0, 8) === '/library') {
						service.readThumbnail('library', file, callback)
					}
				}
			}
		}
		
		/**
		 * 	@private
		 */
		private function handleThumbnail(file:IFileReference, data:BitmapData):void {
			var control:UIFileControl	= hash[file];
			if (control) {
				control.thumbnail.data = data;
			}
		}
		
		/**
		 * 	@private
		 */
		private function removeListeners():void {
			
			var children:Array = filePane.getChildren();
			if (children.length) {
				for each (var fileControl:UIFileControl in children) {
					fileControl.removeEventListener(MouseEvent.CLICK,		handleMouse);
					fileControl.removeEventListener(MouseEvent.MOUSE_DOWN,	handleMouse);
					delete hash[fileControl.file];
				}
				
				filePane.clearChildren();
			}

			children = dirsPane.getChildren();
			if (children.length) {
				for each (var dirControl:UIDirControl in children) {
					dirControl.removeEventListener(MouseEvent.CLICK,		handleMouse);
					dirControl.removeEventListener(MouseEvent.MOUSE_DOWN,	handleMouse);
				}
				dirsPane.clearChildren();
			}
		}
		
		/**
		 * 	@private
		 */
		private function handleMouse(e:MouseEvent):void {
			
			switch (e.type) {
				case MouseEvent.CLICK:
					
					query((e.currentTarget as UIDirControl).file);
					
					break;
				case MouseEvent.MOUSE_DOWN:
					
					// start drag
					DragManager.startDrag(DragManager.GENERATOR, (e.currentTarget as UIFileControl).file, e);
				
					break;
			}
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