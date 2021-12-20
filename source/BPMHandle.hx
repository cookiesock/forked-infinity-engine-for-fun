import flixel.util.FlxTimer;

class BPMHandle
{
	var theTimer:FlxTimer;

	public function new(BPM:Float, curState)
	{
		var BPS = BPM / 60; // beats every second
		var delayTime = 1 / BPS; // makes it into actual loob times (the original is just beats every second this makes it something like.. 0.5 so if our bps was 2 then it would be 0.5 so it would loop twice evry second)
		theTimer = new FlxTimer().start(delayTime, curState.beatHit, 0);
	}

	public function Destroy()
	{
		theTimer.destroy();
		theTimer = null;
	}
}
