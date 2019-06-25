package ys.components.controls.member
{
	public interface IStateStrategy
	{
		function setTarget(target : Object):void;
		
		function mouseOver():void;
		function mouseUp():void;
		function mouseDown():void;
	}
}