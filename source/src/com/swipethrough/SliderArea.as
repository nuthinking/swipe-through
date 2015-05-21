package com.swipethrough
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;

	/**
	 * @author christian
	 */
	public class SliderArea extends ControlAreaBase
	{
		private var _fromFrame : String = "currentFrame";
		private var _toFrame : String = null;
		private var _orientation : String = "horizontal";
		private var _margin : Number = 0;
		private var _snapPositions : Array = null;
		
		private var initialGestureFrame : int;
		private var finalGestureFrame : int;
		private var lastPosition : Number;
		private var frameToSnap : int;
		
		public function SliderArea()
		{
			super();
			
			_color = 0xff7000;
			
			this.addEventListener(MouseEvent.MOUSE_DOWN, touchBegan);
		}
		
		function touchBegan ( e : MouseEvent ) : void
		{
			initializeGesture();
			
			onTouchedPoint(new Point(e.stageX, e.stageY));
			
			stage.addEventListener(MouseEvent.MOUSE_MOVE, touchMoved);
			stage.addEventListener(MouseEvent.MOUSE_UP, touchReleased);
		}
		
		private function touchMoved ( e : MouseEvent ) : void
		{
			onTouchedPoint(new Point(e.stageX, e.stageY));
		}
		
		private function touchReleased ( e : MouseEvent ) : void
		{
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, touchMoved);
			if(snapPositions.length>0){
				var closestPosition : Number = getClosestSnap();
				frameToSnap = initialGestureFrame + Math.round((finalGestureFrame-initialGestureFrame) * closestPosition);
				stage.addEventListener(Event.ENTER_FRAME, snapEnterFrame);
				snapEnterFrame(null);
			}
		}
		
		private function snapEnterFrame ( e : Event ) : void
		{
			if(parentTimeline.currentFrame == frameToSnap){
				stage.removeEventListener(Event.ENTER_FRAME, snapEnterFrame);
				return;
			}
			if(parentTimeline.currentFrame<frameToSnap){
				parentTimeline.nextFrame();
			}else{
				parentTimeline.prevFrame();
			}
		}
		
		private function getClosestSnap () : Number
		{
			var closestSnap : Number = snapPositions[0];
			var closestDistance : Number = Math.abs(lastPosition - closestSnap);
			var distance : Number;
			for(var i:uint = 1; i<snapPositions.length; i++){
				distance = Math.abs(lastPosition - snapPositions[i]);
				if(distance<closestDistance){
					closestDistance = distance;
					closestSnap = snapPositions[i];
				}
			}
			return closestSnap;
		}
		
		private function initializeGesture() : void
		{
			initialGestureFrame = frameFromString(_fromFrame);
//			trace("INITIAL GESTURE FRAME: " + initialGestureFrame);
			try {
				finalGestureFrame = frameFromString(_toFrame);
			}catch(e : Error){
				finalGestureFrame = parentTimeline.totalFrames;
			}
//			trace("FINAL GESTURE FRAME: " + finalGestureFrame);
		}
		
		private function onTouchedPoint(p : Point) : void
		{
			var globalPoint : Point = this.localToGlobal(new Point(0,0));
//			trace("global point: " + globalPoint);
//			trace("touch: " + p);
			
			var position : Number;
			if(_orientation == "horizontal"){
				position = (p.x - margin - globalPoint.x) / (width - margin*2);
			}else{
				
			}
			position = Math.max(0, Math.min(1, position));
			trace("position: " + position);
			var frame : int = initialGestureFrame + Math.round((finalGestureFrame-initialGestureFrame)*position);
			parentTimeline.gotoAndStop(frame);
			lastPosition = position;
		}
		
		//
		// * * * * *   P R O P E R T I E S   * * * * *
		//
		
		[Inspectable(name="From Frame", type=String, defaultValue="currentFrame")]
		public function get fromFrame () : String
		{
			return _fromFrame;
		}
		public function set fromFrame (value : String) : void
		{
			_fromFrame = value;
		}
		
		
		[Inspectable(name="To Frame", type=String, defaultValue="")]
		public function get toFrame () : String
		{
			return _toFrame;
		}
		public function set toFrame (value : String) : void
		{
			_toFrame = value;
		}
		
		
		[Inspectable(name="Orientation", type=String, defaultValue="horizontal", enumeration="horizontal,vertical")]
		public function get orientation() : String
		{
			return _orientation;
		}
		public function set orientation (value : String) : void
		{
			_orientation = value;
		}
		
		
		[Inspectable(name="Border margin", type=Number, defaultValue=0)]
		public function get margin () : Number
		{
			return _margin;
		}
		public function set margin (value : Number) : void
		{
			_margin = value;
		}
		
		
		[Inspectable(name="Snap Positions", defaultValue="0,1")]
		public function get snapPositions () : Array
		{
			return _snapPositions;
		}
		public function set snapPositions (v : Array) : void
		{
			_snapPositions = v;
		}
	}
}
