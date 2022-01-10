package menus;

import menus.FreeplayMenuState;
import flixel.FlxG;
import flixel.FlxCamera;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.system.FlxSound;
import flixel.util.FlxColor;
import flixel.math.FlxMath;
import flixel.group.FlxGroup.FlxTypedGroup;
import ui.AlphabetText;

using StringTools;

class PauseMenu extends BasicSubState
{
	var grpOptions:FlxTypedGroup<AlphabetText>;

	var defaultPauseOptions:Array<String> = [
		"Resume",
		"Restart Song",
		"Toggle Practice Mode",
		"Options",
		"Exit To Menu",
	];

	var funnyOptions:Array<String> = [
		"Back",
		"Botplay",
		"Ghost Tapping",
	];

	var pauseOptions:Array<String> = [];

	var selectedOption:Int = 0;
	var pauseMusic:FlxSound;
	var practiceText:FlxText;
	var botplayText:FlxText;
	var descText:FlxText;
	var bg:FlxSprite;

	public function new(?x:Float, ?y:Float)
	{
		super();

		pauseOptions = defaultPauseOptions;

		// if it crashes i am WAY too tired to fix rn - sworduceb

		pauseMusic = new FlxSound().loadEmbedded('assets/music/breakfast' + Util.soundExt, true, true);
		pauseMusic.volume = 0;
		pauseMusic.play(false, FlxG.random.int(0, Std.int(pauseMusic.length / 2)));

		FlxG.sound.list.add(pauseMusic);

		bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0;
		bg.scrollFactor.set();
		add(bg);

		grpOptions = new FlxTypedGroup<AlphabetText>();
		add(grpOptions);

		refreshPauseOptions();
		changeSelection();

		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];

		// rembr: add song info shit into this later and also fun facts idkdfd
		// it's like 4:45am as of writing thsi i weant to die
	}

	public function refreshPauseOptions(?deletePreviousOptions:Bool = false)
	{
		if(deletePreviousOptions)
		{
			for(i in 0...grpOptions.members.length)
			{
				grpOptions.members[i].kill;
				grpOptions.members[i].destroy;

				grpOptions.clear();
			}
		}

		for (i in 0...pauseOptions.length)
			{
				var songText:AlphabetText = new AlphabetText(0, (70 * i) + 30, pauseOptions[i]);
				songText.isMenuItem = true;
				songText.targetY = i;
				grpOptions.add(songText);
			}
	}

	override function update(elapsed:Float)
	{
		if (pauseMusic.volume < 0.5)
			pauseMusic.volume += 0.01 * elapsed;

		bg.alpha = FlxMath.lerp(bg.alpha, 0.6, Math.max(0, Math.min(1, elapsed * 6)));

		var up = FlxG.keys.justPressed.UP;
		var down = FlxG.keys.justPressed.DOWN;
		var accept = FlxG.keys.justPressed.ENTER;

		if(up) changeSelection(-1);
		if(down) changeSelection(1);

		if (-1 * Math.floor(FlxG.mouse.wheel) != 0)
			changeSelection(-1 * Math.floor(FlxG.mouse.wheel));

		if(accept)
		{
			var selectedItem:String = pauseOptions[selectedOption];

			switch(selectedItem)
			{
				case 'Resume':
					close();

				case 'Restart Song':
					FlxG.resetState();

				case 'Toggle Practice Mode':
					// do nothing yet, i'm tired aaadfgiserh

				case 'Options':
					pauseOptions = funnyOptions;
					selectedOption = 0;
					refreshPauseOptions(true);
					changeSelection();
				
				case 'Exit To Menu':
					FreeplayMenuState.curSpeed = game.PlayState.songMultiplier;
					FlxG.sound.playMusic(Util.getSound('menus/freakyMenu', false));

					if(game.PlayState.storyMode)
						transitionState(new menus.StoryModeState());
					else
						transitionState(new menus.FreeplayMenuState());
				
				// options Shit
				case 'Back':
					pauseOptions = defaultPauseOptions;
					selectedOption = 0;
					refreshPauseOptions(true);
					changeSelection();

				case 'Botplay':
					game.PlayState.botplay = !game.PlayState.botplay;
					Options.saveData('botplay', game.PlayState.botplay);
					game.PlayState.botplayText.visible = Options.getData('botplay');

				case 'Ghost Tapping':
					game.PlayState.ghostTapping = !game.PlayState.ghostTapping;
					Options.saveData('ghost-tapping', game.PlayState.ghostTapping);
			}
		}

		super.update(elapsed);
	}

	override function destroy()
	{
		pauseMusic.destroy();

		super.destroy();
	}

	function changeSelection(change:Int = 0):Void
	{
		selectedOption += change;

		if (selectedOption < 0)
			selectedOption = pauseOptions.length - 1;

		if (selectedOption > pauseOptions.length - 1)
			selectedOption = 0;

		var bullShit:Int = 0;

		for(item in grpOptions.members)
		{
			item.targetY = bullShit - selectedOption;
			
			bullShit++;

			item.alpha = 0.6;

			if (item.targetY == 0)
				item.alpha = 1;
		}

		FlxG.sound.play(Util.getSound('menus/scrollMenu'));
	}
}