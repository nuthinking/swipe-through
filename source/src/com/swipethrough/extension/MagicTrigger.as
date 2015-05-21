package com.swipethrough.extension
{
	import flash.events.EventDispatcher;
	import flash.events.StatusEvent;
	import flash.external.ExtensionContext;
	import flash.geom.Point;

	/**
	 * @author christian
	 */
	public class MagicTrigger extends EventDispatcher
	{
		private var extContext : ExtensionContext;
		private static var _instance:MagicTrigger = null;
		
		private static var _shouldCreateInstance:Boolean = false;
		
		public static function get instance () : MagicTrigger
		{
			if(_instance == null)
            {
                _shouldCreateInstance = true; 
                _instance = new MagicTrigger();
                _shouldCreateInstance = false;
            }
 
            return _instance;
		}
		
		public function MagicTrigger()
		{
			if (_shouldCreateInstance)
            {
                extContext = ExtensionContext.createExtensionContext("com.swipethrough", "magicGesture");
				extContext.addEventListener(StatusEvent.STATUS, onStatus);
            }
            else
            {
                throw new Error("Can't instantiate MagicTrigger ");  
            }      
		}
		
		private function onStatus(event : StatusEvent) : void
		{
			trace("Got status - level: " + event.level + " code: " + event.code);
			if(event.level == "status"){
				switch(event.code){
					case MagicTriggerEvent.NAME:
						var coordinates : Array = (Array) (extContext.call("getGesturePosition"));
						dispatchEvent(new MagicTriggerEvent(new Point(coordinates[0], coordinates[1])));
						break;
					case MagicTriggerSelectionEvent.NAME:
						var selection : int = (int)(extContext.call("getListSelection"));
						dispatchEvent(new MagicTriggerSelectionEvent(selection));
						break;
				}
			}
		}
		
		public function showOptions(options : Array) : void
		{
			extContext.call("showOptions", options);
		}
		
		public function dispose (): void
		{
			extContext.dispose();
			_instance = null;
		}
	}
}
