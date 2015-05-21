package com.swipethrough
{
	import flash.events.IOErrorEvent;
	import flash.display.Stage;
	import flash.net.URLRequest;
	import flash.display.Loader;
	import fl.core.UIComponent;
	import fl.motion.easing.Quadratic;
	import fl.transitions.Tween;
	import flash.display.DisplayObject;
	import flash.display.FrameLabel;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.ColorTransform;
	import flash.utils.getTimer;


	/**
	 * @author christian
	 */
	public class ControlAreaBase extends UIComponent
	{
		protected var _background:Sprite;
		protected var _color : uint;
		
		private var rewindToFrame : int;
		
		private var __parentTimeline : MovieClip;
		private var __lastStageClick : uint;
		
		private static var _currentStage : Stage;
		private var _lastStage : Stage;
		
		private static var _livingInstances : Array;
		protected static function addInstance (view : ControlAreaBase) : void
		{
//			trace("ADD INSTANCE");
			if(!_livingInstances){
				_livingInstances = [];
			}
			_livingInstances.push(view);
		}
		protected static function removeInstance (view : ControlAreaBase) : void
		{
//			trace("REMOVE INSTANCE");
			var index : int = _livingInstances.indexOf(view);
			if(index>-1){
				_livingInstances.splice(index, 1);
			}else{
				trace("Can't remove ControlAreaBase instance");
			}
		}
		
		private function getRoot() : DisplayObject
		{
			for each(var area : ControlAreaBase in _livingInstances){
				if(area.root) return area.root;
			}
			return null;
		}
		
		public static function loadSWF(value : String) : void
		{
			var swfName : String = value;
			var action : String;
			if(value.substring(0,1)=="("){
				// has command
				swfName = getSWFNameFromAction(value);
				action = value.split(".swf).")[1];
			}else{
				// TODO: check value should end with .swf
			}
			trace("load swf: " + swfName);
			trace("will perform action: " + action);
			var mLoader:Loader = new Loader();
			var mRequest:URLRequest = new URLRequest(swfName);
			var stageRef : Stage = _currentStage;
			mLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, function (loadEvent : Event) : void
			{
				var loadedMovie : DisplayObject = loadEvent.currentTarget["content"] as DisplayObject;
				loadedMovie.addEventListener(Event.EXIT_FRAME, function (event : Event) : void
				{
					loadedMovie.removeEventListener(Event.EXIT_FRAME, arguments.callee);
					stageRef.removeChildAt(0);
					stageRef.addChild(loadedMovie);
					if(action){
						performActionOnScopeFromString(loadedMovie, action);
					}
				});
			});
			mLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, function (event:IOErrorEvent) : void
			{
				trace("Couldn't load SWF with IOError: " + event);
			});
			mLoader.load(mRequest);
		}
		
		private static function getSWFNameFromAction (action : String) : String
		{
			var pattern:RegExp = /\b[\w.-]+.swf\b/;
			return action.match(pattern)[0];
		}
		
		private static function performActionOnScopeFromString(scope : DisplayObject, value : String) : void
		{
			var parameters : Array;
			var functionName : String = value;
			var beginParameters : int = value.indexOf("(");
			var endParameters : int = value.indexOf(")");
			if(beginParameters>-1){
				functionName = value.substr(0, beginParameters);
				if(endParameters>-1 && endParameters>beginParameters+1){
					trace("action has parameter");
					var parameterStr : String = value.substring(beginParameters+1, endParameters);
					parameters = parameterStr.split(",");
				}
			}
			(scope[functionName] as Function).apply(scope, parameters);
			/*if(functionName == "rewind"){
				if(parameters && parameters.length>1){
					throw new Error("Can't rewind to more than 1 step");
				}
				if(!parameters){
					parameters = [0];
				}
				performRewind(parameters[0]);
			}else if(functionName == "nextFrame"){
				if(parentTimeline.currentFrame == parentTimeline.totalFrames){
					if(parameters && parameters[0]=="parent" && parent.parent){
						(parent.parent as MovieClip).nextFrame();
					}else{
						parentTimeline.gotoAndStop(0);
					}
				}else{
					parentTimeline.nextFrame();
				}
			}else{
				(scope.parent[functionName] as Function).apply(parent, parameters);
			}*/
		}
		
		public function ControlAreaBase()
		{
			super();
			
			_color = 0x00FEFF;
			addEventListener(Event.ADDED_TO_STAGE, didAddToStage);
			addEventListener(Event.REMOVED_FROM_STAGE, didRemoveFromStage);
			
			if(stage && !stage.hasEventListener(MouseEvent.CLICK)){
				_currentStage = super.stage;
				_currentStage.addEventListener(MouseEvent.CLICK, didClickStage);
			}
		}
			
		override public function get stage() : Stage
		{
			if(!_lastStage && super.stage){
				_lastStage = super.stage;
			}
			return _lastStage;
		}

		private function didClickStage ( e : MouseEvent ) : void
		{
			var t : uint = getTimer();
			if(t-__lastStageClick<300){
				didDoubleClick(e);
				__lastStageClick = 0;
				return;
			}
			__lastStageClick = t;
		}
		
		protected function get parentTimeline () : MovieClip
		{
			return __parentTimeline;
		}
		
		protected function frameFromString ( value : String ) : int
		{
			if(value == "currentFrame"){
				return (parent as MovieClip).currentFrame;
			}
			var fn : Number = parseInt(value);
			if(isNaN(fn)){
				var frame : int = frameForLabel(value);
				if(frame == -1){
					throw new Error("Frame \"" + value + "\" couldn't be calculated");
				}
				fn = frame;
			}
			return int(fn);
		}
		
		protected function frameForLabel ( labelName : String ) : int
		{
			var labels : Array = parentTimeline.currentLabels;
			for each(var fl : FrameLabel in labels){
				if(fl.name == labelName){
					return fl.frame;
				}
			}
			trace("Couldn't find label \"" + labelName + "\"");
			return -1;
		}
		
		protected function performActionFromString(value : String) : void
		{
			trace("perform action: " + value);
			// check for swf
			if(containsSWFKeyboard(value)){
				loadSWF(value);
				return;
			}
			var scope : DisplayObject = this;
			while(value.indexOf("parent.")==0){
				scope = scope.parent;
				value = value.substr("parent.".length);
			}
			var parameters : Array;
			var functionName : String = value;
			var beginParameters : int = value.indexOf("(");
			var endParameters : int = value.indexOf(")");
			if(beginParameters>-1){
				functionName = value.substr(0, beginParameters);
				if(endParameters>-1 && endParameters>beginParameters+1){
					trace("action has parameter");
					var parameterStr : String = value.substring(beginParameters+1, endParameters);
					parameters = parameterStr.split(",");
				}
			}
			if(functionName == "rewind"){
				if(parameters && parameters.length>1){
					throw new Error("Can't rewind to more than 1 step");
				}
				if(!parameters){
					parameters = [0];
				}
				performRewind(parameters[0]);
			}else if(functionName == "nextFrame"){
				if(parentTimeline.currentFrame == parentTimeline.totalFrames){
					if(parameters && parameters[0]=="parent" && parent.parent){
						(parent.parent as MovieClip).nextFrame();
					}else{
						parentTimeline.gotoAndStop(0);
					}
				}else{
					parentTimeline.nextFrame();
				}
			}else{
				(scope.parent[functionName] as Function).apply(parent, parameters);
			}
		}
		
		private function containsSWFKeyboard ( value : String ) : Boolean
		{
			var pattern:RegExp = /\b.swf\b/;
			var result:Object = pattern.exec(value);
			return result != null;
		}
		
		protected function performRewind(steps:uint) : void
		{
			var previousFrames : Array = [];
			var labels : Array = parentTimeline.currentLabels;
			for each(var fl : FrameLabel in labels){
				if(fl.frame < parentTimeline.currentFrame){
					previousFrames.push(fl);
				}
			}
			if(steps > previousFrames.length){
				throw new Error("Can't rewind " + steps + " steps if there are only " + previousFrames.length + " labelled key frames before");
			}
			while(steps>0){
				previousFrames.pop();
				steps--;
			}
			var prevFrame : FrameLabel = previousFrames.pop();
			rewindToFrame = prevFrame.frame;
			trace("REWIND TO FRAME: " + rewindToFrame);
			parent.addEventListener(Event.ENTER_FRAME, __rewindLoop);
		}
		
		private function __rewindLoop ( e : Event) : void
		{
			if(parentTimeline.currentFrame == rewindToFrame){
				parentTimeline.removeEventListener(Event.ENTER_FRAME, __rewindLoop);
			}else{
				parentTimeline.gotoAndStop(parentTimeline.currentFrame-1);
			}
		}
		
