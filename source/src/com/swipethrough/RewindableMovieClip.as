package com.swipethrough
{
	import flash.events.Event;
	import flash.display.MovieClip;

	/**
	 * @author christian
	 */
	public class RewindableMovieClip extends MovieClip
	{
		public var lastFrame : uint = 1;
		private var __isPlaying : Boolean = false;
		
		public function RewindableMovieClip()
		{
			addEventListener(Event.ENTER_FRAME, updateLastframe, false, int.MIN_VALUE);
		}
		
		override public function stop () : void
		{
			super.stop();
			
			__isPlaying = false;
			cancelRewind();
		}
		
		override public function play () : void
		{
			super.play();
			
			__isPlaying = true;
			cancelRewind();
		}
		
		override public function gotoAndPlay(frame : Object, scene : String = null) : void
		{
			super.gotoAndPlay(frame, scene);
			
			__isPlaying = true;
			cancelRewind();
		}
		
		override public function gotoAndStop(frame : Object, scene : String = null) : void
		{
			super.gotoAndStop(frame, scene);
			
			__isPlaying = false;
			cancelRewind();
		}
		
		private function updateLastframe( e : Event ) : void
		{
			lastFrame = currentFrame;
		}
		
		public function rewind() : void
		{
			if(currentFrame == 1){
				return;
			}
			addEventListener(Event.ENTER_FRAME, rewindEnterFrame, false, int.MAX_VALUE);
		}
		
		private function cancelRewind () : void
		{
			removeEventListener(Event.ENTER_FRAME, rewindEnterFrame);
		}
		
		private function rewindEnterFrame ( e : Event ) : void
		{
			if(currentFrame>1){
				prevFrame();
			}else{
				stop();
			}
		}
	}
}
