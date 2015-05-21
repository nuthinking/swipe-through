package com.swipethrough
{
	import flash.events.Event;
	import flash.events.GesturePhase;
	import flash.events.MouseEvent;
	import flash.events.TransformGestureEvent;
	import flash.geom.Point;
	import flash.utils.getTimer;

	/**
	 * @author christian
	 */
	public class PinchArea extends GestureAreaBase
	{
		// exposed
		private var _gestureSize : Number = 1;
		private var _hintDuration : int = 0;
		private var _gestureThreshold : Number = 0.5;
		
		private var isHinting : Boolean = false;
		private var scale : Number = 1;
		
		private var touchPoint : Point;
		private var lastTimeTouched : int = 0;
		public static const MAX_TAP_MOVEMENT : Number = 40;
		public static const MAX_TAP_DURATION : int = 150;
		
		public function PinchArea()
		{
			super();
			
			_color = 0xFFFF00;
			
			addEventListener(TransformGestureEvent.GESTURE_ZOOM , onZoom);
		}
		override protected function touchBegan(e : MouseEvent) : void
		{
			parent.removeEventListener(Event.ENTER_FRAME, rewindLoop);
			parentTimeline.stop();
			
			touchPoint = new Point(e.stageX, e.stageY);
			lastTimeTouched = getTimer();
			
			stage.addEventListener(MouseEvent.MOUSE_MOVE, didMove);
			stage.addEventListener(MouseEvent.MOUSE_OUT, didMoveOut);
			stage.addEventListener(MouseEvent.MOUSE_UP, removedTouch);
		}
		
		private function didMove ( e : MouseEvent ) : void
		{
			var newPosition : Point = new Point(e.stageX, e.stageY);
			if(Point.distance(touchPoint, newPosition)>MAX_TAP_MOVEMENT){
				cancelTap();
			}
		}
		
		private function didMoveOut (e : MouseEvent) : void
		{
			cancelTap();
		}
		private function removedTouch (e : MouseEvent) : void
		{
			var t : int = getTimer();
			if(t - lastTimeTouched<=MAX_TAP_DURATION){
				didTap();
			}
			cancelTap();
		}
		
		private function cancelTap () : void
		{
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, didMove);
			stage.removeEventListener(MouseEvent.MOUSE_OUT, didMoveOut);
			stage.removeEventListener(MouseEvent.MOUSE_UP, removedTouch);
		}
		
		private function didTap () : void
		{
			if(_tapAction){
				performActionFromString(_tapAction);
			}
		}
		
		function onZoom ( e : TransformGestureEvent ) : void
		{			
			var s : Number = (e.scaleX+e.scaleY)*0.5;
			switch(e.phase){
				case GesturePhase.BEGIN:
					cancelTap();
					scale = 1;
					initializeGesture();
					parent.removeEventListener(Event.ENTER_FRAME, rewindLoop);
					
					if(initialGestureFrame != initialFrame){
						if(parentTimeline.currentFrame == initialFrame){
							parentTimeline.play();
						}else{
							parentTimeline.gotoAndPlay(initialFrame);
						}
						parent.addEventListener(Event.ENTER_FRAME, checkHintPlayback);
						isHinting = true;
					}
					
					parentTimeline.play();
					
					break;
				case GesturePhase.UPDATE:
					trace("gesture update: " + isHinting);
					scale *= s;
					if(!isHinting){
						updateTimelinePosition();
					}
					break;
				case GesturePhase.END:
					parent.removeEventListener(Event.ENTER_FRAME, checkHintPlayback);
					isHinting = false;
					if(!isHinting && gestureProgress>=_gestureThreshold){
						parentTimeline.play();
					}else{
						rewind();
					}
					break;
			}
		}
		
		private function get boundedScale () : Number
		{
			var s : Number = scale;
			if(_gestureSize>1){
				// zoom
				s = Math.max(1, Math.min(_gestureSize, s));
			}else{
				s = Math.min(1, Math.max(_gestureSize, s));
			}
			return s;
		}
		
		private function get gestureProgress () : Number
		{
			return Math.abs(boundedScale-1)/Math.abs(_gestureSize-1);
		}
		
		private function updateTimelinePosition() : void
		{
			trace("scale: " + boundedScale + " progress: " + gestureProgress);
			parentTimeline.gotoAndStop(initialGestureFrame + Math.round(gestureProgress * (finalGestureFrame - initialGestureFrame)));
		}
		
		override protected function initializeGesture() : void
		{
			super.initializeGesture();
			
			initialGestureFrame = initialFrame + _hintDuration;
			
			if(_gestureSize == 1){
				throw new Error("There is no point on having a PinchArea with gesture size of 1.0");
			}
		}
		
		private function checkHintPlayback (e:Event) : void
		{
			if(parentTimeline.currentFrame == initialGestureFrame){
				parent.removeEventListener(Event.ENTER_FRAME, checkHintPlayback);
				parentTimeline.stop();
				isHinting = false;
				updateTimelinePosition();
			}
		}
		
		
		//
		// * * * * *   P R O P E R T I E S   * * * * *
		//
		
		
		[Inspectable(name="Gesture Size (%)", type=Number, defaultValue=1)]
		public function get gestureSize () : Number
		{
			return _gestureSize;
		}
		public function set gestureSize (value : Number) : void
		{
			_gestureSize = value;
		}
		
		[Inspectable(name="Hint Duration (fr)", type=Number, defaultValue=0)]
		public function get hintDuration () : int
		{
			return _hintDuration;
		}
		public function set hintDuration (value : int) : void
		{
			_hintDuration = value;
		}
		
		
		[Inspectable(name="Gesture Threshold (%)", type=Number, defaultValue=0.5)]
		public function get gestureThreshold () : Number
		{
			return _gestureThreshold;
		}
		public function set gestureThreshold ( value : Number  ) : void
		{
			_gestureThreshold = value;
		}
	}
}
