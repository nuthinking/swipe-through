package com.swipethrough
{
	import flash.events.Event;
	import flash.events.MouseEvent;

	/**
	 * @author christian
	 */
	public class GestureAreaBase extends ControlAreaBase
	{
		protected var _fromFrame : String = "currentFrame";
		protected var _toFrame : String = null;
		protected var _tapAction : String;
		protected var _returnToHome : Boolean = false;
		protected var _touchesRequired : int;
		
		protected var homeFrame : int;
		protected var initialFrame : int;
		protected var initialGestureFrame : int;
		protected var finalGestureFrame : int;
		
		public function GestureAreaBase()
		{
			super();
			
			addEventListener(MouseEvent.MOUSE_DOWN, touchBegan);
		}
		
		protected function touchBegan ( e : MouseEvent) : void
		{
			parent.removeEventListener(Event.ENTER_FRAME, rewindLoop);
			parentTimeline.stop();
			
			initializeGesture();
		}
		
		protected function initializeGesture() : void
		{
			homeFrame = parentTimeline.currentFrame;
//			trace("HOME FRAME: " + homeFrame + " GO HOME?" + _returnToHome);
			initialFrame = frameFromString(_fromFrame);
//			trace("INITIAL FRAME: " + initialFrame);
			initialGestureFrame = initialFrame;
//			trace("INITIAL GESTURE FRAME: " + initialGestureFrame);
			finalGestureFrame = frameFromString(_toFrame);
//			trace("FINAL GESTURE FRAME: " + finalGestureFrame);
		}
		
		protected function rewind(animated : Boolean = true) : void
		{
			parent.removeEventListener(Event.ENTER_FRAME, rewindLoop);
			if(animated){
				parent.addEventListener(Event.ENTER_FRAME, rewindLoop);
			}else{
				if(_returnToHome){
					parentTimeline.gotoAndStop(homeFrame);
				}else{
					parentTimeline.gotoAndStop(initialFrame);
				}
			}
		}
		
		protected function rewindLoop ( e : Event) : void
		{
			if(parentTimeline.currentFrame == initialFrame){
				parent.removeEventListener(Event.ENTER_FRAME, rewindLoop);
				trace("REWINDED TO INITIAL FRAME: " + _returnToHome);
				if(_returnToHome){
					trace("RETURN HOME");
					parentTimeline.gotoAndStop(homeFrame);
				}
			}else{
				parentTimeline.gotoAndStop(parentTimeline.currentFrame-1);
			}
		}
		
		
		//
		// * * * * *   P R O P E R T I E S   * * * * *
		//
		
		
		[Inspectable(name="Touches Required", type=Number, defaultValue=1)]
		public function get touchesRequired():int
		{
            return _touchesRequired;
        }
        public function set touchesRequired(value:int):void
		{
            _touchesRequired = value;
        }
		
		
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
		
		
		[Inspectable(name="Tap Action", type=String, defaultValue="play")]
		public function get tapAction() : String
		{
			return _tapAction;
		}
		public function set tapAction (value : String) : void
		{
			_tapAction = value;
		}
		
		
		[Inspectable(name="Return Home", type=Boolean, defaultValue="false")]
		public function get returnToHome() : Boolean
		{
			return _returnToHome;
		}
		public function set returnToHome(value : Boolean) : void
		{
			_returnToHome = value;
		}
	}
}
