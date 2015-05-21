package com.swipethrough.helpers
{
	/**
	 * @author christian
	 */
	public function getFunctionName(e:Error) : String
	{
		var stackTrace:String = e.getStackTrace();     // entire stack trace
	    var startIndex:int = stackTrace.indexOf("at ");// start of first line
	    var endIndex:int = stackTrace.indexOf("()");   // end of function name
	    var instanceAndMethod : String = stackTrace.substring(startIndex + 3, endIndex);
		var arr : Array = instanceAndMethod.split("/");
		return arr[arr.length-1];
	}
}
