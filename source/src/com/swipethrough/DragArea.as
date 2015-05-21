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
	public class DragArea extends GestureAreaBase
	{
		private static const DIRECTION_ANY : String = "any";
		private static const DIRECTION_UP : String = "up";
		private static const DIRECTION_LEFT : String = "left";
		private static const DIRECTION_DOWN : String = "down";
		private static const DIRECTION_RIGHT : String = "right";
		private static const DIRECTION_HORIZONTAL : String = "horizontal";
		private static const DIRECTION_VERTICAL : String = "vertical";
		
		private var _gestureSize : Number = 0;
		private var _hintDuration : int = 0;
		private var _gestureThreshold : Number = 0.5;
		private var _direction : String = "any";
		
		private var initialPoint : Point;
		private var gestureProgress : Number = 0;
		private var lastTimeTouched : int = 0;
		private var gestureDirection : String = null;
		
		private var gestureBeginTimeOut : int;
		
		public function DragArea()
		{
			super();
			
			_color = 0xFF00FF;
		}
		
		override protected function touchBegan ( e : MouseEvent ) : void
		{
			super.touchBegan(e);
			
			if(gestureSize == 0){
				trace("Error: DragArea gesture size is 0, you probably want to set this value");
			}
			
			initialPoint = new Point(e.stageX, e.stageY);
			lastTimeTouched = getTimer();
			
			stage.addEventListener(MouseEvent.MOUSE_MOVE, tapDidMove);
			stage.addEventListener(MouseEvent.MOUSE_OUT, tapDidMoveOut);
			stage.addEventListener(MouseEvent.MOUSE_UP, tapRemovedTouch);
			
			gestureBeginTimeOut = setTimeout(beginGesture, TapArea.MAX_COMBINED_TAP_DURATION);
		}
		
		override protected function initializeGesture() : void
		{
			super.initializeGesture();
			
			initialGestureFrame = initialFrame + _hintDuration;
			gestureDirection = null;
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
			
			if(initialGestureFrame != initialFrame){
				playHint();
			}else{
				addGestureListeners();
			}
		}
		
		private function playHint() : void
		{
			if(parentTimeline.currentFrame == initialFrame){
				parentTimeline.play();
			}else{
				parentTimeline.gotoAndPlay(initialFrame);
			}
			parent.addEventListener(Event.ENTER_FRAME, checkHintPlayback);
			stage.addEventListener(MouseEvent.MOUSE_UP, cancelHint);
		}
		private function cancelHint( e : MouseEvent) : void
		{
			parent.removeEventListener(Event.ENTER_FRAME, checkHintPlayback);
			stage.removeEventListener(MouseEvent.MOUSE_UP, cancelHint);
			
			rewind();
		}
		
		private function checkHintPlayback ( e : Event ) : void
		{
			if(parentTimeline.currentFrame == initialGestureFrame){
				parent.removeEventListener(Event.ENTER_FRAME, checkHintPlayback);
				stage.removeEventListener(MouseEvent.MOUSE_UP, cancelHint);
				parentTimeline.stop();
				addGestureListeners();
			}
		}
		
		private function addGestureListeners () : void
		{
//			trace("ADD GESTURE LISTENERS");
			gestureProgress = 0;
			
			stage.addEventListener(MouseEvent.MOUSE_MOVE, touchMoved);
			stage.addEventListener(MouseEvent.MOUSE_UP, touchReleased);
		}
		private function touchMoved ( e : MouseEvent ) : void
		{
			var newPosition : Point = new Point(e.stageX, e.stageY);
			var distance : Number = Point.distance(initialPoint, newPosition);
			if(gestureDirection == null){
				if(distance>TapArea.MAX_TAP_MOVEMENT){
					gestureDirection = getCurrentGestureDirection(newPosition);
					if(_direction && _direction != DIRECTION_ANY){
						// catch failure
						var failed : Boolean = false;
						if(_direction == DIRECTION_HORIZONTAL){
							failed = !isGestureDirectionHorizontal();
						}else if(_direction == DIRECTION_VERTICAL){
							failed = !isGestureDirectionVertical();
						}else{
							failed = _direction != gestureDirection;
						}
						if(failed){
							trace("DRAG FAILED: _direction:" + _direction + " gestureDirection:" + gestureDirection);
							cancelGesture();
							return;
						}
					}
				}
			}
			if((_direction && _direction != DIRECTION_ANY) && gestureDirection){
				// fix distance
				switch(_direction){
					case DIRECTION_HORIZONTAL:
						distance = Math.abs(newPosition.x - initialPoint.x);
						break;
					case DIRECTION_VERTICAL:
						distance = Math.abs(newPosition.y - initialPoint.y);
						break;
					case DIRECTION_UP:
						distance = Math.max(0, initialPoint.y - newPosition.y);
						break;
					case DIRECTION_DOWN:
						distance = Math.max(0, newPosition.y - initialPoint.y);
						break;
					case DIRECTION_RIGHT:
						distance = Math.max(0, newPosition.x - initialPoint.x);
						break;
					default: // LEFT
						distance = Math.max(0, initialPoint.x - newPosition.x);
				}
			}
			gestureProgress = distance / _gestureSize;
			gestureProgress = Math.min(1, gestureProgress);
			parentTimeline.gotoAndStop(initialGestureFrame + Math.round(gestureProgress * (finalGestureFrame - initialGestureFrame)));
			//trace("Progress: " + gestureProgress + " FRAME: " + parentTimeline.currentFrame);
		}
		private function touchReleased ( e : MouseEvent ) : void
		{
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, touchMoved);
			stage.removeEventListener(MouseEvent.MOUSE_UP, touchReleased);
			
			//trace("COMPARE " + gestureProgress + " with " + _gestureThreshold);
			
			if(gestureProgress>=_gestureThreshold){
				//trace("GO FORWARD");
				parentTimeline.play();
			}else{
				//trace("GO BACKWARD");
				rewind();
			}
		}
		
		private function cancelGesture () : void
		{
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, touchMoved);
			stage.removeEventListener(MouseEvent.MOUSE_UP, touchReleased);
			
			rewind();
		}
		
		private function getCurrentGestureDirection (p : Point) : String
		{
			var radians : Number = Math.atan2(p.x - initialPoint.x, p.y - initialPoint.y);
			var degrees : Number = radians * 57.2957795;
			if (Math.abs(degrees)>=135){
				return DIRECTION_UP;
			}else if(Math.abs(degrees)<=45){
				return DIRECTION_DOWN;
			}else if(degrees>0){
				return DIRECTION_RIGHT;
			}else{
				return DIRECTION_LEFT;
			}
		}
		
		private function isDirectionHorizontal () : Boolean
		{
			return _direction == DIRECTION_LEFT || gestureDirection == DIRECTION_RIGHT;
		}
		
		private function isDirectionVertical () : Boolean
		{
			return _direction == DIRECTION_UP || gestureDirection == DIRECTION_DOWN;
		}
		
		private function isGestureDirectionHorizontal () : Boolean
		{
			return gestureDirection == DIRECTION_LEFT || gestureDirection == DIRECTION_RIGHT;
		}
		
		private function isGestureDirectionVertical () : Boolean
		{
			return gestureDirection == DIRECTION_UP || gestureDirection == DIRECTION_DOWN;
		}
		
		//
		// * * * * *   P R O P E R T I E S   * * * * *
		//
		
		
		[Inspectable(name="Gesture Size (px)", type=Number, defaultValue=0)]
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
		
		
		[Inspectable(name="Direction", type=String, defaultValue="any", enumeration="any,up,right,down,left,horizontal,vertical")]
		public function get direction () : String
		{
			return _direction;
		}
		public function set direction (value : String) : void
		{
			_direction = value;
		}
	}
}
