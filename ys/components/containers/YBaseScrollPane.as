package ys.components.containers {

	import flash.display.DisplayObject;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	
	import ys.components.controls.YScrollBar;
	import ys.components.controls.YScrollBarDirection;
	import ys.components.controls.YScrollPolicy;
	import ys.components.core.InvalidationType;
	import ys.components.core.YComponent;
	import ys.components.events.ScrollEvent;
	
	[Event(name="scroll", type="ys.components.events.ScrollEvent")]
	
	
	public class YBaseScrollPane extends YComponent {
		
		protected var _verticalScrollBar:YScrollBar;
		protected var _horizontalScrollBar:YScrollBar;
		protected var contentScrollRect:Rectangle;
		protected var _background:DisplayObject;
		protected var contentWidth:Number=0;
		protected var contentHeight:Number=0;
		protected var _horizontalScrollPolicy:String;
		protected var _verticalScrollPolicy:String;
		protected var contentPadding:Number=0;
		protected var availableWidth:Number = 0;
		protected var availableHeight:Number = 0;
		protected var vOffset:Number = 0;
		protected var _vScrollBar:Boolean;
		protected var _hScrollBar:Boolean;
		protected var _maxHorizontalScrollPosition:Number = 0;		
		protected var _horizontalPageScrollSize:Number = 0;	
		protected var _verticalPageScrollSize:Number = 0;
		protected var defaultLineScrollSize:Number = 4;

		protected var useFixedHorizontalScrolling:Boolean = false; // if false, uses contentWidth to determine hscroll, otherwise uses fixed _maxHorizontalScroll value
		
		protected var _useBitmpScrolling:Boolean = false;
		
		private static var defaultStyles:Object = {	 
											backgroundSkin : null,
											hScrollBarSkin : null,
											vScrollBarSkin : null,
											hScrollBarThumbHeight : 13,
											vScrollBarThumbHeight : 13,
											contentPadding:0,
											offsetX : 0,
											repeatDelay:500,repeatInterval:35
											};
		public static function getStyleDefinition():Object { 
			return mergeStyles(defaultStyles, YScrollBar.getStyleDefinition());
		}

		
		public function YBaseScrollPane() {
			super();
			_width = 0;_height = 0;
        }
        override public function set height(value:Number):void
		{
			super.height = value;
		}
		override public function set enabled(value:Boolean):void {
			if (enabled == value) { 
				return;
			}
			_verticalScrollBar.enabled = value;
			_horizontalScrollBar.enabled = value;
			super.enabled = value;
		}


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
		
		public function get horizontalLineScrollSize():Number {
			return _horizontalScrollBar.lineScrollSize;
		}
		
		public function set horizontalLineScrollSize(value:Number):void {
			_horizontalScrollBar.lineScrollSize = value;
		}
		

		public function get verticalLineScrollSize():Number {
			return _verticalScrollBar.lineScrollSize;
		}
		public function set verticalLineScrollSize(value:Number):void {
			_verticalScrollBar.lineScrollSize = value;
		}
		
		public function get horizontalScrollPosition():Number {
			if(!_horizontalScrollBar){
				return 0;
			}
			return _horizontalScrollBar.scrollPosition;
		}

		public function set horizontalScrollPosition(value:Number):void {
			// We must force a redraw to ensure that the size is up to date.
			drawNow();
			
			_horizontalScrollBar.scrollPosition = value;
			setHorizontalScrollPosition(_horizontalScrollBar.scrollPosition,false);
		}
		

		public function get verticalScrollPosition():Number {
			return _verticalScrollBar.scrollPosition;
		}

		public function set verticalScrollPosition(value:Number):void {
			// We must force a redraw to ensure that the size is up to date.
			drawNow();
			
			_verticalScrollBar.scrollPosition = value;
			setVerticalScrollPosition(_verticalScrollBar.scrollPosition,false);
		}
		

		public function get maxHorizontalScrollPosition():Number {
			drawNow();
			return Math.max(0,contentWidth-availableWidth);
		}

		public function get maxVerticalScrollPosition():Number {
			drawNow();
			return Math.max(0,contentHeight-availableHeight);
		}
		
		public function get useBitmapScrolling():Boolean {
			return _useBitmpScrolling;
		}
		
		public function set useBitmapScrolling(value:Boolean):void {
			_useBitmpScrolling = value;
			invalidate(InvalidationType.STATE);
		}
		
		public function get horizontalPageScrollSize():Number {
			if (isNaN(availableWidth)) { drawNow(); }
			return (_horizontalPageScrollSize == 0 && !isNaN(availableWidth)) ? availableWidth : _horizontalPageScrollSize;
		}
		public function set horizontalPageScrollSize(value:Number):void {
			_horizontalPageScrollSize = value;
			invalidate(InvalidationType.SIZE);	
		}
		
		public function get verticalPageScrollSize():Number {
			if (isNaN(availableHeight)) { drawNow(); }
			return (_verticalPageScrollSize == 0 && !isNaN(availableHeight)) ? availableHeight : _verticalPageScrollSize;
		}
		public function set verticalPageScrollSize(value:Number):void {
			_verticalPageScrollSize = value;
			invalidate(InvalidationType.SIZE);	
		}
		
		/**
		 * Gets a reference to the horizontal scroll bar.
		 */
		public function get horizontalScrollBar():YScrollBar {
			return _horizontalScrollBar;
		}
		/**
		 * Gets a reference to the vertical scroll bar.
		 */
		public function get verticalScrollBar():YScrollBar {
			return _verticalScrollBar;
		}		
		
		override protected function configUI():void {
			super.configUI();

			//contentScrollRect is not actually used by BaseScrollPane, only by subclasses.
			contentScrollRect = new Rectangle(0,0,85,85);
			addEventListener(MouseEvent.MOUSE_WHEEL,handleWheel,false,0,true);
		}
		
		
		public function set hScrollBar(value : YScrollBar):void
		{
			if(_horizontalScrollBar == value){
				return;
			}
			if(_horizontalScrollBar && _horizontalScrollBar.parent){
				_horizontalScrollBar.parent.removeChild(_horizontalScrollBar);
			}
			_horizontalScrollBar = value;
			if(_horizontalScrollBar){
				_horizontalScrollBar.setStyle("thumbMinHeight", getStyleValue("hScrollBarThumbHeight"));
				_horizontalScrollBar.direction = YScrollBarDirection.HORIZONTAL;
				_horizontalScrollBar.addEventListener(ScrollEvent.SCROLL,handleScroll,false,0,true);
				_horizontalScrollBar.visible = false;
				_horizontalScrollBar.lineScrollSize = defaultLineScrollSize;
				addChild(_horizontalScrollBar);
				_horizontalScrollBar.drawNow()
			}
		}
		public function set vScrollBar(value : YScrollBar):void
		{
			if(_verticalScrollBar == value){
				return;
			}
			if(_verticalScrollBar && _verticalScrollBar.parent){
				_verticalScrollBar.parent.removeChild(_verticalScrollBar);
			}
			_verticalScrollBar = value
			if(_verticalScrollBar){
				_verticalScrollBar.setStyle("thumbMinHeight", getStyleValue("vScrollBarThumbHeight"));
				_verticalScrollBar.addEventListener(ScrollEvent.SCROLL,handleScroll,false,0,true);
				_verticalScrollBar.visible = false;
				_verticalScrollBar.lineScrollSize = defaultLineScrollSize;
				addChild(_verticalScrollBar);
				_verticalScrollBar.drawNow();
			}
		}

		protected function setContentSize(width:Number,height:Number):void {
			if ((contentWidth == width || useFixedHorizontalScrolling) && contentHeight == height) { return; }
			
			contentWidth = width;
			contentHeight = height;
			invalidate(InvalidationType.SIZE);
		}

		protected function handleScroll(event:ScrollEvent):void {
			if (event.target == _verticalScrollBar) {
				setVerticalScrollPosition(event.position);
			} else {
				setHorizontalScrollPosition(event.position);
			}
		}

		protected function handleWheel(event:MouseEvent):void {
			if (!enabled || !_verticalScrollBar.visible || contentHeight <= availableHeight) {
				return;
			}
			_verticalScrollBar.scrollPosition -= event.delta * verticalLineScrollSize;
			setVerticalScrollPosition(_verticalScrollBar.scrollPosition);
			
			dispatchEvent(new ScrollEvent(YScrollBarDirection.VERTICAL, event.delta, horizontalScrollPosition));
		}

		// These are meant to be overriden by subclasses:
		protected function setHorizontalScrollPosition(scroll:Number,fireEvent:Boolean=false):void {}
		protected function setVerticalScrollPosition(scroll:Number,fireEvent:Boolean=false):void {}
		
		
		
		override protected function draw():void {
			if (isInvalid(InvalidationType.STYLES)) {
				drawBackground();
				setStyles();
				// drawLayout is expensive, so only do it if padding has changed:
				if (contentPadding != getStyleValue("contentPadding")) {
					invalidate(InvalidationType.SIZE,false);
				}
			}
			if (isInvalid(InvalidationType.SIZE, InvalidationType.STATE)) {
				drawLayout();
			}
			// Call drawNow() on nested components to get around problems with nested render events:
			updateChildren();
			super.draw();
		}

		protected function setStyles():void {
			hScrollBar = getDisplayObjectInstance(getStyleValue("hScrollBarSkin")) as YScrollBar;
			vScrollBar = getDisplayObjectInstance(getStyleValue("vScrollBarSkin")) as YScrollBar;
//			if(getStyleValue("hScrollBarSkin")){
//				copyStylesFromObject(_horizontalScrollBar,getStyleValue("hScrollBarSkin"));
//				_horizontalScrollBar.drawNow();
//			}
//			if(getStyleValue("vScrollBarSkin")){
//				copyStylesFromObject(_verticalScrollBar,getStyleValue("vScrollBarSkin"));
//				_verticalScrollBar.drawNow();
//			}
		}
		override public function setStyle(style:String, value:Object):void
		{
			super.setStyle(style, value);
		}

		protected function drawBackground():void {
			var bg:DisplayObject = _background;
			
			_background = getDisplayObjectInstance(getStyleValue("backgroundSkin"));
			if(_background){
				_background.width = width;
				_background.height = height;
				addChildAt(_background,0);
			}
			if (bg != null && bg != _background) { removeChild(bg); }
		}

		protected function drawLayout():void {
			calculateAvailableSize();
			calculateContentWidth();
			
			if(_background){
				_background.width = width;
				_background.height = height;
			}

			if(_verticalScrollBar){
				if (_vScrollBar) {
					_verticalScrollBar.visible = true;
					_verticalScrollBar.x = width - YScrollBar.WIDTH - contentPadding +getStyleValue("offsetX");
					_verticalScrollBar.y = contentPadding;
					_verticalScrollBar.height = availableHeight;
				} else {
					_verticalScrollBar.visible = false;
				}
				
				_verticalScrollBar.setScrollProperties(availableHeight, 0, contentHeight - availableHeight, verticalPageScrollSize);
				setVerticalScrollPosition(_verticalScrollBar.scrollPosition, false);
			}

			if(_horizontalScrollBar){
				if (_hScrollBar) {
					_horizontalScrollBar.visible = true;
					_horizontalScrollBar.x = contentPadding;
					_horizontalScrollBar.y = height - YScrollBar.WIDTH - contentPadding;
					_horizontalScrollBar.width = availableWidth;
				} else {
					_horizontalScrollBar.visible = false;
				}
				
				_horizontalScrollBar.setScrollProperties(availableWidth, 0, (useFixedHorizontalScrolling) ? _maxHorizontalScrollPosition : contentWidth - availableWidth, horizontalPageScrollSize);
				setHorizontalScrollPosition(_horizontalScrollBar.scrollPosition, false);
			}
		}
		
		protected function calculateAvailableSize():void {
			var scrollBarWidth:Number = YScrollBar.WIDTH;
			var padding:Number = contentPadding = Number(getStyleValue("contentPadding"));
			
			// figure out which scrollbars we need
			var availHeight:Number = height-2*padding - vOffset;
			_vScrollBar = (_verticalScrollPolicy == YScrollPolicy.ON) || (_verticalScrollPolicy == YScrollPolicy.AUTO && contentHeight > availHeight);
			var availWidth:Number = width - (_vScrollBar ? scrollBarWidth : 0) - 2 * padding;
			var maxHScroll:Number = (useFixedHorizontalScrolling) ? _maxHorizontalScrollPosition : contentWidth - availWidth;
			_hScrollBar = (_horizontalScrollPolicy == YScrollPolicy.ON) || (_horizontalScrollPolicy == YScrollPolicy.AUTO && maxHScroll > 0);
			if (_hScrollBar) { availHeight -= scrollBarWidth; }
			// catch the edge case of the horizontal scroll bar necessitating a vertical one:
			if (_hScrollBar && !_vScrollBar && _verticalScrollPolicy == YScrollPolicy.AUTO && contentHeight > availHeight) {
				_vScrollBar = true;
				availWidth -= scrollBarWidth;
			}
			availableHeight = availHeight + vOffset;
			availableWidth = availWidth;
		}
		
		protected function calculateContentWidth():void {
			// Meant to be overriden by subclasses
		}
		
		protected function updateChildren():void {
			if(_verticalScrollBar && _verticalScrollBar.visible){
				_verticalScrollBar.enabled = enabled;
				_verticalScrollBar.drawNow();
			}
			if(_horizontalScrollBar && _horizontalScrollBar.visible){
				_horizontalScrollBar.enabled = enabled
				_horizontalScrollBar.drawNow();
			}
		}
	}
}