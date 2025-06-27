package kiss.util;

import kiss.util.Math.msToFrames;

/**
	Allows to repeat a callback every nth time update is called
**/
@:publicFields
class Repeat
{
	/**
		how many times update is called before the action is called
	**/
	var duration:Int;

	/**
		the callback function 
	**/
	var action:Repeat->Void;

	/**
		keeps track of how many more calls to update are needed before the callback will trigger
	**/
	var remaining:Int;

	/**
		whether to process or not
	**/
	var isActive:Bool;

	/**
		call in e.game update loiop for example
	**/
	function update()
	{
		if (!isActive)
			return;

		if (remaining <= 0)
		{
			remaining = duration;
			action(this);
		}
		else
		{
			remaining--;
		}
	}

	function new(duration:Int, action:Repeat->Void, isActive:Bool = true)
	{
		this.action = action;
		this.duration = duration;
		this.remaining = duration;
		this.isActive = isActive;
	}

	public function reset(isActive:Bool)
	{
		remaining = duration;
		this.isActive = isActive;
	}
}

class Countdown
{
	public var duration:Int;
	public var remaining:Int;

	public function new(durationMs:Int) {
		duration = msToFrames(durationMs);
		remaining = duration;
	}

	public function reset(){
		remaining = duration;
	}
}
