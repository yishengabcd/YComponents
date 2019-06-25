package ys.components.core {

	import flash.display.DisplayObject;
	import flash.display.InteractiveObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.geom.Point;
	import flash.system.IME;
	import flash.system.IMEConversionMode;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.utils.Dictionary;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	import flash.utils.getQualifiedSuperclassName;
	
	import org.bytearray.display.ScaleBitmap;
	
	import ys.components.events.ComponentEvent;
	import ys.components.focus.FocusManager;
	import ys.components.focus.IFocusManager;
	import ys.components.focus.IFocusManagerComponent;
	import ys.components.skin.SkinFactory;
	import ys.components.style.StyleManager;
	import ys.components.tip.ITip;
	import ys.components.tip.ITipTarget;
	
	[Event(name="move", type="ys.components.events.ComponentEvent")]
	[Event(name="resize", type="ys.components.events.ComponentEvent")]
	[Event(name="show", type="ys.components.events.ComponentEvent")]
    [Event(name="hide", type="ys.components.events.ComponentEvent")]

	/**
	 * UI组件类基类.所有UI组件都直接或间接继承此类.
	 * UI组件最主要的方法是setStyle()方法。
	 * 通过setStyle方法可以设置组件的样式及某些属性值.
	 * 可设置的样式或属性可查看各个类的类方法getStyleDefinition()返回的对象的键.
	 */	
	public class YComponent extends Sprite implements ITipTarget
	{
		protected var instanceStyles:Object;
		protected var sharedStyles:Object; // Holds a reference to the class-level styles.
		
		protected var callLaterMethods:Dictionary;
		protected var invalidHash:Object;		
		
		protected var _enabled:Boolean=true;		
		
		protected var _width:Number// = 0;
		protected var _height:Number// = 0;
		protected var _x:Number;
		protected var _y:Number;
		
		protected var _imeMode:String = null;
		protected var _oldIMEMode:String = null;		
		protected var errorCaught:Boolean = false;	
		
		protected var _tipFactory : Function;
		protected var _tipPosOffset : Point = new Point();
		
		/**
		 * Used when components are nested, and we want the parent component to
		 * handle draw focus, not the child.
		 *
		 * @default null
		 *
		 */
		public var focusTarget:IFocusManagerComponent;
		
		protected var isFocused:Boolean =  false
		private var _focusEnabled:Boolean = true;
		private var _mouseFocusEnabled:Boolean = true;
		
		
		private static var defaultStyles:Object = {
			focusRectSkin:"focusRectSkin",
			focusRectPadding:2,
			textFormat: new TextFormat("_sans", 11, 0x000000, false, false, false, "", "", TextFormatAlign.LEFT, 0, 0, 0, 0),
			disabledTextFormat: new TextFormat("_sans", 11, 0x999999, false, false, false, "", "", TextFormatAlign.LEFT, 0, 0, 0, 0),
			defaultTextFormat: new TextFormat("_sans", 11, 0x000000, false, false, false, "", "", TextFormatAlign.LEFT, 0, 0, 0, 0),
			defaultDisabledTextFormat: new TextFormat("_sans", 11, 0x999999, false, false, false, "", "", TextFormatAlign.LEFT, 0, 0, 0, 0)
		}


		private static var focusManagers:Dictionary = new Dictionary(true);
		private static var focusManagerUsers:Dictionary = new Dictionary(true);

		public static function getStyleDefinition():Object {			
			return defaultStyles;
		}

        /**
         * Merges the styles from multiple classes into one object. 
         * If a style is defined in multiple objects, the first occurrence
         * that is found is used. 
         *
         * @param list A comma-delimited list of objects that contain the default styles to be merged.
         *
         * @return A default style object that contains the merged styles.
         *
         */
		public static function mergeStyles(...list:Array):Object {
			var styles:Object = {};
			var l:uint = list.length;
			for (var i:uint=0; i<l; i++) {
				var styleList:Object = list[i];
				for (var n:String in styleList) {
					if (styles[n] != null) { continue; }
					styles[n] = list[i][n];
				}
			}
			return styles;
		}



		public function YComponent() {
			super();
			
			instanceStyles = {};
			sharedStyles = {};
			invalidHash = {};

			callLaterMethods = new Dictionary();
			
			StyleManager.registerInstance(this);

			configUI();
			//invalidate(InvalidationType.ALL);
			// We are tab enabled by default if IFocusManagerComponent
			tabEnabled = (this is IFocusManagerComponent);
			// We do our own focus drawing.
			focusRect = false;

			// Register for focus and keyboard events.
			if (tabEnabled) {
				addEventListener(FocusEvent.FOCUS_IN, focusInHandler);
				addEventListener(FocusEvent.FOCUS_OUT, focusOutHandler);
				addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
				addEventListener(KeyboardEvent.KEY_UP, keyUpHandler);
			}

			initializeFocusManager()
		}
	
        public function get enabled():Boolean { return _enabled; }
		public function set enabled(value:Boolean):void {
			if (value == _enabled) { return; }
			_enabled = value;
			invalidate(InvalidationType.STATE);
		}

		public function setSize(width:Number, height:Number):void {
			_width = width;
			_height = height;
			invalidate(InvalidationType.SIZE);
			dispatchEvent(new ComponentEvent(ComponentEvent.RESIZE, false));
		}

		override public function get width():Number { return _width; }
		override public function set width(value:Number):void {
			if (_width == value) { return; }
			setSize(value, height);
		}

		override public function get height():Number { return _height; }
		override public function set height(value:Number):void {
			if (_height == value) { return; }
			setSize(width, value);
		}

		
        /**
         * Sets a style property on this component instance. This style may 
         * override a style that was set globally.
         */
		public function setStyle(style:String, value:Object):void {
			//Use strict equality so we can set a style to null ... so if the instanceStyles[style] == undefined, null is still set.
			//We also need to work around the specific use case of TextFormats
			if (instanceStyles[style] === value && !(value is TextFormat)) { return; }
			instanceStyles[style] = value;
			invalidate(InvalidationType.STYLES);
		}
		
		public function setStyleByObject(style : Object):void {
			for(var n : String in style){
				setStyle(n, style[n]);
			}
		}
		
		public function clearStyle(style:String):void {			
			setStyle(style,null);
		}

		public function getStyle(style:String):Object {
			return instanceStyles[style]
		}

		public function move(x:Number,y:Number):void {
			_x = x;
			_y = y;
			super.x = Math.round(x);
			super.y = Math.round(y);
			dispatchEvent(new ComponentEvent(ComponentEvent.MOVE));
		}

        override public function get x():Number { return ( isNaN(_x) )?super.x:_x; }
        override public function set x(value:Number):void {
            move(value,_y);
        }

		override public function get y():Number {
			return ( isNaN(_y) )?super.y:_y;
		}

		override public function set y(value:Number):void {
			move(_x, value);	
		}
		
		protected function getScaleY():Number {
			return super.scaleY;
		}
		protected function setScaleY(value:Number):void {
			super.scaleY = value;
		}
		protected function getScaleX():Number {
			return super.scaleX;
		}
		protected function setScaleX(value:Number):void {
			super.scaleX = value;
		}

		
		
		override public function get visible():Boolean {
			return super.visible;	
		}
		override public function set visible(value:Boolean):void {
			if (super.visible == value) { return; }
			super.visible = value;
			var t:String = (value) ? ComponentEvent.SHOW : ComponentEvent.HIDE;
			dispatchEvent(new ComponentEvent(t, true));
		}

        /**
         * Validates and updates the properties and layout of this object, redrawing it
         * if necessary. 
         *
         * <p>Properties that require substantial computation are normally not processed
         * until the script finishes executing. This is because setting one property could
         * require the processing of other properties. For example, setting the <code>width</code> 
         * property may require that the widths of the children or parent of the object also 
         * be recalculated. And if the script recalculates the width of the object more than 
         * once, these interdependent properties may also require recalculating. Use this
         * method to manually override this behavior.</p>
         *
         */
		public function validateNow():void {
			invalidate(InvalidationType.ALL,false);
			draw();
		}

        /**
         * Marks a property as invalid and redraws the component on the
         * next frame unless otherwise specified.
         *
         * @param property The property to be invalidated.
         *
         * @param callLater A Boolean value that indicates whether the
         *        component should be redrawn on the next frame. The default
         *        value is <code>true</code>.
         *
         */
		public function invalidate(property:String=InvalidationType.ALL,callLater:Boolean=true):void {
			invalidHash[property] = true;
			if (callLater) { this.callLater(draw); }
		}

		/**
		 * Sets the inherited style value to the specified style name and
		 * invalidates the styles of the component.
		 * 原FL组件中,调用StyleManager.setComponentStyle()时,
		 * 会调用此方法进行共享样式的设置,但考虑到调用此方法,
		 * 会导致具体组件无法将自身样式设置为null,所以改成了调用setStyle()方法.
         */
		public function setSharedStyle(name:String,style:Object):void {
			if (sharedStyles[name] === style  && !(style is TextFormat)) { return; }
			sharedStyles[name] = style;
			if (instanceStyles[name] == null) {
				invalidate(InvalidationType.STYLES);
			}
		}


		public function get focusEnabled():Boolean {
			return _focusEnabled;
		}
		public function set focusEnabled(b:Boolean):void {
			_focusEnabled = b;
		}


		public function get mouseFocusEnabled():Boolean {
			return _mouseFocusEnabled;
		}
		public function set mouseFocusEnabled(b:Boolean):void {
			_mouseFocusEnabled = b;
		}

		public function get focusManager():IFocusManager {
			var o:DisplayObject = this;
			while (o) {
				if (YComponent.focusManagers[o] != null) {
					return IFocusManager(YComponent.focusManagers[o]);
				}
				o = o.parent;
			}
			return null;
		}
		public function set focusManager(f:IFocusManager):void {
			YComponent.focusManagers[this] = f;
		}


		public function drawFocus(focused:Boolean):void {
			isFocused = focused; // We need to set isFocused here since there are drawFocus() calls from FM.
		}

        
		public function setFocus():void {
			if (stage) {
				stage.focus = this;
			}
		}

		public function getFocus():InteractiveObject {
			if (stage) {
				return stage.focus;
			}
			return null;
		}
		
		
        /**
         * Initiates an immediate draw operation, without invalidating everything as <code>invalidateNow</code> does.
         */
		public function drawNow():void
		{
			draw();
		}

		protected function configUI():void
		{			
			
		}
        // Included the first property as a proper param to enable *some* type checking, and also because it is a required param.		
		protected function isInvalid(property:String,...properties:Array):Boolean {
			if (invalidHash[property] || invalidHash[InvalidationType.ALL]) { return true; }
			while (properties.length > 0) {
				if (invalidHash[properties.pop()]) { return true; }
			}
			return false
		}
		protected function validate():void {
			invalidHash = {};
		}
		
		protected function draw():void {
			// classes that extend UIComponent should deal with each possible invalidated property
			// common values include all, size, enabled, styles, state
			// draw should call super or validate when finished updating
			if (isInvalid(InvalidationType.SIZE,InvalidationType.STYLES)) {
				if (isFocused && focusManager.showFocusIndicator) { drawFocus(true); }
			}
			validate();
		}

		protected function getDisplayObjectInstance(skin:Object):DisplayObject {
			if(skin is DisplayObject){
				return skin as DisplayObject;
			}
			return SkinFactory.create(skin) as DisplayObject;
		}
		
		protected function getStyleValue(name:String):Object {
			return (instanceStyles[name] == null) ? sharedStyles[name] : instanceStyles[name];
		}
		
		protected function copyStylesToChild(child:YComponent,styleMap:Object):void {
			for (var n:String in styleMap) {
				child.setStyle(n,getStyleValue(styleMap[n]));
			}
		}
		protected function copyStylesFromObject(child:YComponent,styleMap:Object):void {
			for (var n:String in styleMap) {
				child.setStyle(n,styleMap[n]);
			}
		}
		
		protected function callLater(fn:Function):void {
			callLaterMethods[fn] = true;
			if (stage != null) {
				stage.addEventListener(Event.RENDER,callLaterDispatcher,false,0,true);
				stage.invalidate();				
			} else {
				addEventListener(Event.ADDED_TO_STAGE,callLaterDispatcher,false,0,true);
			}
		}

		protected function callLaterDispatcher(event:Event):void {
			if (event.type == Event.ADDED_TO_STAGE) {
				removeEventListener(Event.ADDED_TO_STAGE,callLaterDispatcher);
				// now we can listen for render event:
				stage.addEventListener(Event.RENDER,callLaterDispatcher,false,0,true);
				stage.invalidate();
				
				return;
			} else {
				event.target.removeEventListener(Event.RENDER,callLaterDispatcher);
				if (stage == null) {
					// received render, but the stage is not available, so we will listen for addedToStage again:
					addEventListener(Event.ADDED_TO_STAGE,callLaterDispatcher,false,0,true);
					return;
				}
			}

			var methods:Dictionary = callLaterMethods;
			for (var method:Object in methods) {
				method();
				delete(methods[method]);
			}
		}



		private function initializeFocusManager():void {
			// create root FocusManager
			if(stage == null) {
				// we don't have stage yet, wait for it
				addEventListener(Event.ADDED_TO_STAGE, addedHandler, false, 0, true);
			} else {
				// we have stage: if not already created, create FocusManager
				createFocusManager();
				var fm:IFocusManager = focusManager;
				if (fm != null) {
					var fmUserDict:Dictionary = focusManagerUsers[fm];
					if (fmUserDict == null) {
						fmUserDict = new Dictionary(true);
						focusManagerUsers[fm] = fmUserDict;
					}
					fmUserDict[this] = true;
				}
			}
			addEventListener(Event.REMOVED_FROM_STAGE, removedHandler);
		}
		private function addedHandler(evt:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, addedHandler);
			initializeFocusManager();
		}
		private function removedHandler(evt:Event):void {
			removeEventListener(Event.REMOVED_FROM_STAGE, removedHandler);
			addEventListener(Event.ADDED_TO_STAGE, addedHandler);
			var fm:IFocusManager = focusManager;
			if (fm != null) {
				// check to see if any components are registered as users of this IFocusManager
				var fmUserDict:Dictionary = focusManagerUsers[fm];
				if (fmUserDict != null) {
					delete fmUserDict[this];
					var dictEmpty:Boolean = true;
					for (var key:* in fmUserDict) {
						dictEmpty = false;
						break;
					}
					if (dictEmpty) {
						delete focusManagerUsers[fm];
						fmUserDict = null;
					}
				}
				// if there are no users registered, deactivate the IFocusManager and remove it from
				// the focusManagers Dictionary to ensure it can be garbage collected.
				if (fmUserDict == null) {
					fm.deactivate();
					for (var key2:* in focusManagers) {
						var compFM:IFocusManager = focusManagers[key2];
						if (fm == compFM) delete focusManagers[key2];
					}
				}
			}
		}
		protected function createFocusManager():void {
			if (focusManagers[stage] == null) {
				focusManagers[stage] = new FocusManager(stage);
			}
		}
		protected function isOurFocus(target:DisplayObject):Boolean {
			return (target == this);
		}
		protected function focusInHandler(event:FocusEvent):void {
			if (isOurFocus(event.target as DisplayObject)) {
				var fm:IFocusManager = focusManager;
				if (fm && fm.showFocusIndicator) {
					drawFocus(true);
					isFocused = true;
				}
			}
		}
		protected function focusOutHandler(event:FocusEvent):void {
			if (isOurFocus(event.target as DisplayObject)) {
				drawFocus(false);
				isFocused = false;
			}
		}
		protected function keyDownHandler(event:KeyboardEvent):void {
			// You must override this function if your component accepts focus
		}
		protected function keyUpHandler(event:KeyboardEvent):void {
			// You must override this function if your component accepts focus
		}
		
		protected function setIMEMode(enabled:Boolean) :void{
			if(_imeMode != null) {
				if(enabled) {
					IME.enabled = true;
					_oldIMEMode = IME.conversionMode;
					try {
						if (!errorCaught && IME.conversionMode != IMEConversionMode.UNKNOWN) {
							IME.conversionMode = _imeMode;
						}
						errorCaught = false;
					} catch(e:Error) {
						errorCaught = true;				
						throw new Error("IME mode not supported: " + _imeMode);
					}
				} else {
					if (IME.conversionMode != IMEConversionMode.UNKNOWN && _oldIMEMode != IMEConversionMode.UNKNOWN) {
						IME.conversionMode = _oldIMEMode;
					}
					IME.enabled = false;
				}
			}
		}
		public function asDisplayObject():DisplayObject
		{
			return this;
		}
		public function getTip():ITip
		{
			if(_tipFactory != null)
			{
				return _tipFactory();
			}
			return null;
		}
		public function setTipFactory(factory : Function):void
		{
			_tipFactory = factory
		}
		public function getTipOffsetPos():Point
		{
			return _tipPosOffset;
		}
		public function setTipOffsetPos(pt : Point):void
		{
			_tipPosOffset = pt;
		}
	}

}