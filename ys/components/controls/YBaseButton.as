package ys.components.controls {
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Rectangle;
	import flash.utils.Timer;
	
	import org.bytearray.display.ScaleBitmap;
	
	import ys.components.controls.member.IStateStrategy;
	import ys.components.core.InvalidationType;
	import ys.components.core.YComponent;
	import ys.components.events.ComponentEvent;
	import ys.utils.FilterUtils;
	import ys.utils.PNGUtils;

	
	[Event(name="buttonDown", type="ys.components.events.ComponentEvent")]
	[Event(name="change", type="flash.events.Event")]
	
	
	public class YBaseButton extends YComponent
	{
		/**
		 * 按钮背景.按钮的外观主要由它决定.
		 */		
		protected var background:DisplayObject;
		protected var mouseState:String;
		protected var _selected:Boolean = false;
		protected var _autoRepeat:Boolean = false;
		protected var pressTimer:Timer;
		/**
		 * 点击区域.
		 * 只有transparent设置为true时,才会使用此对象.
		 */		
		protected var _hitArea : Sprite;
		/**
		 * 是否忽视透明像素.为true时,按钮透明的地方不可交互.
		 */		
		private var _transparent : Boolean;
		
		private var _mouseStateLocked:Boolean = false;
		private var unlockedMouseState:String;		
		private var _backgroundStyle : Object
		
		/**
		 * 位移.为true时,当鼠标按下时,按钮会向下及向右移动1像素. 
		 */		
		public var displacement : Boolean;
		private var _offsetCount : int;	
		
		/**
		 * 按钮的状态策略.主要控制按钮在up、down、over状态下的显示。
		 */		
		protected var _stateStrategy : IStateStrategy

		private static var defaultStyles:Object = {background : null,
													 stateStrategy : null,
													 unenabledFilters : null,
													 scale9Grid:null,
												  	 repeatDelay:500,
													 repeatInterval:35};
        
		public static function getStyleDefinition():Object { return defaultStyles; }

		
		public function YBaseButton() {
			super();

			buttonMode = true;
			mouseChildren = false;
//			useHandCursor = false;
			
			setupMouseEvents();
			setMouseState("up");

			pressTimer = new Timer(1,0);
			pressTimer.addEventListener(TimerEvent.TIMER,buttonDown,false,0,true);
		}

		override public function get enabled():Boolean {return super.enabled;}
		override public function set enabled(value:Boolean):void {
			super.enabled = value;
			mouseEnabled = value;
			updatePosition();
		}
		
		private function updatePosition():void
		{
			x += -_offsetCount;
			y += -_offsetCount;
			
			_offsetCount = 0;
		}


		public function get selected():Boolean {return _selected;}
		public function set selected(value:Boolean):void {
			if (_selected == value) { return; }
			_selected = value;
			invalidate(InvalidationType.STATE);
		}

		public function get autoRepeat():Boolean {return _autoRepeat;}		
		public function set autoRepeat(value:Boolean):void {
			_autoRepeat = value;
		}		
		
		public function set transparent(value : Boolean):void
		{
			if(_transparent == value){
				return;
			}
			_transparent = value;
		}
		
		public function set mouseStateLocked(value:Boolean):void {
			_mouseStateLocked = value;
			if (value == false) { setMouseState(unlockedMouseState); }
			else { unlockedMouseState = mouseState; }
		}

		public function setMouseState(state:String):void {
			if (_mouseStateLocked) { unlockedMouseState = state; return; }
			if (mouseState == state) { return; }
			mouseState = state;
			invalidate(InvalidationType.STATE);
		}
		
		protected function setupMouseEvents():void {
			addEventListener(MouseEvent.ROLL_OVER,mouseEventHandler,false,0,true);
			addEventListener(MouseEvent.MOUSE_DOWN,mouseEventHandler,false,0,true);
			addEventListener(MouseEvent.MOUSE_UP,mouseEventHandler,false,0,true);
			addEventListener(MouseEvent.ROLL_OUT,mouseEventHandler,false,0,true);
		}

		protected function mouseEventHandler(event:MouseEvent):void {
			if (event.type == MouseEvent.MOUSE_DOWN) {
				setMouseState("down");
				if (displacement && _offsetCount<1)
				{
					x += 1;
					y += 1;
					
					_offsetCount++;
				}
				startPress();
			} else if (event.type == MouseEvent.ROLL_OVER || event.type == MouseEvent.MOUSE_UP) {
				setMouseState("over");
				
				endPress();
			} else if (event.type == MouseEvent.ROLL_OUT) {
				setMouseState("up");
				
				endPress();
			}
			if(event.type == MouseEvent.MOUSE_UP){
				if(displacement && _offsetCount > -1){
					x -= 1;
					y -= 1;					
					_offsetCount--;
				}
			}
		}

		protected function startPress():void {
			if (_autoRepeat) {
				pressTimer.delay = Number(getStyleValue("repeatDelay"));
				pressTimer.start();
			}
			dispatchEvent(new ComponentEvent(ComponentEvent.BUTTON_DOWN, true));
		}

		protected function buttonDown(event:TimerEvent):void {
			if (!_autoRepeat) { endPress(); return; }
			if (pressTimer.currentCount == 1) { pressTimer.delay = Number(getStyleValue("repeatInterval")); }
			dispatchEvent(new ComponentEvent(ComponentEvent.BUTTON_DOWN, true));
		}

		protected function endPress():void {
			pressTimer.reset();
		}
		
		override protected function draw():void {
			if (isInvalid(InvalidationType.STYLES)) {
				drawView();				
			}
			if(isInvalid(InvalidationType.STATE)){
				drawState();
			}
			if (isInvalid(InvalidationType.SIZE)) {
				drawLayout();
			}
			if(background is YComponent){
				YComponent(background).drawNow();
			}
			super.draw();
		}
		
		protected function drawView():void
		{
			drawBackground();
		}

		protected function drawBackground():void {
			var bgStyle : Object = getStyleValue("background")
			if(!bgStyle || bgStyle == _backgroundStyle){
				return;
			}
				
			var bg : DisplayObject = background
			if (bg != null) { removeChild(bg); }
			_backgroundStyle = getStyleValue("background");
			background = getDisplayObjectInstance(_backgroundStyle);
			addChildAt(background, 0);
			if(background is YComponent){
				YComponent(background).drawNow();
			}
			
			addStateStratege(background);
			
			
			if(!bg){
				if(isNaN(width)){
					width = background.width;
				}
				if(isNaN(height)){
					height = background.height;
				}
			}
			
			var scale9Grid : Rectangle = getStyleValue("scale9Grid") as Rectangle
			if(scale9Grid){
				background.scale9Grid = scale9Grid;
			}
			
			invalidate(InvalidationType.SIZE,false); // invalidates size without calling draw next frame.
		}
		
		protected function addStateStratege(target : Object):void
		{
			if(!_stateStrategy){
				var stateStrategyStyle : Object = getStyleValue("stateStrategy")
				if(stateStrategyStyle is Class){
					_stateStrategy = new stateStrategyStyle() as IStateStrategy
				}else if(stateStrategyStyle is IStateStrategy){
					_stateStrategy = stateStrategyStyle as IStateStrategy;
				}
			}
			
			if(_stateStrategy){
				_stateStrategy.setTarget(target);
			}
		}
		
		protected function drawState():void
		{
			if(enabled){
				this.filters = null
				if(_stateStrategy){
					switch(mouseState){
						case YButtonStateType.UP:
							_stateStrategy.mouseUp()
							break;
						case YButtonStateType.OVER:
							_stateStrategy.mouseOver();
							break;
						case YButtonStateType.DOWN:
							_stateStrategy.mouseDown();
							break;
					}
				}
			}else{
				this.filters = getStyleValue("unenabledFilters") as Array;
				if(_stateStrategy){
					_stateStrategy.mouseUp();
				}
			}
			
		}
		protected function drawLayout():void {
			if(background){
				background.width = width;
				background.height = height;
				
				drawHitArea();
			}
			
		}
		
		protected function drawHitArea():void
		{
			if(_hitArea && _hitArea.parent){
				removeChild(_hitArea);
			}
			if(_transparent){
				_hitArea = PNGUtils.drawHitArea(getBitmap());
				hitArea = _hitArea;
				_hitArea.alpha = 0;
				adaptHitArea();
				addChild(_hitArea);
			}else{
				if(_hitArea && _hitArea.parent){
					removeChild(_hitArea);
				}
			}
		}
		protected function adaptHitArea():void
		{
			_hitArea.x = background.x;
			_hitArea.y = background.y;
		}
		protected function getBitmap():Bitmap
		{
			if (background is Bitmap){
				return background as Bitmap;
			}else{
				var bmd:BitmapData = new BitmapData(background.width, background.height);
				bmd.draw(background);
				return new Bitmap(bmd);
			}
			return null;
		}
	}
}