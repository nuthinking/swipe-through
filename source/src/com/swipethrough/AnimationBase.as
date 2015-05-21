package com.swipethrough
{
	import flash.utils.setTimeout;
	
	public class AnimationBase extends RewindableMovieClip
	{
		private var lastTime : uint;
		private var pauseTimeout : uint;
		
		public function AnimationBase()
		{
			lastTime = 0;
			
			/*this.addEventListener(MouseEvent.CLICK, this.didClick);*/
//			addEventListener(Event.ENTER_FRAME, updateDirection);
		}
		
		public function pause(duration:uint) : void
		{
			trace("duration: " + duration);
			stop();
			this.pauseTimeout = setTimeout(this.play, duration);
		}
	}
}