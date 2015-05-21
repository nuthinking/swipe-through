package com.swipethrough
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.utils.clearTimeout;
	import flash.utils.getTimer;
	import flash.utils.setTimeout;

	/**
	 * @author christian
	 */
	public class LongPressArea extends GestureAreaBase
	{
		private var initialPoint : Point;
		private var lastTimeTouched : int = 0;
		private var gestureBeginTimeOut : int;
		
		public function LongPressArea()
		{
			super();
			
			_color = 0x001FFF;
		}
		
		override protected function touchBegan ( e : MouseEvent ) : void
		{
			super.touchBegan(e);
			
			initialPoint = new Point(e.stageX, e.stageY);
			lastTimeTouched = getTimer();
			
			stage.addEventListener(MouseEvent.MOUSE_MOVE, tapDidMove);
			stage.addEventListener(MouseEvent.MOUSE_OUT, tapDidMoveOut);
			stage.addEventListener(MouseEvent.MOUSE_UP, tapRemovedTouch);
			
			gestureBeginTimeOut = setTimeout(beginGesture, TapArea.MAX_COMBINED_TAP_DURATION);
		}
		
		private function cancelTap () : void
		{
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, tapDidMove);
			stage.removeEventListener(MouseEvent.MOUSE_OUT, tapDidMoveOut);
			stage.removeEventListener(MouseEvent.MOUSE_UP, tapRemovedTouch);
		}
		
		private function tapDidMove ( e : MouseEvent ) : void
		{
			var newPosition : Point = new Point(e.stageX, e.stageY);
			if(Point.distance(initialPoint, newPosition)>TapArea.MAX_TAP_MOVEMENT){
				cancelTap();
			}
		}
		private function tapDidMoveOut (e : MouseEvent) : void
		{
			cancelTap();
		}
		
		private function tapRemovedTouch (e : MouseEvent) : void
		{
			var t : int = getTimer();
			if(t - lastTimeTouched<=TapArea.MAX_COMBINED_TAP_DURATION){
				didTap();
			}
			cancelTap();
		}
		private function didTap () : void
		{
//			trace("DID TAP");
			clearTimeout(gestureBeginTimeOut);
			if(_tapAction){
				performActionFromString(_tapAction);
			}
		}
		
		private function beginGesture () : void
		{
			cancelTap();
			
			parentTimeline.gotoAndPlay(initialFrame);
			
			stage.addEventListener(MouseEvent.MOUSE_MOVE, longPressMove);
			stage.addEventListener(MouseEvent.MOUSE_OUT, cancelGesture);
			stage.addEventListener(MouseEvent.MOUSE_UP, cancelGesture);
			addEventListener(Event.ENTER_FRAME, checkCompletion);
		}
		
		private function checkCompletion ( e : Event) : void
		{
			if(parentTimeline.currentFrame == finalGestureFrame){
				//trace("long pressed!");
				removeLongPressCheckListeners();
			}
		}
		
		private function longPressMove ( e : MouseEvent ) : void
		{
			var newPosition : Point = new Point(e.stageX, e.stageY);
			if(Point.distance(initialPoint, newPosition)>TapArea.MAX_TAP_MOVEMENT){
				cancelGesture();
			}
		}
		
		private function removeLongPressCheckListeners () : void
		{
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, longPressMove);
			stage.removeEventListener(MouseEvent.MOUSE_OUT, cancelGesture);
			stage.removeEventListener(MouseEvent.MOUSE_UP, cancelGesture);
			removeEventListener(Event.ENTER_FRAME, checkCompletion);
		}
		
		private function cancelGesture ( e : Event = null) : void
		{
			removeLongPressCheckListeners();
			rewind();
		}
	}
}
