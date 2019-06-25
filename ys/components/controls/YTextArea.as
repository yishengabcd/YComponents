package ys.components.controls {
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.system.IME;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.text.TextLineMetrics;
	import flash.ui.Keyboard;
	
	import ys.components.controls.YScrollBar;
	import ys.components.controls.YScrollPolicy;
	import ys.components.controls.YTextInput;
	import ys.components.controls.YUIScrollBar;
	import ys.components.core.InvalidationType;
	import ys.components.core.YComponent;
	import ys.components.events.ComponentEvent;
	import ys.components.events.ScrollEvent;
	import ys.components.focus.IFocusManager;
	import ys.components.focus.IFocusManagerComponent;

	[Event(name="change", type="flash.events.Event")]
	[Event(name="textInput", type="flash.events.TextEvent")]
	[Event(name= "enter", type="ys.components.events.ComponentEvent")]
	[Event(name="scroll", type="ys.components.events.ScrollEvent")]

	public class YTextArea extends YComponent implements IFocusManagerComponent {
		/**
         * A reference to the internal text field of the TextArea component.
		 */
		private var _textField:TextField;
		protected var _editable:Boolean = true;
		protected var _wordWrap:Boolean = true;
		protected var _horizontalScrollPolicy:String = YScrollPolicy.AUTO;
		protected var _verticalScrollPolicy:String = YScrollPolicy.AUTO;

		
		protected var _horizontalScrollBar:YUIScrollBar;
		protected var _verticalScrollBar:YUIScrollBar;
		protected var background:DisplayObject;
        protected var _html:Boolean = false;
		protected var _savedHTML:String;
		protected var textHasChanged:Boolean = false;
		protected var _savedText : String = "";


		private static var defaultStyles:Object = {
												backgroundSkin:null,
												hScrollBarSkin:null,
												vScrollBarSkin:null,
												textFormat:null, disabledTextFormat:null,
												textPadding:3,
												embedFonts:false
												};

		public static function getStyleDefinition():Object {
//			return mergeStyles(defaultStyles, YScrollBar.getStyleDefinition());
			return mergeStyles(defaultStyles, YComponent.getStyleDefinition());
		}

		public function YTextArea(){
			super(); 
		}

		
		/**
         * Gets a reference to the horizontal scroll bar.
		 */
		public function get horizontalScrollBar():YUIScrollBar { 
			return _horizontalScrollBar;
		}		
		
		/**
         * Gets a reference to the vertical scroll bar.
		 */
		public function get verticalScrollBar():YUIScrollBar { 
			return _verticalScrollBar;
		}		
		
		
		override public function get enabled():Boolean {
			return super.enabled;
		}
		override public function set enabled(value:Boolean):void {
			super.enabled = value;
			mouseChildren = enabled;  //Disables mouseWheel interaction.
			invalidate(InvalidationType.STATE);
		}
		
		/**
         * Gets or sets a string which contains the text that is currently in 
		 * the TextInput component. This property contains text that is unformatted 
		 * and does not have HTML tags. To retrieve this text formatted as HTML, use 
		 * the <code>htmlText</code> property.
		 *
		 * @default ""
         *
         * @see #htmlText
		 */
		public function get text():String {
			return _textField.text;
		}
		public function set text(value:String):void {
			_textField.text = value;
			_html = false;
			invalidate(InvalidationType.DATA);
//			invalidate(InvalidationType.STYLES);	 		
			textHasChanged = true;
		}

		/**
         * Gets or sets the HTML representation of the string that the text field contains.
		 *
		 * @default ""
		 */
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
			invalidate(InvalidationType.DATA);
//			invalidate(InvalidationType.STYLES);
			textHasChanged = true;
		}
		
		/**
         * Gets or sets a Boolean value that indicates whether extra white space
		 * is removed from a TextArea component that contains HTML text. Examples 
		 * of extra white space in the component include spaces and line breaks. 
		 * A value of <code>true</code> indicates that extra white space is removed; 
		 * a value of <code>false</code> indicates that extra white space is not removed.
		 *
         * <p>This property affects only text that is set by using the <code>htmlText</code> 
		 * property; it does not affect text that is set by using the <code>text</code> property. 
         * If you use the <code>text</code> property to set text, the <code>condenseWhite</code> 
         * property is ignored.</p>
		 *
         * <p>If the <code>condenseWhite</code> property is set to <code>true</code>, you 
		 * must use standard HTML commands, such as &lt;br&gt; and &lt;p&gt;, to place line 
         * breaks in the text field.</p>
         *
		 * @default false
		 */
		public function get condenseWhite():Boolean {
			return _textField.condenseWhite;
		}
		public function set condenseWhite(value:Boolean):void {
			_textField.condenseWhite = value;
			invalidate(InvalidationType.DATA);
		}
		
		/**
		 * Gets or sets the scroll policy for the horizontal scroll bar. 
		 * This can be one of the following values:
		 *
		 * <ul>
		 * <li>ScrollPolicy.ON: The horizontal scroll bar is always on.</li>
		 * <li>ScrollPolicy.OFF: The scroll bar is always off.</li>
		 * <li>ScrollPolicy.AUTO: The scroll bar turns on when it is needed.</li>
		 * </ul>
		 *
		 *
         * @default ScrollPolicy.AUTO
         *
		 */
		public function get horizontalScrollPolicy():String {
			return _horizontalScrollPolicy;
		}
		public function set horizontalScrollPolicy(value:String):void {
			_horizontalScrollPolicy = value;
			invalidate(InvalidationType.SIZE);
		}
		
		public function get verticalScrollPolicy():String {
			return _verticalScrollPolicy;
		}
		public function set verticalScrollPolicy(value:String):void {
			_verticalScrollPolicy = value;
			invalidate(InvalidationType.SIZE);
		}

		/**
         * Gets or sets the change in the position of the scroll bar thumb, in  pixels, after
		 * the user scrolls the text field horizontally. If this value is 0, the text
		 * field was not horizontally scrolled.
		 *
         * @default 0
         *
		 */
		public function get horizontalScrollPosition():Number {
			return _textField.scrollH;
		}

		public function set horizontalScrollPosition(value:Number):void {
			// We must force a redraw to ensure that the size is up to date.
			drawNow();
			_textField.scrollH = value;
		}

		/**
         * Gets or sets the change in the position of the scroll bar thumb, in  pixels, after
		 * the user scrolls the text field vertically. If this value is 1, the text
		 * field was not vertically scrolled.
         *
         * @default 1
         *
		 */
		public function get verticalScrollPosition():Number {
			return _textField.scrollV;
		}
		public function set verticalScrollPosition(value:Number):void {
			// We must force a redraw to ensure that the size is up to date.
			drawNow();
			_textField.scrollV = value;
		}

		/**
		 * Gets the width of the text, in pixels.
		 *
         * @default 0
		 */
		public function get textWidth():Number {
			drawNow();
			return _textField.textWidth;
		}

		/**
		 * Gets the height of the text, in pixels.
		 *
         * @default 0
         *
		 */
		public function get textHeight():Number {
			drawNow();
			return _textField.textHeight;
		}

		/**
		 * Gets the count of characters that the TextArea component contains.
		 *
         * @default 0
         *
		 */
		public function get length():Number {
			return _textField.text.length;
		}
		
		/**
         * Gets or sets the string of characters that the text field  
		 * accepts from a user. 
		 *
		 * <p>Note that characters that are not included in this string 
		 * are accepted in the text field if they are entered programmatically.</p>
		 *
		 * <p>The characters in the string are read from left to right. You can 
		 * specify a character range by using the hyphen (-) character. </p>
         *
         * <p>If the value of this property is <code>null</code>, the text field 
		 * accepts all characters. If this property is set to an empty string (""), 
		 * the text field accepts no characters. </p>
		 *
         * <p>If the string begins with a caret (^) character, all characters 
         * are initially accepted and succeeding characters in the string 
         * are excluded from the set of accepted characters. If the string 
         * does not begin with a caret (^) character, no characters are 
         * initially accepted and succeeding characters in the string are 
         * included in the set of accepted characters.</p>
		 *
		 * @default null
		 */
		public function get restrict():String {
			return _textField.restrict;
		}
		public function set restrict(value:String):void {
			_textField.restrict = value;
		}
		
		/**
		 * Gets or sets the maximum number of characters that a user can enter
		 * in the text field.
		 * 
         * @default 0
		 */
		public function get maxChars():int {
			return _textField.maxChars;
		}

		public function set maxChars(value:int):void {
			_textField.maxChars = value;	
		}

		/**
         * Gets the maximum value of the <code>horizontalScrollPosition</code> property.
		 * 
         * @default 0
		 */
		public function get maxHorizontalScrollPosition():int {
			return _textField.maxScrollH;
		}

		/**
         * Gets the maximum value of the <code>verticalScrollPosition</code> property.
         *
         * @default 1
		 */
		public function get maxVerticalScrollPosition():int {
			return _textField.maxScrollV;
		}
		
		/**
		 * Gets or sets a Boolean value that indicates whether the text
		 * wraps at the end of the line. A value of <code>true</code> 
		 * indicates that the text wraps; a value of <code>false</code>
		 * indicates that the text does not wrap. 
         *
         * @default true
		 */		
		public function get wordWrap():Boolean {
			return _wordWrap;
		}
		public function set wordWrap(value:Boolean):void {
			_wordWrap = value;
			invalidate(InvalidationType.STATE);
		}
		
		/**
		 * Gets the index position of the first selected character in a selection of one or more
		 * characters. 
		 *
		 * <p>The index position of a selected character is zero-based and calculated
		 * from the first character that appears in the text area. If there is no selection, 
		 * this value is set to the position of the caret.</p>
		 * 
         * @default 0
		 */
		public function get selectionBeginIndex():int {
			return _textField.selectionBeginIndex;
		}
		
		/**
		 * Gets the index position of the last selected character in a selection of one or more
		 * characters. 
		 *
		 * <p>The index position of a selected character is zero-based and calculated
		 * from the first character that appears in the text area. If there is no selection, 
		 * this value is set to the position of the caret.</p>
		 * 
         * @default 0
		 */
		public function get selectionEndIndex():int {
			return _textField.selectionEndIndex;
		}
		
		/**
         * Gets or sets a Boolean value that indicates whether the TextArea component 
		 * instance is the text field for a password. A value of <code>true</code>
		 * indicates that the current instance was created to contain a password;
		 * a value of <code>false</code> indicates that it was not. 
		 *
		 * <p>If the value of this property is <code>true</code>, the characters 
		 * that the user enters in the text area cannot be seen. Instead,
		 * an asterisk is displayed in place of each character that the
		 * user enters. Additionally, the Cut and Copy commands and their keyboard
		 * shortcuts are disabled to prevent the recovery of a password from
		 * an unattended computer.</p>
         *
         * @default false
		 */		
		public function get displayAsPassword():Boolean {
			return _textField.displayAsPassword;
		}
		public function set displayAsPassword(value:Boolean):void {
			_textField.displayAsPassword = value;
		}
		
		/**
		 * Gets or sets a Boolean value that indicates whether the user can
		 * edit the text in the component. A value of <code>true</code> indicates
		 * that the user can edit the text that the component contains; a value of <code>false</code>
		 * indicates that it cannot. 
		 *
         * @default true
		 */		
		public function get editable():Boolean {
			return _editable;
		}
		public function set editable(value:Boolean):void {
			_editable = value;
			invalidate(InvalidationType.STATE);
		}
		
		/**
         * Gets or sets the mode of the input method editor (IME). The IME makes
		 * it possible for users to use a QWERTY keyboard to enter characters from 
		 * the Chinese, Japanese, and Korean character sets.
		 *
		 * <p>Flash sets the IME to the specified mode when the component gets focus, 
		 * and restores it to the original value after the component loses focus. </p>
		 *
		 * <p>The flash.system.IMEConversionMode class defines constants for 
         * the valid values for this property. Set this property to <code>null</code> to 
		 * prevent the use of the IME with the component.</p>
		 */
		 public function get imeMode():String {
			return IME.conversionMode;
		 }
		
		public function set imeMode(value:String):void {
			_imeMode = value;
		}
		

		/**
		 * Gets or sets a Boolean value that indicates whether Flash Player
		 * highlights a selection in the text field when the text field 
		 * does not have focus. 
		 *
		 * If this value is set to <code>true</code> and the text field does not
		 * have focus, Flash Player highlights the selection in gray. If this value 
		 * is set to <code>false</code> and the text field does not have focus, Flash 
		 * Player does not highlight the selection.  
		 *
		 * @default false
		 */
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
		
		/**
         * Retrieves information about a specified line of text.
		 * 
		 * @param lineIndex The line number for which information is to be retrieved.
		 * 
         * @default null
		 */
		public function getLineMetrics(lineIndex:int):TextLineMetrics {
			return _textField.getLineMetrics(lineIndex);
		}
		
		/**
		 * Sets the range of a selection made in a text area that has focus.
		 * The selection range begins at the index that is specified by the start 
		 * parameter, and ends at the index that is specified by the end parameter.
		 * The selected text is treated as a zero-based string of characters in which
		 * the first selected character is located at index 0, the second 
		 * character at index 1, and so on.
		 *
		 * <p>This method has no effect if the text field does not have focus.</p>
		 *
		 * @param setSelection The index location of the first character in the selection.
		 * @param endIndex The index position of the last character in the selection.
		 */
		public function setSelection(setSelection:int, endIndex:int):void {
			_textField.setSelection(setSelection, endIndex);
		}
		
		/**
         * Appends the specified string after the last character that the TextArea 
		 * component contains. This method is more efficient than concatenating two strings 
		 * by using an addition assignment on a text property--for example, 
		 * <code>myTextArea.text += moreText</code>. This method is particularly
		 * useful when the TextArea component contains a significant amount of
		 * content. 
         *
         * @param text The string to be appended to the existing text.
		 */
		public function appendText(text:String):void {
			_textField.appendText(text);
			invalidate(InvalidationType.DATA);
		}
		
		override protected function configUI():void {
			super.configUI();
			tabChildren = true;
			
			_textField = new TextField();
			addChild(_textField);
			updateTextFieldType();
			
			_textField.addEventListener(TextEvent.TEXT_INPUT, handleTextInput, false, 0, true);
			_textField.addEventListener(Event.CHANGE, handleChange, false, 0, true);
			_textField.addEventListener(KeyboardEvent.KEY_DOWN, handleKeyDown, false, 0, true);

			addEventListener(MouseEvent.MOUSE_WHEEL, handleWheel, false, 0, true);
		}
		public function get textField() : TextField
		{
			return _textField;
		}
		
		public function set hScrollBar(value : YUIScrollBar):void
		{
			_horizontalScrollBar = value;
			_horizontalScrollBar.drawNow()
			_horizontalScrollBar.name = "H";
			_horizontalScrollBar.visible = false;
			_horizontalScrollBar.focusEnabled = false;
			_horizontalScrollBar.direction = YScrollBarDirection.HORIZONTAL;
			_horizontalScrollBar.addEventListener(ScrollEvent.SCROLL,handleScroll,false,0,true);
			addChild(_horizontalScrollBar);
			
			
			_horizontalScrollBar.scrollTarget = _textField;
		}
		public function set vScrollBar(value : YUIScrollBar):void
		{
			_verticalScrollBar = value;
			_verticalScrollBar.drawNow()
			_verticalScrollBar.name = "V";
			_verticalScrollBar.visible = false;
			_verticalScrollBar.focusEnabled = false;
			_verticalScrollBar.addEventListener(ScrollEvent.SCROLL,handleScroll,false,0,true);
			addChild(_verticalScrollBar);
			
			
			_verticalScrollBar.scrollTarget = _textField;
		}
		protected function updateTextFieldType():void {
			_textField.type = (enabled && _editable) ? TextFieldType.INPUT : TextFieldType.DYNAMIC;
			_textField.selectable = enabled;
			_textField.wordWrap = _wordWrap;
			_textField.multiline = true;
		}
		protected function handleKeyDown(event:KeyboardEvent):void {
			if (event.keyCode == Keyboard.ENTER) {
				dispatchEvent(new ComponentEvent(ComponentEvent.ENTER, true));
			}
		}
		protected function handleChange(event:Event):void {
			event.stopPropagation(); // so you don't get two change events
			dispatchEvent(new Event(Event.CHANGE, true));
			invalidate(InvalidationType.DATA);
		}

		protected function handleTextInput(event:TextEvent):void {
			event.stopPropagation();
			dispatchEvent(new TextEvent(TextEvent.TEXT_INPUT, true, false, event.text));
		}

		protected function handleScroll(event:ScrollEvent):void {
			dispatchEvent(event);
		}

		protected function handleWheel(event:MouseEvent):void {
			if (!enabled || !_verticalScrollBar.visible) { return; }
			_verticalScrollBar.scrollPosition -= event.delta * _verticalScrollBar.lineScrollSize;
			dispatchEvent(new ScrollEvent(YScrollBarDirection.VERTICAL, event.delta * _verticalScrollBar.lineScrollSize, _verticalScrollBar.scrollPosition));
		}

		protected function setEmbedFont() :void{
			var embed:Object = getStyleValue("embedFonts");
			if (embed != null) {
				_textField.embedFonts = embed;
			}	
		}
		
		override protected function draw():void {
			
			if (isInvalid(InvalidationType.STYLES)) {
				hScrollBar = getDisplayObjectInstance(getStyleValue("hScrollBarSkin")) as YUIScrollBar;
				vScrollBar = getDisplayObjectInstance(getStyleValue("vScrollBarSkin")) as YUIScrollBar;
				
				drawBackground();
				
				setEmbedFont();	
				invalidate(InvalidationType.STATE, false);
			}
			if (isInvalid(InvalidationType.STATE)) {
				updateTextFieldType();
				drawTextFormat();
				invalidate(InvalidationType.SIZE, false);
			}
			
			if (isInvalid(InvalidationType.SIZE, InvalidationType.DATA)) {
				drawLayout();
			}
			
			
			super.draw();
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

		protected function drawBackground():void {
			var bg:DisplayObject = background;
//			var styleName:String = (enabled) ? "backgroundSkin" : "backgroundDisabledSkin";
			var styleName:String = "backgroundSkin";
			background = getDisplayObjectInstance(getStyleValue(styleName));
			if (background != null) {
				addChildAt(background, 0);
			}
			if (bg != null && bg != background && contains(bg)) { 
				removeChild(bg); 
			}
		}

		protected function drawLayout():void {
			var txtPad:Number = Number(getStyleValue("textPadding"));
			_textField.x = _textField.y = txtPad;
			if(background){
				background.width = width;
				background.height = height;
			}

			// Figure out which scrollbars we need:
			var availHeight:Number = height;
			var vScrollBar:Boolean = needVScroll();
//			var availWidth:Number = width - (vScrollBar?_verticalScrollBar.width:0);
			var availWidth:Number = width - (vScrollBar?15:0);
		
			var hScrollBar:Boolean = needHScroll();
			if (hScrollBar) {
				availHeight -= _horizontalScrollBar.height;
			}			
			setTextSize(availWidth, availHeight, txtPad);
			
			// catch the edge case of the horizontal scroll bar necessitating a vertical one:
			if (hScrollBar && !vScrollBar && needVScroll()) {
				vScrollBar = true;
				availWidth -= _verticalScrollBar.width;
				setTextSize(availWidth, availHeight, txtPad);
			}

			// Size and move the scrollBars
			if (vScrollBar) {
				_verticalScrollBar.visible = true;
				_verticalScrollBar.x = width - 15;_verticalScrollBar.width;
				_verticalScrollBar.height = availHeight;
				_verticalScrollBar.visible = true;
				_verticalScrollBar.enabled = enabled;
			} else {
				_verticalScrollBar.visible = false;
			}
			
			if (hScrollBar) {
				_horizontalScrollBar.visible = true;
				_horizontalScrollBar.y = height - 15;_horizontalScrollBar.height;
				_horizontalScrollBar.width = availWidth;
				_horizontalScrollBar.visible = true;
				_horizontalScrollBar.enabled = enabled;
			} else {
				_horizontalScrollBar.visible = false;
			}
			
			updateScrollBars();	
			
			addEventListener(Event.ENTER_FRAME, delayedLayoutUpdate, false, 0, true);
		}
		
		protected function delayedLayoutUpdate(event:Event):void {
			if (textHasChanged) {
				textHasChanged = false;
				drawLayout();
				return;
			}
			removeEventListener(Event.ENTER_FRAME, delayedLayoutUpdate);
		}
		
		protected function updateScrollBars() :void{
			_horizontalScrollBar.update();
			_verticalScrollBar.update();
			_verticalScrollBar.enabled = enabled;
			_horizontalScrollBar.enabled = enabled;
			_horizontalScrollBar.drawNow();
			_verticalScrollBar.drawNow();			
		}

		protected function needVScroll():Boolean {
			if (_verticalScrollPolicy == YScrollPolicy.OFF) { return false; }
			if (_verticalScrollPolicy == YScrollPolicy.ON) { return true; }
			return (_textField.maxScrollV > 1);
		}
		protected function needHScroll():Boolean {
			if (_horizontalScrollPolicy == YScrollPolicy.OFF) { return false; }
			if (_horizontalScrollPolicy == YScrollPolicy.ON) { return true; }
			return (_textField.maxScrollH > 0);
		}

		protected function setTextSize(width:Number, height:Number, padding:Number):void {
			var w:Number = width - padding*2;
			var h:Number = height - padding*2;
			
			if (w != _textField.width) {
				_textField.width = w;
			}
			if (h != _textField.height) {
				_textField.height = h
			}			
		}

		override protected function isOurFocus(target:DisplayObject):Boolean {
			return target == _textField || super.isOurFocus(target);
		}
				
		override protected function focusInHandler(event:FocusEvent):void {
			setIMEMode(true);
						
			if (event.target == this) {
				stage.focus = _textField;
			}
			var fm:IFocusManager = focusManager;
			if (fm) {
				if(editable) {
					fm.showFocusIndicator = true;
				}
				fm.defaultButtonEnabled = false;
			}
			super.focusInHandler(event);
			
			if(editable) {
				setIMEMode(true);
			}
		}
		
		override protected function focusOutHandler(event:FocusEvent):void {
			var fm:IFocusManager = focusManager;
			if (fm) {
				fm.defaultButtonEnabled = true;
			}
			setSelection(0, 0);
			super.focusOutHandler(event);
			
			if(editable) {
				setIMEMode(false);
			}
		}

	}

}