//		private function touchBegan ( e : TouchEvent ) : void
//		{
//			trace("TOUCH BEGAN");
//			numStageTouches ++;
//			if(numStageTouches == 3){
//				lastTappedTime = getTimer();
//			}
//		}
//		
//		private function touchEnded ( e : TouchEvent ) : void
//		{
//			numStageTouches --;
//			if(numStageTouches == 2){
//				var t : int = getTimer();
//				if(t - lastTappedTime < 350){
//					toggleAreasVisibility();
//				}
//			}
//		}
		
		private function highlightHotSpots () : void
		{
			for each(var area : ControlAreaBase in _livingInstances){
				area.alpha = 1;
				new Tween(area, "alpha", Quadratic.easeIn, 1, 0, 1.0, true);
			}
		}
		
		private function didDoubleClick ( e : MouseEvent ) : void
		{
			var r : DisplayObject = getRoot();
			if(!r){
				// no instances
				return;
			}
			if(!r.hasOwnProperty("hideArea")){
				highlightHotSpots();
			}else{
				trace("Won't toggle areas visibility because root defines \"hideArea\"");
			}
		}
		
		private function didAddToStage ( e : Event ) : void
		{
			__parentTimeline = parent as MovieClip;
			addInstance(this);
			alpha = 0;
		}
		private function didRemoveFromStage(e : Event) : void
		{
			removeInstance(this);
		}
		
		override protected function configUI():void
		{
		    super.configUI();
			
			var bgDef:Object=this.loaderInfo.applicationDomain.getDefinition("SwipeThroughArea");
			_background = new bgDef as Sprite;
			addChild(_background);
		}
		
		override protected function draw():void
		{
			_background.width = width;
			_background.height = height;
			
			var tr : ColorTransform = new ColorTransform();
			tr.color = _color;
			_background.transform.colorTransform = tr;
			
			super.draw();
		}
	}
}
