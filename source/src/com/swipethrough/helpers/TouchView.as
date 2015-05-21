package com.swipethrough.helpers
{
	import flash.events.MouseEvent;
	import flash.display.Graphics;
	import flash.display.Sprite;

	/**
	 * @author christian
	 */
	public class TouchView extends Sprite
	{
		public function TouchView()
		{
			var g : Graphics = this.graphics;
			g.beginFill(0x00D6F7);
			g.drawCircle(0, 0, 40);
			g.endFill();
			alpha = 0.5;
			mouseEnabled = false;
		}
		
		public function startTracking () : void
		{
			stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseMove);
			stage.addEventListener(MouseEvent.MOUSE_UP, mouseUp);
		}

		private function mouseUp(event : MouseEvent) : void
		{
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMove);
			stage.removeEventListener(MouseEvent.MOUSE_UP, mouseUp);
			
			parent.removeChild(this);
		}

		private function mouseMove(event : MouseEvent) : void
		{
			x = event.stageX;
			y = event.stageY;
		}
	}
}
