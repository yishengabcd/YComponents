package ys.components.controls {
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.ui.Keyboard;
	import flash.utils.Dictionary;
	
	import ys.components.controls.listClasses.ICellRenderer;
	import ys.components.controls.listClasses.ListData;
	import ys.components.core.InvalidationType;
	import ys.components.core.YComponent;
	import ys.components.focus.IFocusManagerComponent;
	
	public class YList extends YSelectableList implements IFocusManagerComponent{

		protected var _rowHeight:Number = 20;
		protected var _cellRenderer:Object;
		protected var _labelField:String="label";
		protected var _labelFunction:Function;

		
		private static var defaultStyles:Object = {};

		public static function getStyleDefinition():Object { 
			return mergeStyles(defaultStyles, YSelectableList.getStyleDefinition());
		}


		public function YList() {
			super();
		}
		

		public function get labelField():String {
			return _labelField;
		}
		public function set labelField(value:String):void {
			if (value == _labelField) { return; }
			_labelField = value;
			invalidate(InvalidationType.DATA);
		}

		public function get labelFunction():Function {
			return _labelFunction;
		}
		public function set labelFunction(value:Function):void {
			if (_labelFunction == value) { return; }
			_labelFunction = value;
			invalidate(InvalidationType.DATA);
		}
		
		/**
		 * Gets or sets the number of rows that are at least partially visible in the 
         * list.
		 */
		override public function get rowCount():uint {
			//This is low right now (ie. doesn't count two half items as a whole):
			return Math.ceil(calculateAvailableHeight()/rowHeight);
		}
		public function set rowCount(value:uint):void {
			var pad:Number = Number(getStyleValue("contentPadding"));
			var scrollBarHeight:Number = (_horizontalScrollPolicy == YScrollPolicy.ON || (_horizontalScrollPolicy == YScrollPolicy.AUTO && _maxHorizontalScrollPosition > 0)) ? 15 : 0;
			height = rowHeight*value+2*pad+scrollBarHeight;
		}
		
		/**
		 * Gets or sets the height of each row in the list, in pixels.
         *
         * @default 20
		 */
		public function get rowHeight():Number {
			return _rowHeight;
		}
		public function set rowHeight(value:Number):void {
			_rowHeight = value;
			invalidate(InvalidationType.SIZE);
		}
		
		override public function scrollToIndex(newCaretIndex:int):void {
			drawNow();
			
			var lastVisibleItemIndex:uint = Math.floor((_verticalScrollPosition + availableHeight) / rowHeight) - 1;
			var firstVisibleItemIndex:uint = Math.ceil(_verticalScrollPosition / rowHeight);
			if(newCaretIndex < firstVisibleItemIndex) {
				verticalScrollPosition = newCaretIndex * rowHeight;
			} else if(newCaretIndex > lastVisibleItemIndex) {
				verticalScrollPosition = (newCaretIndex + 1) * rowHeight - availableHeight;
			}
		}
		
		override protected function configUI():void {
			useFixedHorizontalScrolling = true;
			_horizontalScrollPolicy = YScrollPolicy.AUTO;
			_verticalScrollPolicy = YScrollPolicy.AUTO;
			
			super.configUI();
		}
		
		protected function calculateAvailableHeight():Number {
			var pad:Number = Number(getStyleValue("contentPadding"));
			return height-pad*2-((_horizontalScrollPolicy == YScrollPolicy.ON || (_horizontalScrollPolicy == YScrollPolicy.AUTO && _maxHorizontalScrollPosition > 0)) ? 15 : 0);
		}
		
		override protected function setHorizontalScrollPosition(value:Number,fireEvent:Boolean=false):void {
			list.x = -value;
			super.setHorizontalScrollPosition(value, true);
		}
		
		override protected function setVerticalScrollPosition(scroll:Number,fireEvent:Boolean=false):void {
			// This causes problems. It seems like the render event can get "blocked" if it's called from within a callLater
			invalidate(InvalidationType.SCROLL);
			super.setVerticalScrollPosition(scroll, true);
		}
		override protected function draw():void {
			var contentHeightChanged:Boolean = (contentHeight != rowHeight*length);
			contentHeight = rowHeight*length;
			
			if (isInvalid(InvalidationType.STYLES)) {
				drawBackground();
				setStyles();
				// drawLayout is expensive, so only do it if padding has changed:
				if (contentPadding != getStyleValue("contentPadding")) {
					invalidate(InvalidationType.SIZE,false);
				}
				// redrawing all the cell renderers is even more expensive, so we really only want to do it if necessary:
				if (_cellRenderer != getStyleValue("cellRenderer")) {
					// remove all the existing renderers:
					_invalidateList();
					_cellRenderer = getStyleValue("cellRenderer");
				}
			}
			if (isInvalid(InvalidationType.SIZE, InvalidationType.STATE) || contentHeightChanged) {
				drawLayout();
			}
			
			if (isInvalid(InvalidationType.RENDERER_STYLES)) {
				updateRendererStyles();	
			}
			
			if (isInvalid(InvalidationType.STYLES,InvalidationType.SIZE,InvalidationType.DATA,InvalidationType.SCROLL,InvalidationType.SELECTED)) {
				drawList();
			}
			
			// Call drawNow on nested components to get around problems with nested render events:
			updateChildren();
			
			// Not calling super.draw, because we're handling everything here. Instead we'll just call validate();
			validate();
		}
		override protected function drawList():void {
			// List is very environmentally friendly, it reuses existing 
			// renderers for old data, and recycles old renderers for new data.

			// set horizontal scroll:
			listHolder.x = listHolder.y = contentPadding;
			
			var rect:Rectangle = listHolder.scrollRect;
			rect.x = _horizontalScrollPosition;
			
			// set pixel scroll:
			rect.y = Math.floor(_verticalScrollPosition)%rowHeight;
			listHolder.scrollRect = rect;
			
			listHolder.cacheAsBitmap = useBitmapScrolling;
			
			// figure out what we have to render:
			var startIndex:uint = Math.floor(_verticalScrollPosition/rowHeight);
			var endIndex:uint = Math.min(length,startIndex + rowCount+1);
			
			
			// these vars get reused in different loops:
			var i:uint;
			var item:Object;
			var renderer:ICellRenderer;
			
			// create a dictionary for looking up the new "displayed" items:
			var itemHash:Dictionary = renderedItems = new Dictionary(true);
			for (i=startIndex; i<endIndex; i++) {
				itemHash[_dataProvider.getItemAt(i)] = true;
			}
			
			// find cell renderers that are still active, and make those that aren't active available:
			var itemToRendererHash:Dictionary = new Dictionary(true);
			while (activeCellRenderers.length > 0) {
				renderer = activeCellRenderers.pop() as ICellRenderer;
				item = renderer.data;
				if (itemHash[item] == null || invalidItems[item] == true) {
					availableCellRenderers.push(renderer);
				} else {
					itemToRendererHash[item] = renderer;
					// prevent problems with duplicate objects:
					invalidItems[item] = true;
				}
				list.removeChild(renderer as DisplayObject);
			}
			invalidItems = new Dictionary(true);
			
			// draw cell renderers:
			for (i=startIndex; i<endIndex; i++) {
				var reused:Boolean = false;
				item = _dataProvider.getItemAt(i);
				if (itemToRendererHash[item] != null) {
					// existing renderer for this item we can reuse:
					
					reused = true;
					renderer = itemToRendererHash[item];
					delete(itemToRendererHash[item]);
				} else if (availableCellRenderers.length > 0) {
					
					// recycle an old renderer:
					renderer = availableCellRenderers.pop() as ICellRenderer;
				} else {
					
					// out of renderers, create a new one:
					renderer = getDisplayObjectInstance(getStyleValue("cellRenderer")) as ICellRenderer;
					var rendererSprite:Sprite = renderer as Sprite;
					if (rendererSprite != null) {
						rendererSprite.addEventListener(MouseEvent.CLICK,handleCellRendererClick,false,0,true);
						rendererSprite.addEventListener(MouseEvent.ROLL_OVER,handleCellRendererMouseEvent,false,0,true);
						rendererSprite.addEventListener(MouseEvent.ROLL_OUT,handleCellRendererMouseEvent,false,0,true);
						rendererSprite.addEventListener(Event.CHANGE,handleCellRendererChange,false,0,true);
						rendererSprite.doubleClickEnabled = true;
						rendererSprite.addEventListener(MouseEvent.DOUBLE_CLICK,handleCellRendererDoubleClick,false,0,true);
						
						if (rendererSprite.hasOwnProperty("setStyle")) {
							for (var n:String in rendererStyles) {
								rendererSprite["setStyle"](n, rendererStyles[n])
							}
						}
					}
				}
				list.addChild(renderer as Sprite);
				activeCellRenderers.push(renderer);
				
				renderer.y = rowHeight*(i-startIndex);
				renderer.setSize(availableWidth+_maxHorizontalScrollPosition,rowHeight);
				
				var label:String = itemToLabel(item);
				
				if (!reused) {
					renderer.data = item;
				}
				renderer.listData = new ListData(label,null,this,i,i,0);
				renderer.selected = (_selectedIndices.indexOf(i) != -1);
				
				// force an immediate draw (because render event will not be called on the renderer):
				if (renderer is YComponent) {
					(renderer as YComponent).drawNow();
				}
			}
		}
		
		override protected function keyDownHandler(event:KeyboardEvent):void {
			if (!selectable) { return; }
			switch (event.keyCode) {
				case Keyboard.UP:
				case Keyboard.DOWN:
				case Keyboard.END:
				case Keyboard.HOME:
				case Keyboard.PAGE_UP:
				case Keyboard.PAGE_DOWN:
					moveSelectionVertically(event.keyCode, event.shiftKey && _allowMultipleSelection, event.ctrlKey && _allowMultipleSelection);
					break;
				case Keyboard.LEFT:
				case Keyboard.RIGHT:
					moveSelectionHorizontally(event.keyCode, event.shiftKey && _allowMultipleSelection, event.ctrlKey && _allowMultipleSelection);
					break;
				case Keyboard.SPACE:
					if(caretIndex == -1) {
						caretIndex = 0;
					}
					doKeySelection(caretIndex, event.shiftKey, event.ctrlKey);
					scrollToSelected();
					break;
				default:
					var nextIndex:int = getNextIndexAtLetter(String.fromCharCode(event.keyCode), selectedIndex);
					if (nextIndex > -1) {
						selectedIndex = nextIndex;
						scrollToSelected();
					}
					break;
			}
			event.stopPropagation();
			
			
			
		}

		/**
         * @private (protected)
		 * Moves the selection in a horizontal direction in response
		 * to the user selecting items using the left-arrow or right-arrow
		 * keys and modifiers such as  the Shift and Ctrl keys.
		 *
		 * <p>Not implemented in List because the default list
		 * is single column and therefore doesn't scroll horizontally.</p>
		 *
		 * @param code The key that was pressed (e.g. Keyboard.LEFT)
         *
		 * @param shiftKey <code>true</code> if the shift key was held down when
		 *        the keyboard key was pressed.
         *
		 * @param ctrlKey <code>true</code> if the ctrl key was held down when
         *        the keyboard key was pressed.
		 */
		override protected function moveSelectionHorizontally(code:uint, shiftKey:Boolean, ctrlKey:Boolean):void {}
		
		/**
         * @private (protected)
		 * Moves the selection in a vertical direction in response
		 * to the user selecting items using the up-arrow or down-arrow
		 * Keys and modifiers such as the Shift and Ctrl keys.
		 *
		 * @param code The key that was pressed (e.g. Keyboard.DOWN)
         *
		 * @param shiftKey <code>true</code> if the shift key was held down when
		 *        the keyboard key was pressed.
         *
		 * @param ctrlKey <code>true</code> if the ctrl key was held down when
         *        the keyboard key was pressed.
		 */
		override protected function moveSelectionVertically(code:uint, shiftKey:Boolean, ctrlKey:Boolean):void {
			var pageSize:int = Math.max(Math.floor(calculateAvailableHeight() / rowHeight), 1);
			var newCaretIndex:int = -1;
			var dir:int = 0;
			switch(code) {
				case Keyboard.UP:
					if (caretIndex > 0) {
						newCaretIndex = caretIndex - 1;
					}
					break;
				case Keyboard.DOWN:
					if (caretIndex < length - 1) {
						newCaretIndex = caretIndex + 1;
					}
					break;
				case Keyboard.PAGE_UP:
					if (caretIndex > 0) {
						newCaretIndex = Math.max(caretIndex - pageSize, 0);
					}
					break;
				case Keyboard.PAGE_DOWN:
					if (caretIndex < length - 1) {
						newCaretIndex = Math.min(caretIndex + pageSize, length - 1);
					}
					break;
				case Keyboard.HOME:
					if (caretIndex > 0) {
						newCaretIndex = 0;
					}
					break;
				case Keyboard.END:
					if (caretIndex < length - 1) {
						newCaretIndex = length - 1;
					}
					break;
			}
			if(newCaretIndex >= 0) {
				doKeySelection(newCaretIndex, shiftKey, ctrlKey);
				scrollToSelected();
			}
		}
		
		protected function doKeySelection(newCaretIndex:int, shiftKey:Boolean, ctrlKey:Boolean):void {
			var selChanged:Boolean = false;
			if(shiftKey) {
				var i:int;
				var selIndices:Array = [];
				var startIndex:int = lastCaretIndex;
				var endIndex:int = newCaretIndex;
				if(startIndex == -1) {
					startIndex = caretIndex != -1 ? caretIndex : newCaretIndex;
				}
				if(startIndex > endIndex) {
					endIndex = startIndex;
					startIndex = newCaretIndex;
				}
				for(i = startIndex; i <= endIndex; i++) {
					selIndices.push(i);
				}
				selectedIndices = selIndices;
				caretIndex = newCaretIndex;
				selChanged = true;
			} else {
				selectedIndex = newCaretIndex;
				caretIndex = lastCaretIndex = newCaretIndex;
				selChanged = true;
			}
			if(selChanged) {
				dispatchEvent(new Event(Event.CHANGE));
			}
			invalidate(InvalidationType.DATA);
		}
		
		/**
		 * Retrieves the string that the renderer displays for the given data object 
         * based on the <code>labelField</code> and <code>labelFunction</code> properties.
         *
         * <p><strong>Note:</strong> The <code>labelField</code> is not used  
         * if the <code>labelFunction</code> property is set to a callback function.</p>
		 *
		 * @param item The object to be rendered.
		 *
         * @return The string to be displayed based on the data.
         *
         * @internal <code>var label:String = myList.itemToLabel(data);</code>
         *
		 */
		override public function itemToLabel(item:Object):String {
			if (_labelFunction != null) {
				return String(_labelFunction(item));
			} else  {
				return (item[_labelField]!=null) ? String(item[_labelField]) : "";
			}
		}
	}
}
