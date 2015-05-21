package com.swipethrough
{
	import flash.geom.Rectangle;
	import flash.geom.Point;
	import flash.events.MouseEvent;
	import flash.display.InteractiveObject;
	import flash.display.DisplayObject;
	/**
	 * @author christian
	 */
	public class UIScrollView
	{
		private var _contentView : InteractiveObject;
		private var _maskView : DisplayObject;
		private var _canScrollHorizontally : Boolean;
		private var _canScrollVertically : Boolean;
		private var _minScrollX : Number;
		private var _minScrollY : Number;
		private var _maxScrollX : Number;
		private var _maxScrollY : Number;
		
		private var _startTouchPoint : Point;
		private var _startDragPosition : Point;
		
		public static function makeWithMaskView(contentView : InteractiveObject, maskView : DisplayObject) : UIScrollView
		{
			var scroll : UIScrollView = new UIScrollView(contentView, maskView);
			scroll.updateScrollLimits();
			return scroll;
		}
		
		public static function makeWithMaskRect(contentView : InteractiveObject, maskRect : Rectangle) : UIScrollView
		{
			var scroll : UIScrollView = new UIScrollView(contentView);
			scroll.updateScrollLimitsWithRect(maskRect);
			return scroll;
		}
		
		public static function makeWithVerticalLimits(contentView : InteractiveObject, minScrollY : Number, maxScrollY : Number) : UIScrollView
		{
			var scroll : UIScrollView = new UIScrollView(contentView);
			scroll.updateLimits(0, minScrollY, 0, maxScrollY);
			return scroll;
		}
		
		public function UIScrollView (contentView : InteractiveObject, maskView : DisplayObject = null)
		{
			super();
			
			_contentView = contentView;
			_maskView = maskView;
		}
		
		public function updateScrollLimits() : void
		{
			updateScrollLimitsWithRect(new Rectangle(_maskView.x, _maskView.y, _maskView.width, _maskView.height));
		}
		
		public function updateScrollLimitsWithRect(rect : Rectangle) : void
		{
			if(rect.height < _contentView.height){
				_minScrollY = rect.y - (_contentView.height - rect.height);
				_maxScrollY = rect.y;
				trace("should scroll vertically");
			}else{
				_minScrollY = _maxScrollY = rect.y;
			}
			onLimitsUpdated();
		}
		
		public function updateLimits(minScrollX : Number = 0, minScrollY : Number = 0, maxScrollX : Number = 0, maxScrollY : Number = 0) : void
		{
			_minScrollX = minScrollX;
			_minScrollY = minScrollY;
			_maxScrollX = maxScrollX;
			_maxScrollY = maxScrollY;
			
			onLimitsUpdated();
		}
		
		private function onLimitsUpdated () : void
		{
			_canScrollVertically = _minScrollY != _maxScrollY;
			_canScrollHorizontally = _minScrollX != _maxScrollX;
			if(_canScrollHorizontally){
				trace("should scroll horizontally - NOT SUPPORTED");
			}
			if(_canScrollHorizontally || _canScrollVertically){
				if(!_contentView.hasEventListener(MouseEvent.MOUSE_DOWN)){
					_contentView.addEventListener(MouseEvent.MOUSE_DOWN, didTouch);
				}
			}else{
				_contentView.removeEventListener(MouseEvent.MOUSE_DOWN, didTouch);
			}
		}
		
		private function didTouch(e : MouseEvent) : void
		{
//			trace("did touch");
			_startTouchPoint = new Point(e.stageX, e.stageY);
			_startDragPosition = new Point(_contentView.x, _contentView.y);
			
			_contentView.stage.addEventListener(MouseEvent.MOUSE_MOVE, didDrag);
			_contentView.stage.addEventListener(MouseEvent.MOUSE_UP, didRelease);
		}
		
		private function didDrag(e : MouseEvent) : void
		{
//			trace("did drag");
			var p : Point = new Point(e.stageX, e.stageY);
			var newY : Number = _startDragPosition.y + (p.y - _startTouchPoint.y);
			_contentView.y = Math.max(_minScrollY, Math.min(_maxScrollY, newY));
		}
		
		private function didRelease(e : MouseEvent) : void
		{
			_contentView.stage.removeEventListener(MouseEvent.MOUSE_MOVE, didDrag);
			_contentView.stage.removeEventListener(MouseEvent.MOUSE_UP, didRelease);
		}
		
	}
}
