/**
 * date:2011-12-31
 * author:yisheng
 **/
package ys.components.examples.ui
{
	import flash.display.GradientType;
	import flash.display.Shape;
	import flash.geom.Matrix;
	
	public class ButtonBackground extends Shape
	{
		public function ButtonBackground()
		{
			super();
			
			var matrix : Matrix = new Matrix()
			//matrix.rotate(-Math.PI*0.5);
			matrix.createGradientBox(80,30,Math.PI*0.5);
			
			graphics.beginGradientFill(GradientType.LINEAR,[0xf9f9f9,0xaaaaaa],[1,1],[0,255],matrix);
			graphics.drawRoundRect(0,0,80,30,5,5);
			
			matrix = new Matrix();
			matrix.createGradientBox(74,10,Math.PI*0.5);
			graphics.beginGradientFill(GradientType.LINEAR,[0xffffff,0xffffff],[0.9,0],[0,255],matrix);
			graphics.drawRoundRect(3,3,74,10,5,5);
			
			graphics.endFill();
		}
	}
}