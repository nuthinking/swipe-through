package com.swipethrough.extension
{
	import flash.events.Event;
	import flash.geom.Point;

	/**
	 * @author christian
	 */
	public class MagicTriggerEvent extends Event
	{
		public static const NAME : String = "MagicTriggerEvent";
		
		private var __position : Point;
		
		public function MagicTriggerEvent(position : Point)
		{
			super(NAME);
			
			__position = position;
		}
		
		public function get touchPosition () : Point
		{
			return __position;
		}

		override public function clone() : Event
		{
			return new MagicTriggerEvent(__position);
		}

	}
}
