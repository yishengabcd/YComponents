/**
 * date:2012-2-12
 * author:yisheng;
 */
package ys.components.controls.member
{
	import ys.components.controls.YMultiFrameImage;

	public class FramesImageStateStrategy implements IStateStrategy
	{
		private var _target : YMultiFrameImage;
		public function FramesImageStateStrategy()
		{
		}
		
		public function setTarget(target:Object):void
		{
			_target = target as YMultiFrameImage;
		}
		
		public function mouseOver():void
		{
			_target.setFrame(1);
		}
		
		public function mouseUp():void
		{
			_target.setFrame(0);
		}
		
		public function mouseDown():void
		{
			_target.setFrame(2);
		}
	}
}