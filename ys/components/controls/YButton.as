package ys.components.controls {  
	import ys.components.core.YComponent;
	
	public class YButton extends YBaseButton{
		
		private static var defaultStyles:Object = {};
		
		public static function getStyleDefinition():Object { 
			return YComponent.mergeStyles(YBaseButton.getStyleDefinition(), defaultStyles);
		}		
		
		public function YButton() {
			super();
		}
	}
}
