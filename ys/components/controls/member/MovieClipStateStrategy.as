/**
 * date:2011-12-30
 * author:yisheng
 **/
package ys.components.controls.member
{
	import flash.display.MovieClip;

	public class MovieClipStateStrategy implements IStateStrategy
	{
		private var _mc : MovieClip
		public function MovieClipStateStrategy()
		{
		}
		public function setTarget(target : Object):void
		{
			_mc = target as MovieClip;
		}
		public function mouseOver():void
		{
			if(_mc){
				_mc.gotoAndStop(2);
			}
		}
		
		public function mouseUp():void
		{
			if(_mc){
				_mc.gotoAndStop(1);
			}
		}
		
		public function mouseDown():void
		{
			if(_mc){
				_mc.gotoAndStop(3);
			}
		}
	}
}