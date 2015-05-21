package com.swipethrough
{
	import flash.geom.Point;
	import flash.utils.getTimer;
	import flash.events.MouseEvent;
	
	// TODO: Add Hold action

	/**
	 * @author christian
	 */
	public class TapArea extends ControlAreaBase
	{
		private var _tapsRequired : int = 1;
 		private var _touchesRequired : int = 1;
		private var _action : String;
		
		private var lastTimeTouched : int = 0;
		private var touchPoint : Point;
		public static const MAX_TAP_MOVEMENT : Number = 40;
		public static const MAX_TAP_DURATION : int = 300;
		public static const MAX_COMBINED_TAP_DURATION : int = 150;
		
		public function TapArea()
		{
			_action = "play";
			addEventListener(MouseEvent.MOUSE_DOWN, didTouch);
//			this.addEventListener(MouseEvent.CLICK, didClick);
//			trace("TapArea Initiated");
		}
		
		private function didTouch(e : MouseEvent) : void
		{
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
			// TODO: should maybe store reference to stage to clean this up
			if(!stage)
				return;
				
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, didMove);
			stage.removeEventListener(MouseEvent.MOUSE_OUT, didMoveOut);
			stage.removeEventListener(MouseEvent.MOUSE_UP, removedTouch);
		}
		
		private function didTap () : void
		{
//			trace("DID TAP");
			performActionFromString(_action);
		}
		
		
		[Inspectable(name="Taps Required", type=Number, defaultValue=1)]
		public function get tapsRequired():int
		{
            return _tapsRequired;
        }
        public function set tapsRequired(value:int):void
		{
			if(value>1){
				throw new Error("TapArea currently doesn't support multiple taps");
			}
			
            _tapsRequired = value;
        }
		
		
		[Inspectable(name="Touches Required", type=Number, defaultValue=1)]
		public function get touchesRequired():int
		{
            return _touchesRequired;
        }
        public function set touchesRequired(value:int):void
		{
			if(value>1){
				throw new Error("TapArea currently doesn't support multi-touch");
			}
			
            _touchesRequired = value;
        }
		
		
		[Inspectable(name="Action", type=String, defaultValue="play")]
		public function get action() : String
		{
			return _action;
		}
		public function set action (value : String) : void
		{
			_action = value;
		}
	}
}
