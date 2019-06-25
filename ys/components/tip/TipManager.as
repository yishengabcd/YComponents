package ys.components.tip
{
	import flash.display.DisplayObjectContainer;
	import flash.display.Stage;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.utils.Dictionary;

	/**
	 * TIP管理类
	 * @author 黄亦生
	 * @date 2012-8-23
	 */
	public class TipManager
	{
		private static var _stage : Stage;
		
		private static var _tipTargets : Vector.<ITipTarget>;
		private static var _tipDic : Dictionary;
		public function TipManager()
		{
		}
		/**
		 * 添加TIP,将ITipTarget添加到管理器。
		 * 对于添加到管理器的TIP目标对象,当鼠标移动到其上方时,会产生TIP.
		 * 
		 * @param target
		 * 
		 */		
		public static function addTip(target : ITipTarget):void
		{
			if(_tipTargets.indexOf(target) > -1)
			{
				removeTip(target);
			}
			_tipTargets.push(target);
			target.addEventListener(MouseEvent.ROLL_OVER, onTargetOver);
			target.addEventListener(MouseEvent.ROLL_OUT, onTargetOut);
			if(isMouseOn(target))
			{
				showTip(target);
			}
		}
		private static function onTargetOver(event : MouseEvent):void
		{
			var target : ITipTarget = event.currentTarget as ITipTarget;
			showTip(target);
		}
		private static function showTip(target : ITipTarget):void
		{
			var tip : ITip = _tipDic[target];
			if(!tip)
			{
				tip = target.getTip();
				_tipDic[target] = tip;
			}
			if(tip)
			{
				if(!tip.parent)
				{
					_stage.addChild(tip.asDisplayObject());
				}
				adjustTipPosition(tip, target);
			}
		}
		private static function onTargetOut(event : MouseEvent):void
		{
			var target : ITipTarget = event.currentTarget as ITipTarget;
			hideTip(target);
		}
		private static function isMouseOn(target : ITipTarget):Boolean
		{
			var rect : Rectangle = target.getBounds(_stage);
			if(rect.contains(_stage.mouseX, _stage.mouseY))
			{
				return true;
			}
			return false;
		}
		private static function adjustTipPosition(tip : ITip, target : ITipTarget):void
		{
			var rect : Rectangle = target.getBounds(target.asDisplayObject());
			var startPt : Point = target.localToGlobal(new Point(rect.x, rect.y));
			var pt : Point = startPt.clone();
			var w : Number;
			var h : Number;
			if(target is TextField)
			{
				w = target["textWidth"];
				h = target["textHeight"];
			}else
			{
				w = rect.width;
				h = rect.height;
			}
			pt.x = pt.x+w+target.getTipOffsetPos().x;
			pt.y = pt.y+h+target.getTipOffsetPos().y;
			
			if(pt.x+tip.width > _stage.stageWidth)
			{
				pt.x = startPt.x + rect.width - tip.width;
				if(pt.x+tip.width > _stage.stageWidth)
				{
					pt.x = _stage.stageWidth - tip.width;
				}
			}
			
			if(pt.x < 0)
			{
				pt.x = 0;
			}
			if(pt.y + tip.height > _stage.stageHeight)
			{
				pt.y = startPt.y - tip.height;;
			}
			if(pt.y < 0)
			{
				pt.y = 0;
			}
			tip.asDisplayObject().x = pt.x;
			tip.asDisplayObject().y = pt.y;
		}
		/**
		 * 隐藏TIP.
		 * 暂时隐藏针对ITipTarget产生的TIP;
		 * 当鼠标再次移上ITipTarget对象时，仍然会弹出TIP。
		 * @param target
		 * 
		 */		
		public static function hideTip(target : ITipTarget):void
		{
			var tip : ITip = _tipDic[target];
			if(tip)
			{
				if(tip.parent)
				{
					_stage.removeChild(tip.asDisplayObject());
				}
			}
			_tipDic[target] = null;
			delete _tipDic[target];
		}
		/**
		 * 移除TIP,将TIP目标对象从管理器中移除.
		 * 移除后,TIP目标对象将不会再产生TIP,需重新通过showTip()方法来启动TIP功能;
		 * 通常在销毁对象时需通过该方法来移除TIP功能;
		 * @param target
		 * 
		 */		
		public static function removeTip(target : ITipTarget):void
		{
			target.removeEventListener(MouseEvent.ROLL_OVER, onTargetOver);
			target.removeEventListener(MouseEvent.ROLL_OUT, onTargetOut);
			
			hideTip(target);
			
			var index : int = _tipTargets.indexOf(target);
			if(index > -1)
			{
				_tipTargets.splice(index, 1);
			}
		}
		
		public static function hideAll():void
		{
			for(var target : Object in _tipDic)
			{
				hideTip(target as ITipTarget);
			}
		}
		/**
		 * 需先进行设置管理器才能正常使用 
		 * @param stage
		 * 
		 */		
		public static function setup(stage : Stage):void
		{
			_stage = stage;
			_tipTargets = new Vector.<ITipTarget>();
			_tipDic = new Dictionary();
		}
	}
}