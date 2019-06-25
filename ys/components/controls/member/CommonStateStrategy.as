/**
 * date:2011-12-30
 * author:yisheng
 **/
package ys.components.controls.member
{
	import flash.display.DisplayObject;
	
	import ys.utils.FilterUtils;

	public class CommonStateStrategy implements IStateStrategy
	{
		private var _target : DisplayObject
		public function CommonStateStrategy()
		{
		}
		
		public function setTarget(target:Object):void
		{
			_target = target as DisplayObject
		}
		
		public function mouseOver():void
		{
			if(_target){
				_target.filters = [FilterUtils.getLightingFilter()]
			}
		}
		
		public function mouseUp():void
		{
			if(_target){
				_target.filters = null
			}
		}
		
		public function mouseDown():void
		{
			if(_target){
				_target.filters = null
			}
		}
	}
}