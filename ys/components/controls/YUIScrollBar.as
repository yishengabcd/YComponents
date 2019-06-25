package ys.components.controls {

	import Error;
	import ys.components.controls.YScrollBar;
	import ys.components.controls.YScrollBarDirection;
	import ys.components.core.InvalidationType;
	import ys.components.core.YComponent;
	import flash.display.DisplayObject;
	import ys.components.events.ScrollEvent;
	import flash.events.Event;
	import flash.events.TextEvent;
		

	
	public class YUIScrollBar extends YScrollBar {
		
		protected var _scrollTarget:DisplayObject;

		protected var inEdit:Boolean = false;	

		protected var inScroll:Boolean = false;

		protected var _targetScrollProperty:String;

		protected var _targetMaxScrollProperty:String;
		
		private static var defaultStyles:Object = {};
		
		public static function getStyleDefinition():Object { 
			return YComponent.mergeStyles(defaultStyles, YScrollBar.getStyleDefinition()); 
		}
		
		public function YUIScrollBar() {
			super();
		}
		
		override public function set minScrollPosition(minScrollPosition:Number):void {
			super.minScrollPosition = (minScrollPosition<0)?0:minScrollPosition;
		}
		
		override public function set maxScrollPosition(maxScrollPosition:Number):void {
			var maxScrollPos:Number = maxScrollPosition;
			if (_scrollTarget != null) { 
				maxScrollPos = Math.min(maxScrollPos, _scrollTarget[_targetMaxScrollProperty]);
			}
			super.maxScrollPosition = maxScrollPos;
		}
		
		/**
		 * Registers a TextField instance or a TLFTextField instance with the ScrollBar component instance.
		 */
		public function get scrollTarget():DisplayObject {
			return _scrollTarget;
		}
		public function set scrollTarget(target:DisplayObject):void {
			if (_scrollTarget != null) {
				_scrollTarget.removeEventListener(Event.CHANGE,handleTargetChange,false);
				_scrollTarget.removeEventListener(TextEvent.TEXT_INPUT,handleTargetChange,false);
				_scrollTarget.removeEventListener(Event.SCROLL,handleTargetScroll,false);
			}
			_scrollTarget = target;

			// deal with switch to or away from bidi or vertical target
			var blockProg:String = null;
			var textDir:String = null;
			if (_scrollTarget != null) {
				try {
					if (_scrollTarget.hasOwnProperty("blockProgression")) blockProg = _scrollTarget["blockProgression"];
					if (_scrollTarget.hasOwnProperty("direction")) textDir = _scrollTarget["direction"];
				} catch (e:Error) {
					blockProg = null;
					textDir = null;
				}
			}
			var scrollHoriz:Boolean = (this.direction == YScrollBarDirection.HORIZONTAL);
			var rot:Number = Math.abs(this.rotation);
			if (scrollHoriz && (blockProg == "rl" || textDir == "rtl")) {
				// flip it around and shift it for right to left text
				if (getScaleY() > 0 && rotation == 90) x += width;
				setScaleY(-1);
			} else if (!scrollHoriz && blockProg == "rl" && textDir == "rtl") {
				// flip it around it for right to left vertical text
				if (getScaleY() > 0 && rotation != 90) y += height;
				setScaleY(-1);
			} else {
				if (getScaleY() < 0) {
					if (scrollHoriz) {
						if (rotation == 90) x -= width;
					} else {
						if (rotation != 90) y -= height;
					}
				}
				setScaleY(1);
			}
			// determine which APIs we call, horizontal or vertical
			setTargetScrollProperties(scrollHoriz, blockProg);

			// add event listeners if necessary
			if (_scrollTarget != null) {
				_scrollTarget.addEventListener(Event.CHANGE,handleTargetChange,false,0,true);
				_scrollTarget.addEventListener(TextEvent.TEXT_INPUT,handleTargetChange,false,0,true);
				_scrollTarget.addEventListener(Event.SCROLL,handleTargetScroll,false,0,true);
			}	
			invalidate(InvalidationType.DATA);
		}
		
		/**
		 * @private (internal)
         * @internal For specifying in inspectable, and setting dropTarget
		 */		
		public function get scrollTargetName():String {
			return _scrollTarget.name;	
		}
		public function set scrollTargetName(target:String):void {
			try {
				scrollTarget = parent.getChildByName(target);
			} catch (error:Error) {
				throw new Error("ScrollTarget not found, or is not a valid target");
			}
		}
		
		/**
		 * @copy ys.components.controls.ScrollBar#direction
         *
         * @default ScrollBarDirection.VERTICAL
		 */		
		override public function get direction():String { return super.direction; }


		override public function set direction(dir:String):void {
			// if shifted and flipped for right to left and/or top to bottom, fix that first
			var cacheScrollTarget:DisplayObject;
			if (_scrollTarget != null) {
				cacheScrollTarget = _scrollTarget;
				scrollTarget = null;
			}
			super.direction = dir;
			if (cacheScrollTarget != null) {
				scrollTarget = cacheScrollTarget;
			} else {
				updateScrollTargetProperties();
			}
		}
		
		/**
		 * Forces the scroll bar to update its scroll properties immediately.  
         * This is necessary after text in the specified <code>scrollTarget</code> text field
		 * is added using ActionScript, and the scroll bar needs to be refreshed.
		 */
		public function update():void {
			inEdit = true;
			updateScrollTargetProperties();
			inEdit = false;
		}
		
		
		override protected function draw():void {
			super.draw();
			if (isInvalid(InvalidationType.DATA)) {
				updateScrollTargetProperties();
			}
			validate()
		}
		
		protected function updateScrollTargetProperties():void {
			if (_scrollTarget == null) {
				setScrollProperties(pageSize,minScrollPosition,maxScrollPosition);
				scrollPosition = 0;
			} else {
				var blockProg:String = null;
				try {
					if (_scrollTarget.hasOwnProperty("blockProgression")) blockProg = _scrollTarget["blockProgression"];
				} catch (e1:Error) {
				}
				setTargetScrollProperties(this.direction == YScrollBarDirection.HORIZONTAL, blockProg);

				var pageSize:Number;
				var minScroll:Number;
				if (_targetScrollProperty == "scrollH") {
					minScroll = 0;
					try {
						if (_scrollTarget.hasOwnProperty("controller") && _scrollTarget["controller"].hasOwnProperty("compositionWidth")) {
							pageSize = _scrollTarget["controller"]["compositionWidth"];
						} else {
							pageSize = _scrollTarget.width;
						}
					} catch (e2:Error) {
						pageSize = _scrollTarget.width;
					}
				} else {
					try {
						// hasOwnProperty will fail because it is in a namespace, so assume blockProg != null
						// means we are TLF and it will be there, and if not just catch error
						if (blockProg != null) {
							namespace local_tlf_internal = "http://ns.adobe.com/textLayout/internal/2008";
							use namespace local_tlf_internal;
							var minScrollVValue:* = _scrollTarget["minScrollV"];
							if (minScrollVValue is int) {
								minScroll = minScrollVValue;
							} else {
								minScroll = 1;
							}
						} else {
							minScroll = 1;
						}
					} catch (e3:Error) {
						minScroll = 1;
					}
					pageSize = 10;					
				}
				setScrollProperties(pageSize, minScroll, scrollTarget[_targetMaxScrollProperty]);
				scrollPosition = _scrollTarget[_targetScrollProperty];
			}
		}
		
		override public function setScrollProperties(pageSize:Number,minScrollPosition:Number,maxScrollPosition:Number,pageScrollSize:Number=0):void {
			var maxScrollPos:Number = maxScrollPosition;
			var minScrollPos:Number  = (minScrollPosition<0)?0:minScrollPosition;
			
			if (_scrollTarget != null) {
				maxScrollPos = Math.min(maxScrollPosition, _scrollTarget[_targetMaxScrollProperty]);
			}
			super.setScrollProperties(pageSize,minScrollPos,maxScrollPos,pageScrollSize);
		}
		
		override public function setScrollPosition(scrollPosition:Number, fireEvent:Boolean=true):void {
			super.setScrollPosition(scrollPosition, fireEvent);
			if (!_scrollTarget) { inScroll = false; return; }
			updateTargetScroll();
		}

		// event default is null, so when user calls setScrollPosition, the text is updated, and we don't pass an event
		protected function updateTargetScroll(event:ScrollEvent=null):void {
			if (inEdit) { return; } // Update came from the user input. Ignore.
			_scrollTarget[_targetScrollProperty] = scrollPosition;
		}
		
		protected function handleTargetChange(event:Event):void {
			inEdit = true;
			setScrollPosition(_scrollTarget[_targetScrollProperty], true);
			updateScrollTargetProperties();
			inEdit = false;
		}
		
		protected function handleTargetScroll(event:Event):void {
			if (inDrag) { return; }
			if (!enabled) { return; }		
			inEdit = true;
			updateScrollTargetProperties(); // This needs to be done first! 
			
			scrollPosition = _scrollTarget[_targetScrollProperty];
			inEdit = false;
		}
		
		private function setTargetScrollProperties(scrollHoriz:Boolean, blockProg:String):void
		{
			if (blockProg == "rl") {
				if (scrollHoriz) {
					_targetScrollProperty = "scrollV";
					_targetMaxScrollProperty = "maxScrollV";
				} else {
					_targetScrollProperty = "scrollH";
					_targetMaxScrollProperty = "maxScrollH";
				}
			} else {
				if (scrollHoriz) {
					_targetScrollProperty = "scrollH";
					_targetMaxScrollProperty = "maxScrollH";
				} else {
					_targetScrollProperty = "scrollV";
					_targetMaxScrollProperty = "maxScrollV";
				}
			}
		}

	}
}
