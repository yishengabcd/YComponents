/**
 * date:2011-7-13
 * author:yisheng
 **/
package ys.components.skin
{
	import flash.display.DisplayObject;
	import flash.utils.getDefinitionByName;
	
	import org.bytearray.display.ScaleBitmap;
	
	import ys.components.core.YComponent;
	import ys.utils.ClassUtils;

	public class SkinFactoryImpl implements ISkinFactory2
	{
		public function SkinFactoryImpl()
		{
		}
		
		public function create(skin : Object):*
		{
			if(!skin){
				return null;
			}
			var classDef:Object = null;
			if(isComponent(skin)){
				return createComponent(skin);
			}
			return ClassUtils.create(skin);
		}
		private function isComponent(skin : Object):Boolean
		{
			if(!skin){
				return false;
			}
			return skin.hasOwnProperty("classname")
		}
		private function createComponent(skin : Object):*
		{
			var comp : Object = create(skin.classname);
			if(comp){
				if(comp is YComponent){
					for(var styleName : String in skin){
						if(styleName != "classname"){
							YComponent(comp).setStyle(styleName, skin[styleName]);
						}
					}
				}
			}
			return comp;
		}
	}
}