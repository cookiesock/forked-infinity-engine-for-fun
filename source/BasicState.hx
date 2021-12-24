package;

import game.Conductor;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.util.FlxTimer;

class BasicState extends FlxState
{
	//bpm and step
	var curStep:Int = 0;
	var curBeat:Int = 0;
	
	public function stepHit(timer:FlxTimer) {curStep++;}
	public function beatHit(timer:FlxTimer) {curBeat++;}

	var theTimer:FlxTimer;
	var theTimerButStep:FlxTimer;

	public function funkyBpm(BPM:Float)
	{
		var BPS = BPM / 60; // beats every second
		var delayTime = 1 / BPS; // makes it into actual loob times (the original is just beats every second this makes it something like.. 0.5 so if our bps was 2 then it would be 0.5 so it would loop twice evry second)
		var delayTimeStep = delayTime/4; // makes delay time to steps
		theTimer = new FlxTimer().start(delayTime, beatHit, 0);
		theTimerButStep = new FlxTimer().start(delayTimeStep, stepHit, 0);

		Conductor.changeBPM(BPM);
	}

	public function destroyFunkyBPM()
	{
		theTimer.destroy();
		theTimer = null;
		theTimerButStep.destroy();
		theTimerButStep = null;
	}

	//transition
	var transitionSpr:FlxSprite = new FlxSprite(0, 0, 'assets/images/transition');

	public function transitionState(close:Bool)
	{

	}
}
