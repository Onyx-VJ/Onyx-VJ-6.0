package onyx.ui.component {

	import flash.events.*;
	import flash.text.*;
	
	import onyx.ui.core.*;
	
	use namespace skinPart;
	
	[UIComponent(id='text', thickness='-100')]
	
	public final class UITextField extends UIObject {
		
		/**
		 * 	@private
		 */
		skinPart const label:TextField		= addChild(new TextField()) as TextField;
		
		/**
		 * 	@private
		 */
		override public function initialize(data:Object):void {
			const format:TextFormat			= UIStyleManager.createDefaultTextFormat(data.color !== undefined ? data.color : 0xFFFFFF, data.textAlign || 'left');
			
			// init text?
			if (data.size) {
				format.size = data.size;
			}
			
			label.embedFonts				= true;
			label.gridFitType				= GridFitType.PIXEL;
			label.antiAliasType				= AntiAliasType.ADVANCED;
			label.mouseEnabled				= false;
			label.wordWrap					= data.wordWrap === undefined ? false : data.wordWrap;
			label.selectable				= false;
			label.thickness					= data.thickness || 0;
			label.defaultTextFormat			= format;
			
			mouseEnabled					= false;
			
			// init
			super.initialize(data);
			
			// init text?
			if (data.border !== undefined) {
				label.borderColor	= uint(data.border);
				label.border		= true;
			}
			
			// init text?
			if (data.background !== undefined) {
				label.backgroundColor	= uint(data.background);
				label.background		= true;
			}
			
			// init text?
			if (data.text !== undefined) {
				label.text = data.text;
			}
			
			if (data.editable !== undefined) {
				this.editable = data.editable;
			}
		}
		
		/**
		 * 	@public
		 */
		public function set textAlign(value:String):void {
			var format:TextFormat	= label.defaultTextFormat;
			format.align = value;
			label.setTextFormat(format);
			label.defaultTextFormat = format;
			
		}
		
		/**
		 * 	@public
		 */
		public function get textAlign():String {
			return label.defaultTextFormat.align;
		}
		
		/**
		 * 	@public
		 */
		public function set editable(value:Boolean):void {
			label.type	= value ? TextFieldType.INPUT : TextFieldType.DYNAMIC;
			label.selectable	= value;
			label.mouseEnabled	= value;
			label.addEventListener(Event.CHANGE, dispatchEvent);
		}
		
		/**
		 * 	@public
		 */
		public function get length():int {
			return label.length;
		}
		
		/**
		 * 	@public
		 */
		public function get editable():Boolean {
			return label.type === TextFieldType.INPUT;
		}
		
		/**
		 * 	@public
		 */
		public function set multiline(value:Boolean):void {
			label.multiline	= value;
		}
		
		/**
		 * 	@public
		 */
		public function get multiline():Boolean {
			return label.multiline;
		}
		
		/**
		 * 	@public
		 */
		public function setFocus():void {
			stage.focus = label;
		}
		
		/**
		 * 	@public
		 */
		public function set defaultTextFormat(value:TextFormat):void {
			label.defaultTextFormat	= value;
		}
		
		/**
		 * 	@public
		 */
		public function get defaultTextFormat():TextFormat {
			return label.defaultTextFormat;
		}
		
		/**
		 * 	@public
		 */
		public function appendText(value:String):void {
			label.appendText(value);
		}
		
		/**
		 * 	@public
		 */
		public function get scrollV():int {
			return label.scrollV;
		}
		
		/**
		 * 	@public
		 */
		public function scrollMax():void {
			label.scrollV = label.maxScrollV;
		}

		/**
		 * 	@public
		 */
		override public function arrange(bounds:UIRect):void {
			
			// arrange
			super.arrange(bounds);
			
			// set width/height
			label.width		= bounds.width;
			label.height	= bounds.height;

		}
		
		/**
		 * 	@public
		 */
		public function set text(value:String):void {
			label.text = value || '';
		}
		
		public function set textColor(value:uint):void {
			label.textColor	= value;
		}
		
		/**
		 * 	@public
		 */
		public function get text():String {
			return label.text;
		}
		
		public function selectAll():void {
			label.setSelection(0, label.length);
			stage.focus	= label;
		}
		
		/**
		 * 	@public
		 */
		override public function dispose():void {
			
			// remove
			label.removeEventListener(Event.CHANGE, dispatchEvent);
			
			super.dispose();
			
		}
	}
}