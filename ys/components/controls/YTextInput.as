package ys.components.controls {
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.events.TextEvent;
	import flash.geom.Rectangle;
	import flash.system.IME;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.text.TextLineMetrics;
	import flash.ui.Keyboard;
	
	import ys.components.controls.YTextArea;
	import ys.components.controls.YTextInput;
	import ys.components.core.InvalidationType;
	import ys.components.core.YComponent;
	import ys.components.events.ComponentEvent;
	import ys.components.focus.IFocusManager;
	import ys.components.focus.IFocusManagerComponent;
	

    //--------------------------------------
    //  Events
    //--------------------------------------
	[Event(name="change", type="flash.events.Event")]
	[Event(name="enter", type="ys.components.events.ComponentEvent")]
	[Event(name="textInput", type="flash.events.TextEvent")]


	public class YTextInput extends YComponent implements IFocusManagerComponent
	{
		private var _textField:TextField
		
		
		protected var _editable:Boolean = true;

		protected var background:DisplayObject;
		protected var _html:Boolean = false;
		protected var _savedHTML:String;

		
		private static var defaultStyles:Object = {
												background:null,
												scale9Grid:null,
												textFormat:null,
												disabledTextFormat:null,
												textPadding:0,
												embedFonts:false
												};
        

		public static function getStyleDefinition():Object { return defaultStyles; }


		
		public function YTextInput() {
			super();
		}
		
		
		
		
		public function get textField():TextField
		{
			return _textField;
		}
		
		public function get text():String {
			return _textField.text;
		}
		public function set text(value:String):void {
			_textField.text = value;
			_html = false;
			invalidate(InvalidationType.STATE);
		}

		override public function get enabled():Boolean {
			return super.enabled;
		}
		override public function set enabled(value:Boolean):void {
			super.enabled = value;
			updateTextFieldType();
		}		
		
		public function get imeMode():String {
			return _imeMode;
		}		
		public function set imeMode(value:String):void {
			_imeMode = value;
		}
		public function get alwaysShowSelection():Boolean {
			return _textField.alwaysShowSelection;
		}
		public function set alwaysShowSelection(value:Boolean):void {
			_textField.alwaysShowSelection = value;	
		}

		override public function drawFocus(draw:Boolean):void {
			if (focusTarget != null) {
				focusTarget.drawFocus(draw);
				return;
			}
			super.drawFocus(draw);
   	 	}
		
		public function get editable():Boolean {
			return _editable;
		}
		public function set editable(value:Boolean):void {
			_editable = value;
			updateTextFieldType();
		}

		public function get horizontalScrollPosition():int {
			return _textField.scrollH;
		}
		public function set horizontalScrollPosition(value:int):void {
			_textField.scrollH = value;
		}
		
		public function get maxHorizontalScrollPosition():int {
			return _textField.maxScrollH;
		}

		public function get length():int {
			return _textField.length;
		}

		public function get maxChars():int {
			return _textField.maxChars;
		}
		public function set maxChars(value:int):void {
			_textField.maxChars = value;
		}
		
		public function get displayAsPassword():Boolean {
			return _textField.displayAsPassword;
		}
		public function set displayAsPassword(value:Boolean):void {
			_textField.displayAsPassword = value;
		}
		
		public function get restrict():String {
			return _textField.restrict;
		}
		public function set restrict(value:String):void {
			_textField.restrict = value;
		}

		public function get selectionBeginIndex():int {
			return _textField.selectionBeginIndex;
		}

		public function get selectionEndIndex():int {
			return _textField.selectionEndIndex;
		}

		 public function get condenseWhite():Boolean {
			return _textField.condenseWhite;
		 }

		 public function set condenseWhite(value:Boolean):void {
			_textField.condenseWhite = value;
		 }

		 public function get htmlText():String {
			return _textField.htmlText;
		 }
		 public function set htmlText(value:String):void {
			if (value == "") { 
				text = "";
				return;
			}
			_html = true;
			_savedHTML = value;
			_textField.htmlText = value;
			invalidate(InvalidationType.STATE);
		 }

		public function get textHeight():Number {
			return _textField.textHeight;
		}

		public function get textWidth():Number {
			return _textField.textWidth;
		}

		public function setSelection(beginIndex:int, endIndex:int):void {
			_textField.setSelection(beginIndex, endIndex);
		}

		public function getLineMetrics(index:int):TextLineMetrics {
			return _textField.getLineMetrics(index);
		}
		
		public function appendText(text:String):void {
			_textField.appendText(text);
		}
		
		protected function updateTextFieldType():void {
			_textField.type = (enabled && editable) ? TextFieldType.INPUT : TextFieldType.DYNAMIC;
			_textField.selectable = enabled;
		}
		protected function handleKeyDown(event:KeyboardEvent):void {
			if (event.keyCode == Keyboard.ENTER) {
				dispatchEvent(new ComponentEvent(ComponentEvent.ENTER, true));
			}
		}

		protected function handleChange(event:Event):void {
			event.stopPropagation(); // so you don't get two change events
			dispatchEvent(new Event(Event.CHANGE, true));
		}

		protected function handleTextInput(event:TextEvent):void {
			event.stopPropagation();
			dispatchEvent(new TextEvent(TextEvent.TEXT_INPUT, true, false, event.text));
		}

		protected function setEmbedFont() :void{
			var embed:Object = getStyleValue("embedFonts");
			if (embed != null) {
				_textField.embedFonts = embed;
			}	
		}
		
		override protected function draw():void {
			if (isInvalid(InvalidationType.STYLES)) {
				drawBackground();
				
				var embed:Object = getStyleValue('embedFonts');
				if (embed != null) {
					_textField.embedFonts = embed;
				}
				invalidate(InvalidationType.STATE,false);
			}
			if (isInvalid(InvalidationType.STATE)) {
				drawTextFormat();
				invalidate(InvalidationType.SIZE,false);
			}
			if (isInvalid(InvalidationType.SIZE)) {
				drawLayout();
			}
			super.draw();
		}

		protected function drawBackground():void {
			var bg:DisplayObject = background;
			
			var styleName:String = "background"//(enabled) ? "background" : "disabledSkin";
			background = getDisplayObjectInstance(getStyleValue(styleName));
			if (background == null) { return; }
			addChildAt(background,0);
			var scale9Grid : Rectangle = getStyleValue("scale9Grid") as Rectangle
			if(scale9Grid){
				background.scale9Grid = scale9Grid;
			}
			if(background is YComponent){
				YComponent(background).drawNow();
			}
			if(!bg){
				if(isNaN(width)){
					width = background.width;
				}
				if(isNaN(height)){
					height = background.height;
				}
			}
			if (bg != null && bg != background && contains(bg)) { 
				removeChild(bg); 
			}	
		}

		protected function drawTextFormat():void {
			// Apply a default textformat
			var uiStyles:Object = YComponent.getStyleDefinition();
			var defaultTF:TextFormat = enabled ? uiStyles.defaultTextFormat as TextFormat : uiStyles.defaultDisabledTextFormat as TextFormat;
			_textField.setTextFormat(defaultTF);
			
			var tf:TextFormat = getStyleValue(enabled?"textFormat":"disabledTextFormat") as TextFormat;
			if (tf != null) {
				_textField.setTextFormat(tf);
			} else {
				tf = defaultTF;
			}
			_textField.defaultTextFormat = tf;
			
			setEmbedFont();
			if (_html) { _textField.htmlText = _savedHTML; }
		}

		protected function drawLayout():void {
			var txtPad:Number = Number(getStyleValue("textPadding"));
			if (background != null) {
				background.width = width;
				background.height = height;
			}
			_textField.width = width-2*txtPad;
			_textField.height = height-2*txtPad;
			_textField.x = _textField.y = txtPad;
		}

		override protected function configUI():void {
			super.configUI();
			
			_textField = new TextField();
			addChild(_textField);
			updateTextFieldType();
			_textField.addEventListener(TextEvent.TEXT_INPUT, handleTextInput, false, 0, true);
			_textField.addEventListener(Event.CHANGE, handleChange, false, 0, true);
			_textField.addEventListener(KeyboardEvent.KEY_DOWN, handleKeyDown, false, 0, true);
			
			tabChildren = true;
		}

		override public function setFocus():void {
			stage.focus = _textField;
		}

		override protected function isOurFocus(target:DisplayObject):Boolean {
			return target == _textField || super.isOurFocus(target);
		}
		
		override protected function focusInHandler(event:FocusEvent):void {
			if (event.target == this) {
				stage.focus = _textField;
			}
			var fm:IFocusManager = focusManager;
			if (editable && fm) {
				fm.showFocusIndicator = true;
				if (_textField.selectable && _textField.selectionBeginIndex == _textField.selectionBeginIndex) {
					setSelection(0, _textField.length);
				}
			}
			super.focusInHandler(event);
			
			if(editable) {
				setIMEMode(true);
			}
		}
		override public function setStyle(style:String, value:Object):void
		{
			super.setStyle(style, value);
		}
		
		override protected function focusOutHandler(event:FocusEvent):void {
			super.focusOutHandler(event);
			
			if(editable) {
				setIMEMode(false);
			}
		}
	}
}