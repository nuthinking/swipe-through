package com.swipethrough
{
	import com.swipethrough.helpers.TouchView;
	import flash.desktop.NativeApplication;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.system.Capabilities;


	/**
	 * @author christian
	 */
	 
	public class PrototypeBase extends MovieClip
	{
		public function PrototypeBase()
		{
			stop();
			
			if(Capabilities.manufacturer.toLowerCase().indexOf("macintosh")>-1){
				stage.addEventListener(MouseEvent.MOUSE_DOWN, addTouch);
			}
			
			addEventListener(Event.DEACTIVATE,onDeactivate);
			
//			var magicGesture : MagicTrigger = new MagicTrigger();
//			magicGesture.addEventListener(MagicTrigger.GESTURE_PERFORMED_EVENT, onMagicGesturePerformed);
		}

		private function addTouch(event : MouseEvent) : void
		{
			var view : TouchView = new TouchView();
			view.x = event.stageX;
			view.y = event.stageY;
			addChild(view);
			view.startTracking();
		}
		
//		private function onMagicGesturePerformed(e : Event) : void
//		{
//			trace("ControlAreaBase.onMagicGesturePerformed");
//			gotoAndStop(1);
//		}
		
		private function onDeactivate(e:Event):void
		{
			if(Capabilities.manufacturer.toLocaleLowerCase().indexOf("android")>-1){
				NativeApplication.nativeApplication.exit();
			}else{
				gotoAndStop(1);
			}
        }
	}
}
