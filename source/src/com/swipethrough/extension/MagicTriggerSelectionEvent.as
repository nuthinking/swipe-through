package com.swipethrough.extension
{
	import flash.events.Event;

	/**
	 * @author christian
	 */
	public class MagicTriggerSelectionEvent extends Event
	{
		public static const NAME : String = "MagicTriggerSelectionEvent";
		
		private var __selectionIndex : int;
		
		public function MagicTriggerSelectionEvent(selectionIndex : int)
		{
			super(NAME);
			
			__selectionIndex = selectionIndex;
		}
		
		public function get selectionIndex () : int
		{
			return __selectionIndex;
		}
		
		
		override public function clone() : Event
		{
			return new MagicTriggerSelectionEvent(__selectionIndex);
		}
	}
}
