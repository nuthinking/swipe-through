package com.swipethrough.typography
{
	import flash.display.Stage;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.text.TextField;
	/**
	 * @author christian
	 */
	public class ProgressNumber extends Object
	{
		private var _field : TextField;
		private var _timeline : MovieClip;
		private var _initialFrame : int;
		private var _finalFrame : int;
		private var _formatFunction : Function;
		private var _lastFrame : int;
		private var _stage : Stage;
		
		public static function make(field : TextField, timeline : MovieClip, initialFrame : int, finalFrame : int, formatFunction : Function) : ProgressNumber
		{
			var pn :ProgressNumber = new ProgressNumber();
			pn._field = field;
			pn._timeline = timeline;
			pn._initialFrame = initialFrame;
			pn._finalFrame = finalFrame;
			pn._formatFunction = formatFunction;
			pn.start();
			return pn;
		}
		public function ProgressNumber()
		{
			super();
		}
		
		private function start () : void
		{
			if(!_field.stage){
				throw new Error("ProgressNumber only works if the textfield is already in the timeline");
			}
			_field.stage.addEventListener(Event.ENTER_FRAME, doEnterFrame);
			_stage = _field.stage;
			_lastFrame = -1;
		}
		
		private function doEnterFrame ( e : Event ) : void
		{
			if(!_field.stage){
				trace("progress not needed anymore, ProgressNumber will be invalidated");
				_stage.removeEventListener(Event.ENTER_FRAME, doEnterFrame);
				return;
			}
			var frame : int = _timeline.currentFrame;
			if(frame == _lastFrame)
				return;
				
			frame = Math.max(_initialFrame, Math.min(_finalFrame, frame));
			var pos : Number = (frame - _initialFrame) / (_finalFrame-_initialFrame); 
			_field.text = _formatFunction(pos);
			_lastFrame = _timeline.currentFrame;
		}
	}
}
