package;

import game.PlayState;
import menus.TitleScreenState;
import flixel.FlxG;
import game.Conductor;
import flixel.FlxSprite;
import flixel.FlxState;
import lime.app.Application;
import flixel.addons.ui.FlxUIState;

class BasicState extends FlxUIState
{
	//bpm and step
	var curStep:Int = 0;
	var curBeat:Int = 0;

	public function new()
	{
		super();

		if(TitleScreenState.optionsInitialized)
			Controls.refreshControls();

		//if(FlxG.camera != null)
		//	FlxG.camera.fade(FlxColor.TRANSPARENT, 0.5, true);
	}

	public function funkyBpm(BPM:Float, ?songMultiplier:Float = 1)
	{
		Conductor.changeBPM(BPM, songMultiplier); // love how this function is basically useless because Conductor.changeBPM itself is a function lol
	}

	override public function create()
	{
		super.create();

		if(TitleScreenState.optionsInitialized)
			Controls.refreshControls();

		Util.clearMemoryStuff();
	}

	override public function update(elapsed:Float)
	{
		var oldStep:Int = curStep;

		updateCurStep();
		updateBeat();

		if(oldStep != curStep)
			stepHit();

		FlxG.stage.frameRate = Options.getData('fpsCap');

		if(TitleScreenState.optionsInitialized)
			Controls.refreshControls();

		super.update(elapsed);
	}

	//transition
	var transitionSpr:FlxSprite = new FlxSprite(0, 0, 'assets/images/transition.png');

	public function transitionState(state:FlxState)
	{
		if(TitleScreenState.optionsInitialized)
			Controls.refreshControls();
		
		FlxG.switchState(state);

		if(TitleScreenState.optionsInitialized)
			Controls.refreshControls();
		//FlxG.camera.fade(FlxColor.BLACK, 0.5, true, function(){ FlxG.switchState(state); }, true);
	}

	private function updateBeat():Void
	{
		curBeat = Math.floor(curStep / (16 / Conductor.timeScale[1]));
	}

	private function updateCurStep():Void
	{
		var lastChange:BPMChangeEvent = {
			stepTime: 0,
			songTime: 0,
			bpm: 0
		}
		
		for (i in 0...Conductor.bpmChangeMap.length)
		{
			if (Conductor.songPosition >= Conductor.bpmChangeMap[i].songTime)
				lastChange = Conductor.bpmChangeMap[i];
		}

		Conductor.recalculateStuff();

		curStep = lastChange.stepTime + Math.floor((Conductor.songPosition - lastChange.songTime) / Conductor.stepCrochet);

		updateBeat();
	}

	public function stepHit():Void
	{
		if (curStep % Conductor.timeScale[0] == 0)
			beatHit();
	}

	public function beatHit():Void
	{
		//do literally nothing dumbass
	}

	public static function changeAppTitle(?prefix:String = "", ?suffix:String = ""):Void
	{
		if(suffix != "" || suffix != null)
			Application.current.window.title = prefix + " - " + suffix;
		else
			Application.current.window.title = prefix;

		if(prefix == "" || prefix == null)
			Application.current.window.title = Util.engineName;
	}
}
