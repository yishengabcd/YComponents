/**
 * date:2011-12-31
 * author:yisheng
 **/
package ys.components.examples
{
	import ys.components.controls.YBaseButton;
	import ys.components.controls.YButton;
	import ys.components.examples.ui.ButtonBackground;
	import ys.components.style.StyleManager;

	public class ComponentDefaultSkin
	{
		public function ComponentDefaultSkin()
		{
			ButtonBackground
		}
		public static function setup():void
		{
			buttonSetting();
		}
		public static function buttonSetting():void
		{
			StyleManager.setComponentStyle(YButton, "background", "ys.components.examples.ui.ButtonBackground");
			StyleManager.setComponentStyle(YBaseButton, "background", "ys.components.examples.ui.ButtonBackground");
		}
	}
}