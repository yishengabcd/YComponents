/**
 * date:2011-12-31
 * author:yisheng
 **/
package ys.components.examples.utils
{
	import flash.display.DisplayObject;
	import flash.display.GradientType;
	import flash.display.Shape;
	import flash.display.Sprite;

	public class GraphicUtils
	{
//		/**
//		 * 扇形 
//		 * @param x
//		 * @param y
//		 * @param radius
//		 * @param sAngle
//		 * @param lAngle
//		 * @return 
//		 * 
//		 */		
//		public static function drawSector(x:Number, y:Number, radius:Number, sAngle:Number, lAngle:Number):Sprite
//		{
//			var sprite:Sprite = new Sprite();
//			var sx:Number = radius;
//			var sy:Number = 0;
//			if (sAngle != 0)
//			{
//				sx = Math.cos(sAngle * Math.PI/180) * radius;
//				sy = Math.sin(sAngle * Math.PI/180) * radius;
//			}
//			sprite.graphics.beginFill(0xffff00,1);
//			sprite.graphics.moveTo(x, y)
//			sprite.graphics.lineTo(x + sx, y - sy);
//			var a:Number=  lAngle * Math.PI / 180 / lAngle;
//			var cos:Number = Math.cos(a);
//			var sin:Number = Math.sin(a);
//			var b:Number = 0;
//			for (var i:Number = 0; i<lAngle; i++) 
//			{
//				var nx:Number = cos * sx - sin * sy;
//				var ny:Number = cos * sy + sin * sx;
//				sx = nx;
//				sy = ny;
//				sprite.graphics.lineTo(sx + x, -sy + y);
//			}
//			sprite.graphics.lineTo(x, y);
//			sprite.graphics.endFill();
//			return sprite;
//		}
//		
//		public static function changeSectorAngle(sprite:Sprite,x:Number,y:Number,radius:Number,sAngle:Number,lAngle:Number):void
//		{
//			sprite.graphics.clear();
//			var sx:Number = radius;
//			var sy:Number = 0;
//			if (sAngle != 0)
//			{
//				sx = Math.cos(sAngle * Math.PI/180) * radius;
//				sy = Math.sin(sAngle * Math.PI/180) * radius;
//			}
//			sprite.graphics.beginFill(0xffff00,1);
//			sprite.graphics.moveTo(x, y)
//			sprite.graphics.lineTo(x + sx, y - sy);
//			var a:Number=  lAngle * Math.PI / 180 / lAngle;
//			var cos:Number = Math.cos(a);
//			var sin:Number = Math.sin(a);
//			var b:Number = 0;
//			for (var i:Number = 0; i<lAngle; i++) 
//			{
//				var nx:Number = cos * sx - sin * sy;
//				var ny:Number = cos * sy + sin * sx;
//				sx = nx;
//				sy = ny;
//				sprite.graphics.lineTo(sx + x, -sy + y);
//			}
//			sprite.graphics.lineTo(x, y);
//			sprite.graphics.endFill();
//			sprite.graphics.beginGradientFill(
//		}	
//		public static function drawGradientRect(colors : Array,alphas : Array, ratios : Array):Shape
//		{
//			var shape : Shape = new Shape();
//			shape.graphics.beginGradientFill(GradientType.LINEAR);
//			shape.graphics.endFill();
//			return shape;
//		}
	}
}