/**
 * date:2011-7-13
 * author:yisheng
 **/
package ys.components.skin
{
	public class SkinFactory
	{
		private static var _impl : ISkinFactory2;
		public static function setSkinFactory2(value : ISkinFactory2):void
		{
			_impl = value;
		}
		private static function get impl():ISkinFactory2
		{
			if(!_impl){
				_impl = new SkinFactoryImpl();
			}
			return _impl;
		}
		public static function create(style : Object):*
		{
			return impl.create(style);
		}
	}
}