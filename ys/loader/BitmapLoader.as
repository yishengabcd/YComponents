/**
 * date:2012-1-14
 * author:yisheng
 */
package ys.loader
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;

	/**
	 * 图片加载类。
	 * 在完成加载后,可通过getBitmapData()获得BitmapData数据。
	 */	
	public class BitmapLoader extends DisplayObjectLoader
	{
		public function BitmapLoader(url:String)
		{
			super(url);
		}
		public function getBitmapData():BitmapData
		{
			if(_loader.content is Bitmap){
				return Bitmap(_loader.content).bitmapData;
			}else{
				throw new Error("BitmapLoader 只能用于加载位图!");
			}
			return null;
		}
	}
}