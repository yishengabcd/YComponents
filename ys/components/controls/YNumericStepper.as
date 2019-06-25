package ys.components.controls {
	
	import ys.components.controls.YBaseButton;
	import ys.components.controls.YTextInput; //Only for ASDocs
	import ys.components.core.InvalidationType;
	import ys.components.core.YComponent;
	import ys.components.events.ComponentEvent;
	import ys.components.focus.IFocusManagerComponent;
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.ui.Keyboard;

	[Event(name="change", type="flash.events.Event")]

	
	public class YNumericStepper extends YComponent implements IFocusManagerComponent {

		protected var inputField:YTextInput;
		protected var upArrow:YBaseButton;
		protected var downArrow:YBaseButton;
		protected var _maximum:Number = 10;
		protected var _minimum:Number = 0;
		protected var _value:Number = 1;
		protected var _stepSize:Number = 1;
		protected var _precision:Number;

		
		public function YNumericStepper() {
			super();
//			setStyles();
			stepSize = _stepSize;
		}

		private static var defaultStyles:Object = {
											inputFieldSkin : null,
											upArrowSkin : null,
											downArrowSkin : null,
											repeatDelay:500,
											repeatInterval:35, 
											embedFonts:false
											};
		
		public static function getStyleDefinition():Object { return defaultStyles; }

		override public function get enabled():Boolean {
			return super.enabled;
		}

		override public function set enabled(value:Boolean):void {
			if (value == enabled) { return; }
			super.enabled = value;
			upArrow.enabled = downArrow.enabled = inputField.enabled = value;
		}
		
		public function get maximum():Number {
			return _maximum;
		}
		public function set maximum(value:Number):void {
			_maximum = value;
			if (_value > _maximum) { 
				setValue(_maximum, false);
			}
		}
		
		public function get minimum():Number {
			return _minimum;
		}
		public function set minimum(value:Number):void {
			_minimum = value;
			if (_value < _minimum) {
				setValue(_minimum, false);
			}
		}

		/**
         * Gets the next value in the sequence of values.
		 */
		public function get nextValue():Number {
			var val:Number = _value + _stepSize;
			return (inRange(val)) ? val : _value;
		}

		/**
         * Gets the previous value in the sequence of values.
		 */
		public function get previousValue():Number {
			var val:Number = _value - _stepSize;
			return (inRange(val)) ? val : _value;
		}
		
		/**
         * Gets or sets a nonzero number that describes the unit of change between 
		 * values. The <code>value</code> property is a multiple of this number 
		 * less the minimum. The NumericStepper component rounds the resulting value to the 
		 * nearest step size.
         *
         * @default 1
		 */		
		public function get stepSize():Number {
			return _stepSize;
		}
		public function set stepSize(value:Number):void {
			_stepSize = value;
			_precision = getPrecision();
			setValue(_value);
		}
		
		/**
		 * Gets or sets the current value of the NumericStepper component.
         *
         * @default 1
         *
		 */		
		public function get value():Number {
			return _value;
		}
		public function set value(value:Number):void {
			setValue(value, false);
		}
		
		/**
		 * Gets a reference to the TextInput component that the NumericStepper
		 * component contains. Use this property to access and manipulate the 
		 * underlying TextInput component. For example, you can use this
		 * property to change the current selection in the text box or to
		 * restrict the characters that the text box accepts.
		 */
		public function get textField():YTextInput {
			return inputField;	
		}
		
		/**
         * @copy ys.components.controls.TextArea#imeMode
		 */
		 public function get imeMode():String {
			return inputField.imeMode;
		}		
		public function set imeMode(value:String):void {
			inputField.imeMode = value;
		}
		override protected function configUI():void {
			super.configUI();

			upArrow = new YBaseButton();
//			copyStylesToChild(upArrow, UP_ARROW_STYLES);
			upArrow.autoRepeat = true;
			upArrow.setSize(21, 12);
			upArrow.focusEnabled = false;
			addChild(upArrow);

			downArrow = new YBaseButton();
//			copyStylesToChild(downArrow, DOWN_ARROW_STYLES);
			downArrow.autoRepeat = true;
			downArrow.setSize(21, 12);
			downArrow.focusEnabled = false;
			addChild(downArrow);

			inputField = new YTextInput();
//			copyStylesToChild(inputField, TEXT_INPUT_STYLES);
			inputField.restrict = "0-9\\-\\.\\,";
			inputField.text = _value.toString();
			inputField.setSize(21, 24);
			inputField.focusTarget = this as IFocusManagerComponent;
			inputField.focusEnabled = false;
			inputField.addEventListener(FocusEvent.FOCUS_IN, passEvent);
			inputField.addEventListener(FocusEvent.FOCUS_OUT, passEvent);
			addChild(inputField);

			inputField.addEventListener(Event.CHANGE, onTextChange, false, 0, true);
			upArrow.addEventListener(ComponentEvent.BUTTON_DOWN, stepperPressHandler, false, 0, true);
			downArrow.addEventListener(ComponentEvent.BUTTON_DOWN, stepperPressHandler, false, 0, true);
		}

		protected function setValue(value:Number, fireEvent:Boolean=true):void {
			if (value == _value) {
				return;
			}
			var oldVal:Number = _value;
			_value = getValidValue(value);
			inputField.text = _value.toString();
			
			if (fireEvent) {
				dispatchEvent(new Event(Event.CHANGE, true));
			}
		}

		override protected function keyDownHandler(event:KeyboardEvent):void {
			if (!enabled) { return; }
			event.stopImmediatePropagation();

			var val:Number = Number(inputField.text);
			switch (event.keyCode) {
				case Keyboard.END:
					setValue(maximum);
					break;
				case Keyboard.HOME:
					setValue(minimum);
					break;
				case Keyboard.UP:
					setValue(nextValue);
					break;
				case Keyboard.DOWN:
					setValue(previousValue);
					break;
				case Keyboard.ENTER:
					setValue(val);
					break;
			}
		}
		protected function stepperPressHandler(event:ComponentEvent):void {
			setValue(Number(inputField.text), false);
			
			switch (event.currentTarget) {
				case upArrow:
					setValue(nextValue);
					break;
				case downArrow:
					setValue(previousValue);
			}
			inputField.setFocus();
			inputField.textField.setSelection(0,0);
		}

		/**
         * @copy ys.components.core.UIComponent#drawFocus()
		 */
		override public function drawFocus(event:Boolean):void {
			super.drawFocus(event);
		}
		
		override protected function focusOutHandler(event:FocusEvent):void {
			if (event.eventPhase == 3) {
				setValue(Number(inputField.text));
			}
			super.focusOutHandler(event);
		}
		override protected function draw():void {
			if (isInvalid(InvalidationType.STYLES)) {
//				setStyles();
				invalidate(InvalidationType.SIZE, false);
			}
//			if (isInvalid(InvalidationType.STATE)) {
//				invalidate(InvalidationType.SIZE, false);
//			}
			if (isInvalid(InvalidationType.SIZE)) {
				drawLayout();
			}
			if (isFocused && focusManager.showFocusIndicator) { drawFocus(true); }
			validate();
		}

		protected function drawLayout():void {
			var w:Number = width - upArrow.width;
			var h:Number = height / 2;
			inputField.setSize(w, height);
			upArrow.height = h;
			downArrow.height = Math.floor(h);
			downArrow.move(w, h);
			upArrow.move(w, 0);
			
			downArrow.drawNow();
			upArrow.drawNow();
			inputField.drawNow();
		}

		protected function onTextChange(event:Event):void {
			event.stopImmediatePropagation();
		}

		protected function passEvent(event:Event):void {
			dispatchEvent(event);
		}

		/**
         * Sets focus to the component instance.
		 */
		override public function setFocus():void {
			if(stage) { stage.focus = inputField.textField; }
		}

		override protected function isOurFocus(target:DisplayObject):Boolean {
			return target == inputField || super.isOurFocus(target);
		}

		protected function inRange(num:Number):Boolean {
			return (num >= _minimum && num <= _maximum);
		}

		protected function inStep(num:Number):Boolean {
			return (num - _minimum) % _stepSize == 0;
		}
		protected function getValidValue(num:Number):Number {
			if (isNaN(num)) { return _value; }
			var closest:Number = Number((_stepSize * Math.round(num / _stepSize)).toFixed(_precision));
			if (closest > maximum) { 
				return maximum; 
			} else if (closest < minimum) { 
				return minimum;
			} else { 
				return closest
			}
		}

		protected function getPrecision():Number {
			var s:String = _stepSize.toString();
			if (s.indexOf('.') == -1) { return 0; }
			return s.split('.').pop().length;
		}

	}
}