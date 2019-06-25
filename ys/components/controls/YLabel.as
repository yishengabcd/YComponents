package ys.components.controls {

	import ys.components.core.InvalidationType;
	import ys.components.core.YComponent;
	import ys.components.events.ComponentEvent;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TextEvent;
	import ys.components.controls.YTextInput; //Only for ASDocs
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;

	[Event(name="resize", type="ys.components.events.ComponentEvent")]
	
	public class YLabel extends YComponent {

		private var _textField:TextField;		
		protected var actualWidth:Number;		
		protected var actualHeight:Number;		
		protected var defaultLabel:String = "Label";
		protected var _savedHTML:String;
		protected var _html:Boolean = false;
		
		private static var defaultStyles:Object = {
			textFormat:null, 
			textFilters:null,
			embedFonts:false
		};


		public static function getStyleDefinition():Object { return defaultStyles; }

		public function YLabel() {
			super();
			
			text = defaultLabel;
			actualWidth = _width;
			actualHeight = _height;
		}
		
		public function get text():String {
			return _textField.text;
		}


		public function set text(value:String):void {
			// Value is the same as what is already set.
			if (value == text) { 
				return;
			}	
			
			// Clear the HTML value, and redraw.
			_html = false;
			_textField.text = value;	
			if (_textField.autoSize != TextFieldAutoSize.NONE) { 
				invalidate(InvalidationType.SIZE);
			}
		}
		
		public function get htmlText():String {
			return _textField.htmlText;
		}
		
		public function set htmlText(value:String):void {
			// Value is the same as what is already set.
			if (value == htmlText) { 
				return;
			}
			
			// Remember the html for later.
			_html = true;
			_savedHTML = value;
			
			// Change the text, and possibly resize.
			_textField.htmlText = value;
			if (_textField.autoSize != TextFieldAutoSize.NONE) { 
				invalidate(InvalidationType.SIZE);
			}
		}
		
		public function get condenseWhite():Boolean {
			return _textField.condenseWhite;
		}
		public function set condenseWhite(value:Boolean):void {
			_textField.condenseWhite = value;
			if (_textField.autoSize != TextFieldAutoSize.NONE) { invalidate(InvalidationType.SIZE); }
		}
		
		public function get selectable():Boolean {
			return _textField.selectable;
		}		
		public function set selectable(value:Boolean):void {
			_textField.selectable = value;
		}
		
		public function get wordWrap():Boolean {
			return _textField.wordWrap;
		}		
		public function set wordWrap(value:Boolean):void {
			_textField.wordWrap = value;
			if (_textField.autoSize != TextFieldAutoSize.NONE) { invalidate(InvalidationType.SIZE); }
		}
		
		public function get autoSize():String {
			return _textField.autoSize;
		}
		public function set autoSize(value:String):void {
			_textField.autoSize = value;
			invalidate(InvalidationType.SIZE);
		}		
		
		override public function get width():Number {
			if (_textField.autoSize != TextFieldAutoSize.NONE && !wordWrap) {
				return _width;
			} else {
				return actualWidth;	
			}
		}		
		override public function set width(value:Number):void {
			actualWidth = value;
			super.width = value;
		}
		override public function get height():Number {
			if (_textField.autoSize != TextFieldAutoSize.NONE && wordWrap) {
				return _height;
			} else {
				return actualHeight;	
			}
		}		
		override public function setSize(width:Number, height:Number):void {
			actualWidth = width;
			actualHeight = height;
			super.setSize(width,height);
		}
		
		
		
		override protected function configUI():void {
			super.configUI();
			
			_textField = new TextField();
			addChild(_textField);
			_textField.type = TextFieldType.DYNAMIC;
			_textField.selectable = false;
			_textField.wordWrap = false;
		}
		
		override protected function draw():void {
			if (isInvalid(InvalidationType.STYLES,InvalidationType.STATE)) {
				drawTextFormat();
				
//				var embed:Object = getStyleValue('embedFonts');
//				if (embed != null) {
//					_textField.embedFonts = embed;
//				}
				
				if (_textField.autoSize != TextFieldAutoSize.NONE) { 
					invalidate(InvalidationType.SIZE,false);
				}
			}
			if (isInvalid(InvalidationType.SIZE)) {
				drawLayout();
			}
			super.draw();
		}
		protected function drawTextFormat():void {
			var tf:TextFormat = getStyleValue("textFormat") as TextFormat;
			if (tf == null) {
				var uiStyles:Object = YComponent.getStyleDefinition();
				tf = enabled ? uiStyles.defaultTextFormat as TextFormat : uiStyles.defaultDisabledTextFormat as TextFormat;
			}
			
			_textField.defaultTextFormat = tf; // This removes HTML Styles...
			_textField.setTextFormat(tf);
			
			_textField.filters = getStyleValue("textFilters") as Array;
			
			// Set the HTML again to make sure that the html styles are preserved.
			if (_html && _savedHTML != null) { htmlText = _savedHTML; }
		}

		protected function drawLayout():void {
			var resized:Boolean = false;
			
			_textField.width = width;
			_textField.height = height;
			
			if (_textField.autoSize != TextFieldAutoSize.NONE) {
				
				var txtW:Number = _textField.width;
				var txtH:Number = _textField.height;
				
				resized = (_width != txtW || _height != txtH);
				// set the properties directly, so we don't trigger a callLater:
				_width = txtW;
				_height = txtH;
				
				switch (_textField.autoSize) {
					case TextFieldAutoSize.CENTER:
						_textField.x = (actualWidth/2)-(_textField.width/2);
						break;
					case TextFieldAutoSize.LEFT:
						_textField.x = 0;
						break;
					case TextFieldAutoSize.RIGHT:
						_textField.x = -(_textField.width - actualWidth);
						break;
				}
			} else {
				_textField.width = actualWidth;
				_textField.height = actualHeight;
				_textField.x = 0;	
			}
			
			if (resized) { 
				dispatchEvent(new ComponentEvent(ComponentEvent.RESIZE, true));
			}
		}
		
		public function get textField():TextField
		{
			return _textField;
		}
	}
}