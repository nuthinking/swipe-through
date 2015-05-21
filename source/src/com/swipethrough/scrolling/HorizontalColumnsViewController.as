package com.swipethrough.scrolling
{
	import fl.transitions.Tween;
	import fl.motion.easing.Quintic;
	import flash.display.Sprite;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.geom.Point;

	/**
	 * @author christian
	 */
	public class HorizontalColumnsViewController extends EventDispatcher
	{
		private var loop : Boolean;
		private var columnWidth : Number;
		private var view : Sprite;
		
		private var initialDragPosition : Point;
		private var initialViewPosition : Point;
		
		private var columns : Array;
		private var numColumns : int;

		public function HorizontalColumnsViewController(view : Sprite, columnWidth : Number, loop : Boolean = true)
		{
			super();

			this.view = view;
			this.columnWidth = columnWidth;
			this.loop = loop;
			
			numColumns = Math.round(view.width / columnWidth);
			trace("Number of Columns: " + numColumns);
			
			view.addEventListener(MouseEvent.MOUSE_DOWN, startScrolling);
		}

		private function startScrolling(event : MouseEvent) : void
		{
			trace("start scrolling");
			view.stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			view.stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			
			initialDragPosition = new Point(this.view.stage.mouseX, this.view.stage.mouseY);
			initialViewPosition = new Point(this.view.x, this.view.y);
		}

		private function onMouseUp(event : MouseEvent = null) : void
		{
			view.stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			view.stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			
			snapToPosition();
		}

		private function onMouseMove(event : MouseEvent) : void
		{
			var deltaX : Number = this.view.stage.mouseX - initialDragPosition.x;
			this.view.x = initialViewPosition.x + deltaX;
		}
		
		private function snapToPosition () : void
		{
			var index : int = Math.round(view.x/columnWidth);
			var myTween:Tween = new Tween(view, "x", Quintic.easeOut, view.x, columnWidth * index, 0.33, true);
		}
	}
}
