package ys.components.controls {

	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.geom.Point;
	import flash.system.IME;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.ui.Keyboard;
	
	import ys.components.containers.YBaseScrollPane;
	import ys.components.controls.YBaseButton;
	import ys.components.controls.YList;
	import ys.components.controls.YScrollBar;
	import ys.components.controls.YTextArea;
	import ys.components.controls.YTextInput;
	import ys.components.controls.listClasses.ICellRenderer;
	import ys.components.core.InvalidationType;
	import ys.components.core.YComponent;
	import ys.components.data.DataProvider;
	import ys.components.events.ComponentEvent;
	import ys.components.events.DataChangeEvent;
	import ys.components.events.DataChangeType;
	import ys.components.events.ListEvent;
	import ys.components.focus.IFocusManagerComponent;

	[Event(name="change", type="flash.events.Event")]
	[Event(name="itemRollOver", type="ys.components.events.ListEvent")]
	[Event(name="itemRollOut", type="ys.components.events.ListEvent")]
	[Event(name="close", type="flash.events.Event")]
	[Event(name="enter", type="ys.components.events.ComponentEvent")]
	[Event(name="open", type="flash.events.Event")]
	[Event(name="scroll", type="ys.components.events.ScrollEvent")]


	public class YComboBox extends YComponent implements IFocusManagerComponent {

		protected var _inputField:YTextInput;
		protected var _background:YBaseButton;
		protected var _list:YList;
		protected var _rowCount:uint = 5;
		protected var _editable:Boolean = false;
		protected var isOpen:Boolean = false;
		protected var highlightedCell:int = -1
		protected var editableValue:String;
		protected var _prompt:String;
		protected var isKeyDown:Boolean = false;
		protected var currentIndex:int;
		protected var listOverIndex:uint;
		protected var _dropdownWidth:Number;
		protected var _labels:Array;
		private var _dataProvider : DataProvider;
		
		private static var defaultStyles:Object = {
				backgroundSkin : null,
				inputFieldSkin : null,
				listSkin:null,
				textFormat:null, 
				disabledTextFormat:null, 
				textPaddingX:3,
				textPaddingY:3,
				buttonWidth:24
				};

		public static function getStyleDefinition():Object {
			return mergeStyles(defaultStyles, YList.getStyleDefinition());
		}


		
		public function YComboBox() {
			super();
		}

		public function getList():YList
		{
			return _list;
		}
		
		public function get editable():Boolean {
			return _editable;
		}
		public function set editable(value:Boolean):void {
			_editable = value;
			drawTextField();
		}
		public function get rowCount():uint {
			return _rowCount;
		}
		public function set rowCount(value:uint):void {
			_rowCount = value;
			invalidate(InvalidationType.SIZE);
		}
		public function get restrict():String {
			return _inputField.restrict;
		}
		public function set restrict(value:String):void {
			if (! _editable) { return; }
			_inputField.restrict = value;
		}

		
		public function get selectedIndex():int {
			return _list.selectedIndex;
		}
		public function set selectedIndex(value:int):void {
			if(_list==null)
			{
				drawNow();
			}
			_list.selectedIndex = value;
			highlightCell(); // Deselect any highlighted cells / reset index
			invalidate(InvalidationType.SELECTED);
		}

		public function get text():String {
			return _inputField.text;
		}
		public function set text(value:String):void {
			if (!editable) { return; }
			_inputField.text = value;
		}

		public function get labelField():String {
			return _list.labelField;
		}
		public function set labelField(value:String):void {
			_list.labelField = value;
			invalidate(InvalidationType.DATA);
		}

		public function get labelFunction():Function {
			return _list.labelFunction;
		}
		public function set labelFunction(value:Function):void {
			_list.labelFunction = value;
			invalidate(InvalidationType.DATA);
		}

		public function itemToLabel(item:Object):String {
			if (item == null) { return ""; }
			return _list.itemToLabel(item);	
		}

		
		public function get selectedItem():Object {
			return _list.selectedItem;
		}
		public function set selectedItem(value:Object):void {
			_list.selectedItem = value;
			invalidate(InvalidationType.SELECTED);
		}

		public function get dropdown():YList {
			return _list;
		}

		public function get length():int {
			return _list.length;
		}

		public function get textField():YTextInput {
			return _inputField;
		}
		
		public function get value():String {
			if (editableValue != null) {
				return editableValue;
			} else {
				var item:Object = selectedItem;
				if (!_editable && item.data != null) {
					return item.data;
				} else {
					return itemToLabel(item);	
				}
			}
		}	
				
		public function get dataProvider():DataProvider {
			if(_list)
			{
				return _list.dataProvider;
			}else
			{
				return _dataProvider;
			}
		}
		
		public function set dataProvider(value:DataProvider):void {
			value.addEventListener(DataChangeEvent.DATA_CHANGE,handleDataChange,false,0,true);
			if(_list){
				_list.dataProvider = value;
			}else{
				_dataProvider = value;
			}
			
			invalidate(InvalidationType.DATA);
		}

		public function get dropdownWidth():Number {
			return _list.width;
		}
		public function set dropdownWidth(value:Number):void {
			_dropdownWidth = value;
			invalidate(InvalidationType.SIZE);
		}

		
		
		public function addItem(item:Object):void {
			_list.addItem(item);
			invalidate(InvalidationType.DATA);
		}
		
		public function get prompt():String {
			return _prompt;
		}
		public function set prompt(value:String):void {
			if (value == "") {
				_prompt = null;
			} else {
				_prompt = value;
			}
			invalidate(InvalidationType.STATE);
		}
		
		 public function get imeMode():String {
			return _inputField.imeMode;
		}		
		public function set imeMode(value:String):void {
			_inputField.imeMode = value;
		}

		public function addItemAt(item:Object,index:uint):void {
			_list.addItemAt(item,index);
			invalidate(InvalidationType.DATA);
		}
		public function removeAll():void {
			_list.removeAll();
			_inputField.text = "";
			invalidate(InvalidationType.DATA);
		}
		
		public function removeItem(item:Object):Object {
			return _list.removeItem(item);
		}
		
		public function removeItemAt(index:uint):void {
			_list.removeItemAt(index);
			invalidate(InvalidationType.DATA);
		}

		public function getItemAt(index:uint):Object {
			return _list.getItemAt(index);
		}

		public function replaceItemAt(item:Object, index:uint):Object {
			return _list.replaceItemAt(item, index);
		}

		public function sortItems(...sortArgs:Array):* {
			return _list.sortItems.apply(_list, sortArgs);
		}

		public function sortItemsOn(field:String,options:Object=null):* {
			return _list.sortItemsOn(field,options);
		}

		public function open():void {
			currentIndex = selectedIndex;
			if (isOpen || length == 0) { return; }

			dispatchEvent(new Event(Event.OPEN));
			isOpen = true;

			// Add a listener to the stage to close the combobox when something
			// else is clicked.  We need to wait a frame, otherwise the same click
			// that opens the comboBox will also close it.
			addEventListener(Event.ENTER_FRAME, addCloseListener, false, 0, true);			

			positionList();
			_list.scrollToSelected();
			stage.addChild(_list);
		}

		public function close():void {
			highlightCell();
			highlightedCell = -1;
			if (! isOpen) { return; }
			
			dispatchEvent(new Event(Event.CLOSE));
			stage.removeEventListener(MouseEvent.MOUSE_DOWN, onStageClick);
			isOpen = false;
			stage.removeChild(_list);
		}
		
		public function get selectedLabel():String {
			if (editableValue != null) {
				return editableValue;
			} else if (selectedIndex == -1) {
				return null;
			}
			return itemToLabel(selectedItem);	
		}
		
		
		public function set background(value : YBaseButton):void
		{
			if(_background == value || !value){
				return;
			}
			if(_background && _background.parent){
				_background.parent.removeChild(_background);
			}
			
			_background = value;
			_background.focusEnabled = false;
			_background.addEventListener(MouseEvent.MOUSE_DOWN, onToggleListVisibility, false, 0, true);
			addChild(_background);
		}
		public function set inputField(value : YTextInput):void
		{
			if(_inputField == value || !value){
				return;
			}
			if(_inputField && _inputField.parent){
				_inputField.parent.removeChild(_inputField);
			}
			_inputField = value
			_inputField.drawNow();
			_inputField.focusTarget = this as IFocusManagerComponent;
			_inputField.focusEnabled = false;
			_inputField.addEventListener(Event.CHANGE, onTextInput, false, 0, true);
			addChild(_inputField);
		}
		public function set list(value : YList):void
		{
			if(_list == value || !value){
				return;
			}
			if(_list && _list.parent){
				_list.parent.removeChild(_list);
			}
			_list = value;
			_list.drawNow();
			_list.focusEnabled = false;
			_list.addEventListener(Event.CHANGE, onListChange, false, 0, true);
			_list.addEventListener(ListEvent.ITEM_CLICK, onListChange, false, 0, true);
			_list.addEventListener(ListEvent.ITEM_ROLL_OUT, passEvent, false, 0, true);
			_list.addEventListener(ListEvent.ITEM_ROLL_OVER, passEvent, false, 0, true);
			_list.verticalScrollBar.addEventListener(Event.SCROLL, passEvent, false, 0, true);
		}
		override protected function focusInHandler(event:FocusEvent):void {
			super.focusInHandler(event);
			if (editable) {
				stage.focus = _inputField.textField;
			}
		}
		
		override protected function focusOutHandler(event:FocusEvent):void {
			isKeyDown = false;
			// If the dropdown is open...
			if (isOpen) {				
				// If focus is moving outside the dropdown...
				if (!event.relatedObject || !_list.contains(event.relatedObject)) {
					// Close the dropdown.
					if (highlightedCell != -1 && highlightedCell != selectedIndex) {
						selectedIndex = highlightedCell;
						dispatchEvent(new Event(Event.CHANGE));
					}
					close();
				}
			}
			super.focusOutHandler(event);
		}
		
		protected function handleDataChange(event:DataChangeEvent):void {
			invalidate(InvalidationType.DATA);
		}
		override protected function draw():void {
			if (isInvalid(InvalidationType.STYLES)) {
				background = getDisplayObjectInstance(getStyleValue("backgroundSkin")) as YBaseButton;
				inputField = getDisplayObjectInstance(getStyleValue("inputFieldSkin")) as YTextInput;
				list = getDisplayObjectInstance(getStyleValue("listSkin")) as YList;
				if(_dataProvider){
					_list.dataProvider = _dataProvider;
				}
//				_list.drawNow();
//				_inputField.drawNow();
//				_background.drawNow();
				
				setEmbedFonts();				
				invalidate(InvalidationType.SIZE, false);
			}
			// Fix the selectedIndex before redraw.
			var _selectedIndex : int = selectedIndex;
			
			// Check if index is -1, and it is allowed.
			if (_selectedIndex == -1 && (prompt != null || editable || length == 0)) {
				_selectedIndex = Math.max(-1, Math.min(_selectedIndex, length-1));
			} else {
				editableValue = null;
				_selectedIndex = Math.max(0, Math.min(_selectedIndex, length-1));	
			}
			if (_list.selectedIndex != _selectedIndex) {
				_list.selectedIndex = _selectedIndex;
				invalidate(InvalidationType.SELECTED, false);
			}
			
			
			if (isInvalid(InvalidationType.SIZE, InvalidationType.DATA, InvalidationType.STATE)) {
				drawTextFormat();
				drawLayout();
				invalidate(InvalidationType.DATA);
			}
			if (isInvalid(InvalidationType.DATA)) {
				drawList();
				invalidate(InvalidationType.SELECTED, true);
			}
			if (isInvalid(InvalidationType.SELECTED)) {
				if (_selectedIndex == -1 && editableValue != null) {
					_inputField.text = editableValue;
				} else if (_selectedIndex > -1) {
					if (length > 0) {
						_inputField.horizontalScrollPosition = 0;
						_inputField.text = itemToLabel(_list.selectedItem);
					}
				} else if(_selectedIndex == -1 && _prompt != null) {
					showPrompt();
				} else {
					_inputField.text = "";	
				}
				
				if (editable && selectedIndex > -1 && stage.focus == _inputField.textField) {
					_inputField.setSelection(0,_inputField.length);
				}
			}			
			drawTextField();
			
			_list.drawNow();
			_inputField.drawNow();
			_background.drawNow();
			
			super.draw();
		}
		
		protected function setEmbedFonts():void {
			var embed:Object = getStyleValue("embedFonts");
			if (embed != null) {
				_inputField.textField.embedFonts = embed;
			}	
		}
		
		protected function showPrompt():void {
			_inputField.text = _prompt;
		}
		protected function drawLayout():void {
			var buttonWidth:Number = getStyleValue("buttonWidth") as Number;
			var textPaddingX:Number = getStyleValue("textPaddingX") as Number;
			var textPaddingY:Number = getStyleValue("textPaddingY") as Number;
			_background.setSize(width, height);
			_inputField.x = textPaddingX;
			_inputField.y = textPaddingY;
			_inputField.setSize(width - buttonWidth - textPaddingX, height - textPaddingY); // textPadding*2 cuts off the descenders.
			
			_list.width = (isNaN(_dropdownWidth)) ? width : _dropdownWidth;
			
			_background.enabled = enabled;
			_background.drawNow();
		}
		protected function drawTextFormat():void {
//			var tf:TextFormat = getStyleValue(_enabled?"textFormat":"disabledTextFormat") as TextFormat;
//			if (tf == null) { tf = new TextFormat(); }
//			_inputField.textField.defaultTextFormat = tf;
//			_inputField.textField.setTextFormat(tf);
//			setEmbedFonts();
		}

		protected function drawList():void {
			_list.rowCount = Math.max(0, Math.min(_rowCount, _list.dataProvider.length));
		}
		protected function positionList():void {
			var p:Point = localToGlobal(new Point(0,0));
			_list.x = p.x;
			if (p.y + height + _list.height > stage.stageHeight) {
				_list.y = p.y - _list.height;
			} else {
				_list.y = p.y + height;
			}
		}
		protected function drawTextField():void {
			_inputField.setStyle("upSkin", "");
			_inputField.setStyle("disabledSkin", "");

			_inputField.enabled = enabled;
			_inputField.editable = _editable;
			_inputField.textField.selectable = enabled && _editable;
			_inputField.mouseEnabled = _inputField.mouseChildren = enabled && _editable;
			_inputField.focusEnabled = false;
			
			if (_editable) {
				_inputField.addEventListener(FocusEvent.FOCUS_IN, onInputFieldFocus, false,0,true);
				_inputField.addEventListener(FocusEvent.FOCUS_OUT, onInputFieldFocusOut, false,0,true);
			} else {
				_inputField.removeEventListener(FocusEvent.FOCUS_IN, onInputFieldFocus);
				_inputField.removeEventListener(FocusEvent.FOCUS_OUT, onInputFieldFocusOut);
			}

		}
		protected function onInputFieldFocus(event:FocusEvent):void {
			_inputField.addEventListener(ComponentEvent.ENTER, onEnter, false, 0, true);
			close();
		}
		
		protected function onInputFieldFocusOut(event:FocusEvent):void {
			_inputField.removeEventListener(ComponentEvent.ENTER, onEnter);
			selectedIndex = selectedIndex;
		}
		
		protected function onEnter(event:ComponentEvent):void {
			event.stopPropagation();
		}
		protected function onToggleListVisibility(event:MouseEvent):void {
			event.stopPropagation();
			dispatchEvent(event);
			if (isOpen) {
				close()
			} else {
				open();
				// Add a listener to listen for press/drag/release behavior.
				// We will remove it once they release.
				stage.addEventListener(MouseEvent.MOUSE_UP, onListItemUp, false, 0, true);
			}
		}
		
		protected function onListItemUp(event:MouseEvent):void {
			stage.removeEventListener(MouseEvent.MOUSE_UP, onListItemUp);
			if (!(event.target is ICellRenderer ) || !_list.contains(event.target as DisplayObject)) {
				return;
			}
			
			editableValue = null;
			var startIndex : int = selectedIndex;
			selectedIndex = event.target.listData.index;
			
			if (startIndex != selectedIndex) {
				dispatchEvent(new Event(Event.CHANGE));
			}
			
			close();			
		}
		
		protected function onListChange(event:Event):void {
			editableValue = null;
			dispatchEvent(event);
			invalidate(InvalidationType.SELECTED);
			if (isKeyDown) { return; }
			close();
		}
		protected function onStageClick(event:MouseEvent):void {
			if (!isOpen) { return; }
			if (! contains(event.target as DisplayObject) && !_list.contains(event.target as DisplayObject)) {
				if (highlightedCell != -1) {
					selectedIndex = highlightedCell;
					dispatchEvent(new Event(Event.CHANGE));
				}
				close();
			}
		}

		protected function passEvent(event:Event):void {
			dispatchEvent(event);
		}
		
		private function addCloseListener(event:Event) :void {
			removeEventListener(Event.ENTER_FRAME, addCloseListener);
			if (!isOpen) { return; }
			stage.addEventListener(MouseEvent.MOUSE_DOWN, onStageClick, false, 0, true);
		}
		protected function onTextInput(event:Event):void {
			// Stop the TextInput CHANGE event
			event.stopPropagation();
			if (!_editable) { return; }
			// If editable, set the editableValue, and dispatch a change event.
			editableValue = _inputField.text;
			selectedIndex = -1;
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		protected function calculateAvailableHeight():Number {
			var pad:Number = Number(getStyleValue("contentPadding"));
			return _list.height-pad*2;
		}
		
		override protected function keyDownHandler(event:KeyboardEvent):void {
			isKeyDown = true;
			if (event.ctrlKey) {
				switch (event.keyCode) {
					case Keyboard.UP:
						if (highlightedCell > -1) {
							selectedIndex = highlightedCell;
							dispatchEvent(new Event(Event.CHANGE));
						}
						close();
						// Reset selectedIndex/prompt. Maybe dispatch change.
						break;
					case  Keyboard.DOWN:
						open();
						break;
				}
				return;
			}
			
			event.stopPropagation();
			
			var pageSize:int = Math.max((calculateAvailableHeight() / _list.rowHeight)<<0, 1);
			var sel:uint = selectedIndex;
			var lastSel:Number = (highlightedCell == -1) ? selectedIndex : highlightedCell;
			var newSel:int = -1;
			switch (event.keyCode) {
				case Keyboard.SPACE:
					isOpen ? close() : open();
					return;
				case Keyboard.ESCAPE:
					if (isOpen) { 
						if (highlightedCell > -1) {
							selectedIndex = selectedIndex;
						}
						close();
					}
					return;
					
				case Keyboard.UP:
					newSel = Math.max(0, lastSel-1);
					break;
				case Keyboard.DOWN:
					newSel = Math.min(length-1, lastSel+1);
					break;
				case Keyboard.PAGE_UP:
					newSel = Math.max(lastSel - pageSize, 0);
					break;
				case Keyboard.PAGE_DOWN:
					newSel = Math.min(lastSel + pageSize, length - 1);
					break;
				case Keyboard.HOME:
					newSel = 0;
					break;
				case Keyboard.END:
					newSel = length-1;
					break;
					
				case Keyboard.ENTER:
					if (_editable && highlightedCell == -1) {
						editableValue = _inputField.text;
						selectedIndex = -1;
					} else if (isOpen && highlightedCell > -1) {
						editableValue = null;
						selectedIndex = highlightedCell;
						dispatchEvent(new Event(Event.CHANGE));
					}
					dispatchEvent(new ComponentEvent(ComponentEvent.ENTER));
					close();
					return;
					
				default:
					if (editable) { break; } // Don't allow letter keys to change focus when editable.
					newSel = _list.getNextIndexAtLetter(String.fromCharCode(event.keyCode), lastSel);
					break;
			}
						
			if (newSel > -1) {
				if (isOpen) {
					highlightCell(newSel);
					_inputField.text = _list.itemToLabel(getItemAt(newSel));
				} else {
					highlightCell();
					selectedIndex = newSel;
					dispatchEvent(new Event(Event.CHANGE));					
				}
			}
		}
		
		protected function highlightCell(index:int=-1):void {
			var renderer:ICellRenderer;
			
			// Turn off the currently highlighted cell
			if (highlightedCell > -1) {
				renderer = _list.itemToCellRenderer(getItemAt(highlightedCell));
				if (renderer != null) {
					renderer.setMouseState("up");
				}
			}
			
			if (index == -1) { return; }
						
			// Scroll to the new index, so that the renderer is created
			_list.scrollToIndex(index);
			_list.drawNow();
			
			// Highlight the cellRenderer at the new index
			renderer = _list.itemToCellRenderer(getItemAt(index));
			if (renderer != null) {
				renderer.setMouseState("over");
				highlightedCell = index;
			}
		}
		
		override protected function keyUpHandler(event:KeyboardEvent):void {
			isKeyDown = false;
		}
	}
}