/**
 * date:2012-1-14
 * author:yisheng
 */
package ys.loader
{
	import flash.net.URLLoaderDataFormat;

	public class TextLoader extends LoaderBase
	{
		public function TextLoader(url:String)
		{
			super(url);
			setLoaderDataFormat(URLLoaderDataFormat.TEXT);
		}
	}
}