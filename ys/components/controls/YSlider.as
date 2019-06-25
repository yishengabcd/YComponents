package ys.components.controls {
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.ui.Keyboard;
	
	import ys.components.controls.YBaseButton;
	import ys.components.controls.YScrollBar;
	import ys.components.controls.YSliderDirection;
	import ys.components.core.InvalidationType;
	import ys.components.core.YComponent;
	import ys.components.events.InteractionInputType;
	import ys.components.events.SliderEvent;
	import ys.components.events.SliderEventClickTarget;
	import ys.components.focus.IFocusManagerComponent;	

	[Event(name="thumbPress", type="ys.components.events.SliderEvent")]
	[Event(name="thumbRelease", type="ys.components.events.SliderEvent")]
	[Event(name="thumbDrag", type="ys.components.events.SliderEvent")]
	[Event(name="change", type="ys.components.events.SliderEvent")]
	
	public class YSlider extends YComponent implements IFocusManagerComponent {
		
		protected var _direction:String = YSliderDirection.HORIZONTAL;
		protected var _minimum:Number = 0;
		protected var _maximum:Number = 10;
		protected var _value:Number = 0;
		protected var _tickInterval:Number = 0;   
		protected var _snapInterval:Number = 0;
		protected var _liveDragging:Boolean = false;
		protected var tickContainer:Sprite;
		protected var _thumb:YBaseButton;
		protected var _track:YBaseButton;
		
		private var _insideFlag : Boolean;
		private var _widthReduce : Number = 0;
		private var thumbScrollOffset:Number;
		
		protected static var defaultStyles:Object = {
			thumbSkin:null,
			trackSkin:null,
			insideFlag:true,
			tickSkin: null
		}
		
        /**
         * @copy ys.components.core.UIComponent#getStyleDefinition()
         *
		 * @includeExample ../core/examples/UIComponent.getStyleDefinition.1.as -noswf
		 *
         */
		public static function getStyleDefinition():Object { return defaultStyles; }
		

		public function YSlider() { 
			super(); 
		}
		
		public function get direction():String { 
			return _direction;
		}		
		public function set direction(value:String):void {
			_direction = value;

			var vertical:Boolean = (_direction == YSliderDirection.VERTICAL);

			rotation = (vertical)?90:0;
		}
		
		public function get minimum():Number { return _minimum; }
		public function set minimum(value:Number):void {
			_minimum = value;
			this.value = Math.max(value, this.value);
			invalidate(InvalidationType.DATA);
		}
		
		public function get maximum():Number {
			return _maximum;
		}		
		public function set maximum(value:Number):void {
			_maximum = value;
			this.value = Math.min(value, this.value);
			invalidate(InvalidationType.DATA);
		}
		
		/**
		 * The spacing of the tick marks relative to the maximum value 
		 * of the component. The Slider component displays tick marks whenever 
         * you set the <code>tickInterval</code> property to a nonzero value.
         *
         * @default 0
         *
		 */		 
		public function get tickInterval():Number {
			return _tickInterval;
		}
		public function set tickInterval(value:Number):void { 
			_tickInterval = value;
			invalidate(InvalidationType.SIZE);
		}
		
		/**
		 * Gets or sets the increment by which the value is increased or decreased
		 * as the user moves the slider thumb. 
		 *
		 * <p>For example, this property is set to 2, the <code>minimum</code> value is 0, 
		 * and the <code>maximum</code> value is 10, the position of the thumb will always  
		 * be at 0, 2, 4, 6, 8, or 10. If this property is set to 0, the slider 
		 * moves continuously between the <code>minimum</code> and <code>maximum</code> values.</p>
         *
         * @default 0
         *
		 */		
		public function get snapInterval():Number {
			return _snapInterval;
		}
		
		public function set snapInterval(value:Number):void {
			_snapInterval = value;
		}
		
		/**
         * Gets or sets a Boolean value that indicates whether the <code>SliderEvent.CHANGE</code> 
		 * event is dispatched continuously as the user moves the slider thumb. If the 
		 * <code>liveDragging</code> property is <code>false</code>, the <code>SliderEvent.CHANGE</code> 
		 * event is dispatched when the user releases the slider thumb.
         *
         * @default false
         *
		 */		 
		public function set liveDragging(value:Boolean):void {
			_liveDragging = value;
		}		
		public function get liveDragging():Boolean {
			return _liveDragging;
		}
				
		override public function get enabled():Boolean {
			return super.enabled;
		}
		override public function set enabled(value:Boolean):void {
			if (enabled == value) { return; }
			super.enabled = value;
			_track.enabled = _thumb.enabled = value;
		}
		override public function setSize(w:Number, h:Number):void {			
			if (_direction == YSliderDirection.VERTICAL) {
				super.setSize(h, w);
			} else {
				super.setSize(w, h);
			}			
			invalidate(InvalidationType.SIZE);
		}
		
		/**
         * Gets or sets the current value of the Slider component. This value is 
		 * determined by the position of the slider thumb between the minimum and 
		 * maximum values.
         *
         * @default 0
         *
		 */
		 
		public function get value():Number {
			return _value;
		}
		
		public function set value(value:Number):void {
			if(_thumb){
				doSetValue(value);
			}else{
				_value = value;
			}
		}	
		
		protected function doSetValue(val:Number, interactionType:String=null, clickTarget:String=null, keyCode:int=undefined):void {
			var oldVal:Number = _value;
			if (_snapInterval != 0 && _snapInterval != 1) { 
				var pow:Number = Math.pow(10, getPrecision(snapInterval));
				var snap:Number = _snapInterval * pow;
				var rounded:Number = Math.round(val * pow);
				var snapped:Number = Math.round(rounded / snap) * snap;
				var val:Number = snapped / pow;
				_value = Math.max(minimum, Math.min(maximum,val));
			} else {
				_value = Math.max(minimum, Math.min(maximum, Math.round(val)));
			}
			// Only dispatch if value has changed
			// Dispatch when dragging			
			if (oldVal != _value && ((liveDragging && clickTarget != null) || (interactionType == InteractionInputType.KEYBOARD))) {
				dispatchEvent(new SliderEvent(SliderEvent.CHANGE, value, clickTarget, interactionType, keyCode));
			}
			
			positionThumb();
		}
		
		override protected function draw():void {
			if (isInvalid(InvalidationType.STYLES)) { 
				_insideFlag = getStyleValue("insideFlag");
				thumb = getDisplayObjectInstance(getStyleValue("thumbSkin")) as YBaseButton;
				track = getDisplayObjectInstance(getStyleValue("trackSkin")) as YBaseButton;
				invalidate(InvalidationType.SIZE, false);
			}
			
			
			if (isInvalid(InvalidationType.SIZE)) {
				_track.setSize(_width, _track.height);
				_track.drawNow();
				_thumb.drawNow();
			}
			if (tickInterval > 0) {
				drawTicks();
			} else {
				clearTicks();
			}
			
			positionThumb();
			super.draw();
		}
		
		protected function positionThumb():void {
			_thumb.x = ((_direction == YSliderDirection.VERTICAL) ? (maximum-value) : (value-minimum))/(maximum-minimum)*(_width - _widthReduce);
		}
		protected function drawTicks():void {
			clearTicks();
			tickContainer = new Sprite();
			var divisor:Number = (maximum<1)?tickInterval/100:tickInterval;
			var l:Number = (maximum-minimum)/divisor;
			var dist:Number = _width/l;
			for (var i:uint=0;i<=l;i++) {
				var tick:DisplayObject = getDisplayObjectInstance(getStyleValue("tickSkin"));
				tick.x = dist * i;
				tick.y = (_track.y - tick.height) - 2;
				tickContainer.addChild(tick);
			}
			addChild(tickContainer);
		}
		
		protected function clearTicks():void {
			if (!tickContainer || !tickContainer.parent) { return; }
			removeChild(tickContainer);
		}
		protected function calculateValue(pos:Number, interactionType:String, clickTarget:String, keyCode:int = undefined):void {
			var newValue:Number = (pos/(_width - _widthReduce))*(maximum-minimum);
			if (_direction == YSliderDirection.VERTICAL) {
				newValue = (maximum - newValue);
			} else {
				newValue = (minimum + newValue);
			}
			doSetValue(newValue, interactionType, clickTarget, keyCode);
		}
		
		protected function doDrag(event:MouseEvent):void {
//			var dist:Number = _width/snapInterval;
//			var thumbPos:Number = _track.mouseX;
			var thumbPos:Number = Math.max(0, Math.min(_track.width-_thumb.width, mouseX-_track.x-thumbScrollOffset));
			calculateValue(thumbPos, InteractionInputType.MOUSE, SliderEventClickTarget.THUMB);
			dispatchEvent(new SliderEvent(SliderEvent.THUMB_DRAG, value, SliderEventClickTarget.THUMB, InteractionInputType.MOUSE));
		}
		
		protected function thumbPressHandler(event:MouseEvent):void {
			thumbScrollOffset = mouseX-_thumb.x;
			stage.addEventListener(MouseEvent.MOUSE_MOVE,doDrag,false,0,true);
			stage.addEventListener(MouseEvent.MOUSE_UP,thumbReleaseHandler,false,0,true);
			dispatchEvent(new SliderEvent(SliderEvent.THUMB_PRESS, value, SliderEventClickTarget.THUMB, InteractionInputType.MOUSE));
		}
		
		protected function thumbReleaseHandler(event:MouseEvent):void {
			stage.removeEventListener(MouseEvent.MOUSE_MOVE,doDrag);
			stage.removeEventListener(MouseEvent.MOUSE_UP,thumbReleaseHandler);
			dispatchEvent(new SliderEvent(SliderEvent.THUMB_RELEASE, value, SliderEventClickTarget.THUMB, InteractionInputType.MOUSE));
			dispatchEvent(new SliderEvent(SliderEvent.CHANGE, value, SliderEventClickTarget.THUMB, InteractionInputType.MOUSE));
		}
		
		protected function onTrackClick(event:MouseEvent):void {			
			calculateValue(_track.mouseX, InteractionInputType.MOUSE, SliderEventClickTarget.TRACK);
			if (!liveDragging) {
				dispatchEvent(new SliderEvent(SliderEvent.CHANGE, value, SliderEventClickTarget.TRACK, InteractionInputType.MOUSE));
			}
		}
		
		override protected function keyDownHandler(event:KeyboardEvent):void {
			if (!enabled) { return; }
			var incrementBy:Number = (snapInterval > 0) ? snapInterval : 1;
			var newValue:Number;
			var isHorizontal:Boolean = (direction == YSliderDirection.HORIZONTAL);

			if ((event.keyCode == Keyboard.DOWN && !isHorizontal) || (event.keyCode == Keyboard.LEFT && isHorizontal)) {
				newValue = value - incrementBy;
			} else if ((event.keyCode == Keyboard.UP && !isHorizontal) || (event.keyCode == Keyboard.RIGHT && isHorizontal)) {
				newValue = value + incrementBy;
			} else if ((event.keyCode == Keyboard.PAGE_DOWN && !isHorizontal) || (event.keyCode == Keyboard.HOME && isHorizontal)) {
				newValue = minimum;
			} else if ((event.keyCode == Keyboard.PAGE_UP && !isHorizontal) || (event.keyCode == Keyboard.END && isHorizontal)) {
				newValue = maximum;
			}
			
			if (!isNaN(newValue)) {
				event.stopPropagation();
				doSetValue(newValue, InteractionInputType.KEYBOARD, null, event.keyCode);
			}
		}
		
		public function set thumb(value : YBaseButton):void
		{
			_thumb = value;
			_thumb.drawNow();
			if(_insideFlag){
				_widthReduce = _thumb.width;
			}
//			_thumb.setSize(13, 13);
			_thumb.autoRepeat = false;
			addChild(_thumb);
			
			_thumb.addEventListener(MouseEvent.MOUSE_DOWN,thumbPressHandler,false,0,true);
		}
		public function set track(value : YBaseButton):void
		{
			_track = value;
			_track.move(0, 0);
			_track.setSize(80, 4);
			_track.autoRepeat = false;
			_track.useHandCursor = false;
			_track.addEventListener(MouseEvent.CLICK,onTrackClick,false,0,true);
			addChildAt(_track,0);
		}

		protected function getPrecision(num:Number):Number {
			var s:String = num.toString();
			if (s.indexOf(".") == -1) { return 0; }
			return s.split(".").pop().length;
		}
	}
}
