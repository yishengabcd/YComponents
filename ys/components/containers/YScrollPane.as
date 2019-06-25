package ys.components.containers {

	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.ui.Keyboard;
	
	import ys.components.containers.YBaseScrollPane;
	import ys.components.controls.YScrollPolicy;
	import ys.components.core.InvalidationType;
	import ys.components.events.ScrollEvent;
	import ys.components.focus.IFocusManagerComponent;

	[Event(name="scroll", type="ys.components.events.ScrollEvent")]
	[Event(name="init",type="flash.events.Event")]

	/**
	 * 包含滚动条的容器类.
	 * 可通过source方法指定容器的内容.
	 */	
	public class YScrollPane extends YBaseScrollPane implements IFocusManagerComponent {
        

		protected var _source:Object = "";
		protected var _scrollDrag:Boolean = false;
		protected var contentClip:Sprite;
		protected var xOffset:Number;
		protected var yOffset:Number;
		protected var scrollDragHPos:Number;
		protected var scrollDragVPos:Number;
		protected var currentContent:Object;

		private static var defaultStyles:Object = {contentPadding:0}


		public static function getStyleDefinition():Object {
			return mergeStyles(defaultStyles, YBaseScrollPane.getStyleDefinition());
		}

		public function YScrollPane() {
			super();
		}
		
		override protected function configUI():void {
			super.configUI();
			contentClip = new Sprite();
			contentClip.mouseEnabled = false;
			addChild(contentClip);
			contentClip.scrollRect = contentScrollRect;
			_horizontalScrollPolicy = YScrollPolicy.AUTO;
			_verticalScrollPolicy = YScrollPolicy.AUTO;
		}
		
		
		public function get scrollDrag():Boolean {
			return _scrollDrag;
		}

		public function set scrollDrag(value:Boolean):void {
			_scrollDrag = value;
			invalidate(InvalidationType.STATE);
		}

        /**
         * Refreshes the scroll bar properties based on the width
         * and height of the content.  This is useful if the content
         * of the ScrollPane changes during run time.
         *
         */
		public function update():void {
			var child:DisplayObject = contentClip.getChildAt(0);
			var rect : Rectangle = child.getBounds(contentClip);
			if(rect.width == 0)
			{
				rect.width = 1;
				rect.x = 0;
			}
			if(rect.height == 0)
			{
				rect.height = 1;
				rect.y = 0;
			}
//			setContentSize(child.width, child.height);
			setContentSize(rect.x+rect.width, rect.y +rect.height);
		}

        /**
         * Gets a reference to the content loaded into the scroll pane.
         */
		public function get content():DisplayObject {
			return currentContent as DisplayObject;
		}
		
		public function get source():Object {
			return _source;
		}
		/**
		 * 设置容器的内容.
		 * 可为显示对象或能产生显示对象的对象
		 * @param value 
		 * 
		 */		
		public function set source(value:Object):void {
			clearContent();
			
			_source = value;
			if (_source == "" || _source == null) {
				return;
			}
			
			currentContent = getDisplayObjectInstance(value);
			if (currentContent != null) {
				var child : DisplayObject= contentClip.addChild(currentContent as DisplayObject);
				dispatchEvent(new Event(Event.INIT));
				update();
			}
		}

		override protected function setVerticalScrollPosition(scrollPos:Number, fireEvent:Boolean=false):void {
			var contentScrollRect : Rectangle = contentClip.scrollRect;
			contentScrollRect.y = scrollPos;
			contentClip.scrollRect = contentScrollRect;
		}

		override protected function setHorizontalScrollPosition(scrollPos:Number, fireEvent:Boolean=false):void {
			var contentScrollRect : Rectangle= contentClip.scrollRect;
			contentScrollRect.x = scrollPos;
			contentClip.scrollRect = contentScrollRect;
		}

		override protected function drawLayout():void {
			super.drawLayout();
			contentScrollRect = contentClip.scrollRect;
			contentScrollRect.width = availableWidth;
			contentScrollRect.height = availableHeight;
			
			contentClip.cacheAsBitmap = useBitmapScrolling;
			contentClip.scrollRect = contentScrollRect;
			contentClip.x = contentClip.y = contentPadding;
		}

		override protected function handleScroll(event:ScrollEvent):void {
			dispatchEvent(event);
			super.handleScroll(event);
		}

		protected function doDrag(event:MouseEvent):void {
			var yPos : Number= scrollDragVPos-(mouseY-yOffset);
			_verticalScrollBar.setScrollPosition(yPos);
			setVerticalScrollPosition(_verticalScrollBar.scrollPosition,true);
			
			var xPos : Number= scrollDragHPos-(mouseX-xOffset);
			_horizontalScrollBar.setScrollPosition(xPos);
			setHorizontalScrollPosition(_horizontalScrollBar.scrollPosition,true);
		}

		protected function doStartDrag(event:MouseEvent):void {
			if (!enabled) { return; }
			xOffset = mouseX;
			yOffset = mouseY;
			scrollDragHPos = horizontalScrollPosition;
			scrollDragVPos = verticalScrollPosition;
			stage.addEventListener(MouseEvent.MOUSE_MOVE, doDrag, false, 0, true);
		}

		protected function endDrag(event:MouseEvent):void {
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, doDrag);
		}

		protected function setScrollDrag():void {
			if (_scrollDrag) {
				contentClip.addEventListener(MouseEvent.MOUSE_DOWN, doStartDrag, false, 0, true);
				stage.addEventListener(MouseEvent.MOUSE_UP, endDrag, false, 0, true);
			} else {
				contentClip.removeEventListener(MouseEvent.MOUSE_DOWN, doStartDrag);
				stage.removeEventListener(MouseEvent.MOUSE_UP, endDrag);
				removeEventListener(MouseEvent.MOUSE_MOVE, doDrag);
			}
			contentClip.buttonMode = _scrollDrag;
		}

		override protected function draw():void {
			if (isInvalid(InvalidationType.STYLES)) {
				drawBackground();
				setStyles();
				// drawLayout is expensive, so only do it if padding has changed:
				if (contentPadding != getStyleValue("contentPadding")) {
					invalidate(InvalidationType.SIZE,false);
				}
			}
			if (isInvalid(InvalidationType.STATE)) {
				setScrollDrag();
				drawLayout();
			}
			if (isInvalid(InvalidationType.SIZE)) {
				drawLayout();
			}
			// Call drawNow() on nested components to get around problems with nested render events:
			updateChildren();
			validate();
		}

		override protected function drawBackground():void {
			var bg:DisplayObject = _background;
			_background = getDisplayObjectInstance(getStyleValue("backgroundSkin"));
			if(_background){				
				_background.width = width;
				_background.height = height;
				addChildAt(_background,0);
			}
			if (bg != null && bg != _background) { removeChild(bg); }
		}

		protected function clearContent():void {
			if (contentClip.numChildren == 0) { return; }
			contentClip.removeChildAt(0);
			currentContent = null;
		}

		override protected function keyDownHandler(event:KeyboardEvent):void {
			var pageSize:int = calculateAvailableHeight();
			switch (event.keyCode) {
				case Keyboard.DOWN:
					verticalScrollPosition++;
					break;
				case Keyboard.UP:
					verticalScrollPosition--;
					break;
				case Keyboard.RIGHT:
					horizontalScrollPosition++;
					break;
				case Keyboard.LEFT:
					horizontalScrollPosition--;
					break;
				case Keyboard.END:
					verticalScrollPosition = maxVerticalScrollPosition;
					break;
				case Keyboard.HOME:
					verticalScrollPosition = 0;
					break;
				case Keyboard.PAGE_UP:
					verticalScrollPosition -= pageSize;
					break;
				case Keyboard.PAGE_DOWN:
					verticalScrollPosition += pageSize;
					break;
			}
		}

		protected function calculateAvailableHeight():Number {
			var pad:Number = Number(getStyleValue("contentPadding"));
			return height-pad*2-((_horizontalScrollPolicy == YScrollPolicy.ON || (_horizontalScrollPolicy == YScrollPolicy.AUTO && _maxHorizontalScrollPosition > 0)) ? 15 : 0);
		}
	}
}
