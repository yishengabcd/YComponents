package ys.components.controls {	

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.Timer;
	
	import ys.components.controls.YBaseButton;
	import ys.components.controls.YScrollBarDirection;
	import ys.components.controls.YTextInput;
	import ys.components.core.InvalidationType;
	import ys.components.core.YComponent;
	import ys.components.events.ComponentEvent;
	import ys.components.events.ScrollEvent;
	

	[Event(name="scroll", type="ys.components.events.ScrollEvent") ]

	public class YScrollBar extends YComponent {

		public static const WIDTH:Number = 15;
		private var _pageSize:Number = 10;
		private var _pageScrollSize:Number = 0;
		private var _lineScrollSize:Number = 1;
		private var _minScrollPosition:Number = 0;
		private var _maxScrollPosition:Number = 0;
		private var _scrollPosition:Number = 0;
		private var _direction:String = YScrollBarDirection.VERTICAL;
		private var thumbScrollOffset:Number;
		protected var inDrag:Boolean = false;
		protected var _upArrow:YBaseButton;
		protected var _downArrow:YBaseButton;
		protected var _thumb:YBaseButton;
		protected var _track:YBaseButton;
		private var _thumbMinHeight : int
		private var _trackXoffset : Number
		
        // Note that there is currently no disabled state for thumb, 
		// and track only has one state.

		private static var defaultStyles:Object = {downArrowSkin:null,
													thumbSkin:null,
													trackSkin:null,
													upArrowSkin:null,
													thumbMinHeight : 13,
													repeatDelay:500,
													repeatInterval:35,
													trackXoffset : 0};

		public static function getStyleDefinition():Object { 
			return defaultStyles;
		}
		

		public function YScrollBar() {
			super();
			focusEnabled = false;
		}
		
		override public function setSize(width:Number, height:Number):void {
			if (_direction == YScrollBarDirection.HORIZONTAL) {
				super.setSize(height,width);
			} else {
				super.setSize(width,height);
			}
		}
		
		override public function get width():Number {
			return (_direction == YScrollBarDirection.HORIZONTAL) ? super.height : super.width;
		}
		
		override public function get height():Number {
			return (_direction == YScrollBarDirection.HORIZONTAL) ? super.width : super.height;
		}
		
		override public function get enabled():Boolean {
			return super.enabled;
		}
		override public function set enabled(value:Boolean):void {
			super.enabled = value;
			_downArrow.enabled = _track.enabled = _thumb.enabled = _upArrow.enabled = (enabled && _maxScrollPosition > _minScrollPosition);
			updateThumb();
		}
		
		/**
         * Sets the range and viewport size of the ScrollBar component. The ScrollBar 
         * component updates the state of the arrow buttons and size of the scroll 
         * thumb accordingly. All of the scroll properties are relative to the
		 * scale of the <code>minScrollPosition</code> and the <code>maxScrollPosition</code>.
		 * Each number between the maximum and minumum values represents one scroll position.
		 *
		 * @param pageSize Size of one page. Determines the size of the thumb, and the increment by which the scroll bar moves when the arrows are clicked.
 		 * @param minScrollPosition Bottom of the scrolling range.
		 * @param maxScrollPosition Top of the scrolling range.
		 * @param pageScrollSize Increment to move when a track is pressed, in pixels.
		 *
         * @see #maxScrollPosition
         * @see #minScrollPosition
         * @see #pageScrollSize
         * @see #pageSize
         *
		 */
		public function setScrollProperties(pageSize:Number,minScrollPosition:Number,maxScrollPosition:Number,pageScrollSize:Number=0):void {
			this.pageSize = pageSize;
			_minScrollPosition = minScrollPosition;
			_maxScrollPosition = maxScrollPosition;
			if (pageScrollSize >= 0) { _pageScrollSize = pageScrollSize; }
			enabled = (_maxScrollPosition > _minScrollPosition);
			// ensure our scroll position is still in range:
			setScrollPosition(_scrollPosition, false);
			updateThumb();
		}
		
		/**
		 * Gets or sets the current scroll position and updates the position 
         * of the thumb. The <code>scrollPosition</code> value represents a relative position between
		 * the <code>minScrollPosition</code> and <code>maxScrollPosition</code> values.
         *
         * @default 0
         *
         * @see #setScrollProperties()
         * @see #minScrollPosition
		 * @see #maxScrollPosition
		 *
		 */
		public function get scrollPosition():Number { return _scrollPosition; }
		
		public function set scrollPosition(newScrollPosition:Number):void {
			setScrollPosition(newScrollPosition, true);
		}
		
		/**
		 * Gets or sets a number that represents the minimum scroll position.  The 
		 * <code>scrollPosition</code> value represents a relative position between the
		 * <code>minScrollPosition</code> and the <code>maxScrollPosition</code> values.
		 * This property is set by the component that contains the scroll bar,
		 * and is usually zero.
         *
         * @default 0
         *
         * @see #setScrollProperties()
		 * @see #maxScrollPosition
		 * @see #scrollPosition
         *
		 */
		public function get minScrollPosition():Number {
			return _minScrollPosition;
		}		
		public function set minScrollPosition(value:Number):void {
			// This uses setScrollProperties because it needs to update thumb and enabled.
			setScrollProperties(_pageSize,value,_maxScrollPosition);
		}
		
		/**
		 * Gets or sets a number that represents the maximum scroll position. The
		 * <code>scrollPosition</code> value represents a relative position between the
		 * <code>minScrollPosition</code> and the <code>maxScrollPosition</code> values.
		 * This property is set by the component that contains the scroll bar,
		 * and is the maximum value. Usually this property describes the number
		 * of pixels between the bottom of the component and the bottom of
		 * the content, but this property is often set to a different value to change the
		 * behavior of the scrolling.  For example, the TextArea component sets this
		 * property to the <code>maxScrollH</code> value of the text field, so that the 
		 * scroll bar scrolls appropriately by line of text.
         *
         * @default 0
         *
         * @see #setScrollProperties()
		 * @see #minScrollPosition
		 * @see #scrollPosition
         *
		 */
		public function get maxScrollPosition():Number {
			return _maxScrollPosition;
		}		
		public function set maxScrollPosition(value:Number):void {
			// This uses setScrollProperties because it needs to update thumb and enabled.
			setScrollProperties(_pageSize,_minScrollPosition,value);
		}
		
		/**
		 * Gets or sets the number of lines that a page contains. The <code>lineScrollSize</code>
		 * is measured in increments between the <code>minScrollPosition</code> and 
		 * the <code>maxScrollPosition</code>. If this property is 0, the scroll bar 
		 * will not scroll.
         *
         * @default 10
         *
		 * @see #maxScrollPosition
		 * @see #minScrollPosition
         * @see #setScrollProperties()
		 */
		public function get pageSize():Number {
			return _pageSize;
		}
		public function set pageSize(value:Number):void {
			if (value > 0) {
				_pageSize = value;
			}
		}
		/**
		 * Gets or sets a value that represents the increment by which the page is scrolled
		 * when the scroll bar track is pressed. The <code>pageScrollSize</code> value is 
		 * measured in increments between the <code>minScrollPosition</code> and the 
		 * <code>maxScrollPosition</code> values. If this value is set to 0, the value of the
		 * <code>pageSize</code> property is used.
         *
         * @default 0
		 *
		 * @see #maxScrollPosition
		 * @see #minScrollPosition
         *
		 */
		public function get pageScrollSize():Number {
			return (_pageScrollSize == 0) ? _pageSize : _pageScrollSize;
		}
		public function set pageScrollSize(value:Number):void {
			if (value>=0) { _pageScrollSize = value; }
		}
		
		/**
		 * Gets or sets a value that represents the increment by which to scroll the page
		 * when the scroll bar track is pressed. The <code>pageScrollSize</code> is measured 
		 * in increments between the <code>minScrollPosition</code> and the <code>maxScrollPosition</code> 
         * values. If this value is set to 0, the value of the <code>pageSize</code> property is used.
         *
         * @default 0
		 *
		 * @see #maxScrollPosition
		 * @see #minScrollPosition
         *
		 */
		public function get lineScrollSize():Number {
			return _lineScrollSize;
		}		
		public function set lineScrollSize(value:Number):void {
			if (value>0) {_lineScrollSize = value; }
		}
		
		/**
		 * Gets or sets a value that indicates whether the scroll bar scrolls horizontally or vertically.
         * Valid values are <code>ScrollBarDirection.HORIZONTAL</code> and 
         * <code>ScrollBarDirection.VERTICAL</code>.
         *
         * @default ScrollBarDirection.VERTICAL
         *
         * @see ys.components.controls.ScrollBarDirection ScrollBarDirection
         *
		 */
		public function get direction():String {
			return _direction;
		}
		public function set direction(value:String):void {
			if (_direction == value) { return; }
			_direction = value;
			//
			setScaleY(1);			
			
			var horizontal:Boolean = _direction == YScrollBarDirection.HORIZONTAL;
			
			if (horizontal && rotation == 0) {
				rotation = -90;
				setScaleX(-1);
			} else if (!horizontal && rotation == -90 ) {
				rotation = 0;
				setScaleX(1);
			}
			invalidate(InvalidationType.SIZE);
		}
		override protected function configUI():void {
			super.configUI();
			//enabled = false;
		}
		
		
		public function set upArrow(value : YBaseButton):void
		{
			_upArrow = value;
//			_upArrow.setSize(WIDTH,14);
//			_upArrow.move(0,0);
			_upArrow.autoRepeat = true;
			_upArrow.focusEnabled = false;
			addChild(_upArrow);
			
			_upArrow.addEventListener(ComponentEvent.BUTTON_DOWN,scrollPressHandler,false,0,true);
			
		}
		public function set downArrow(value : YBaseButton):void
		{
			_downArrow = value;
//			_downArrow.setSize(WIDTH,14);
			_downArrow.autoRepeat = true;
			_downArrow.focusEnabled = false;
			addChild(_downArrow);
			
			_downArrow.addEventListener(ComponentEvent.BUTTON_DOWN,scrollPressHandler,false,0,true);
		}
		public function set thumb(value : YBaseButton):void
		{
			_thumb = value
//			_thumb.setSize(WIDTH,15);
//			_thumb.move(0,15);
			_thumb.focusEnabled = false;
			addChild(_thumb);
			
			_thumb.addEventListener(MouseEvent.MOUSE_DOWN,thumbPressHandler,false,0,true);
		}
		
		public function set track(value : YBaseButton):void
		{
			_track = value;
//			_track.move(0,14);
			_track.useHandCursor = false;
			_track.autoRepeat = true;
			_track.focusEnabled = false;
			addChild(_track);
			
			_track.addEventListener(ComponentEvent.BUTTON_DOWN,scrollPressHandler,false,0,true);
		}
		override protected function draw():void {	
			
			if (isInvalid(InvalidationType.STYLES)) {
				_thumbMinHeight = int(getStyleValue("thumbMinHeight"))
				_trackXoffset = Number(getStyleValue("trackXoffset"))
				track = getDisplayObjectInstance(getStyleValue("trackSkin")) as YBaseButton
				thumb = getDisplayObjectInstance(getStyleValue("thumbSkin")) as YBaseButton
				downArrow = getDisplayObjectInstance(getStyleValue("downArrowSkin")) as YBaseButton
				upArrow = getDisplayObjectInstance(getStyleValue("upArrowSkin")) as YBaseButton
					
				drawMembers();
			}
			
			if (isInvalid(InvalidationType.SIZE)) {
				var h:Number = super.height;
				if(isNaN(h)){
					h = 0;
				}
				_downArrow.move(0,  Math.max(_upArrow.height, h-_downArrow.height));
				_track.height = Math.max(0, h-(_downArrow.height + _upArrow.height));
				updateThumb();
				drawMembers();
				
				var centerX : Number = (_upArrow.width - _thumb.width)*0.5
				_thumb.move(centerX,_upArrow.height);
				_track.move(_trackXoffset,_upArrow.height);
			}else{
				// Call drawNow on nested components to get around problems with nested render events:
				drawMembers();
			}
			
			validate();
		}
		private function drawMembers():void
		{
			_downArrow.drawNow();
			_upArrow.drawNow();
			_track.drawNow();
			_thumb.drawNow();
		}
		
		protected function scrollPressHandler(event:ComponentEvent):void {
			event.stopImmediatePropagation();
			if (event.currentTarget == _upArrow) {
				setScrollPosition(_scrollPosition-_lineScrollSize); 
			} else if (event.currentTarget == _downArrow) {
				setScrollPosition(_scrollPosition+_lineScrollSize);
			} else {
				var mousePosition:Number = (_track.mouseY)/_track.height * (_maxScrollPosition-_minScrollPosition) + _minScrollPosition;
				var pgScroll:Number = (pageScrollSize == 0)?pageSize:pageScrollSize;
				if (_scrollPosition < mousePosition) {
					setScrollPosition(Math.min(mousePosition,_scrollPosition+pgScroll));
				} else if (_scrollPosition > mousePosition) {
					setScrollPosition(Math.max(mousePosition,_scrollPosition-pgScroll));
				}
			}
		}
		protected function thumbPressHandler(event:MouseEvent):void {
			inDrag = true;
			thumbScrollOffset = mouseY-_thumb.y;
			_thumb.mouseStateLocked = true;
			mouseChildren = false; // Should be able to do stage.mouseChildren, but doesn't seem to work.
			stage.addEventListener(MouseEvent.MOUSE_MOVE,handleThumbDrag,false,0,true);
			stage.addEventListener(MouseEvent.MOUSE_UP,thumbReleaseHandler,false,0,true);
		}
		protected function handleThumbDrag(event:MouseEvent):void {
			var pos:Number = Math.max(0, Math.min(_track.height-_thumb.height, mouseY-_track.y-thumbScrollOffset));
			setScrollPosition(pos/(_track.height-_thumb.height) * (_maxScrollPosition-_minScrollPosition) + _minScrollPosition);
		}
		
		protected function thumbReleaseHandler(event:MouseEvent):void {
			inDrag = false;
			mouseChildren = true;
			_thumb.mouseStateLocked = false;
			stage.removeEventListener(MouseEvent.MOUSE_MOVE,handleThumbDrag);
			stage.removeEventListener(MouseEvent.MOUSE_UP,thumbReleaseHandler);
		}
		public function setScrollPosition(newScrollPosition:Number, fireEvent:Boolean=true):void {
			var oldPosition:Number = scrollPosition;
			_scrollPosition = Math.max(_minScrollPosition,Math.min(_maxScrollPosition, newScrollPosition));
			if (oldPosition == _scrollPosition) { return; }
			if (fireEvent) { dispatchEvent(new ScrollEvent(_direction, scrollPosition-oldPosition, scrollPosition)); }
			updateThumb();
		}
		protected function updateThumb():void {
			var per:Number = _maxScrollPosition - _minScrollPosition + _pageSize;
			if (_track.height <= _thumbMinHeight - 1 || _maxScrollPosition <= _minScrollPosition || (per == 0 || isNaN(per))) {
				_thumb.height = _thumbMinHeight - 1;
				_thumb.visible = false;
			} else {
				_thumb.height = Math.max(_thumbMinHeight,_pageSize / per * _track.height);
				_thumb.y = _track.y+(_track.height-_thumb.height)*((_scrollPosition-_minScrollPosition)/(_maxScrollPosition-_minScrollPosition));
				_thumb.visible = enabled;
			}
		}
	}
}
