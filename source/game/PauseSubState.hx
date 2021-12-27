package game;

import menus.FreeplayMenuState;
import flixel.FlxG;
import flixel.FlxCamera;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.system.FlxSound;
import flixel.util.FlxColor;
import flixel.group.FlxGroup.FlxTypedGroup;
import ui.AlphabetText;

using StringTools;

class PauseSubState extends BasicSubState
{
	var grpOptions:FlxTypedGroup<AlphabetText>;

	var pauseOptions:Array<String> = [
		"Resume",
		"Restart Song",
		"Toggle Practice Mode",
		"Options",
		"Exit To Menu",
	];

	var selectedOption:Int = 0;
	var pauseMusic:FlxSound;
	var practiceText:FlxText;
	var botplayText:FlxText;
	var descText:FlxText;

	public function new(?x:Float, ?y:Float)
	{
		super();

		// if it crashes i am WAY too tired to fix rn - sworduceb

		pauseMusic = new FlxSound().loadEmbedded('assets/music/breakfast' + Util.soundExt, true, true);
		pauseMusic.volume = 0;
		pauseMusic.play(false, FlxG.random.int(0, Std.int(pauseMusic.length / 2)));

		FlxG.sound.list.add(pauseMusic);

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0;
		bg.scrollFactor.set();
		add(bg);

		grpOptions = new FlxTypedGroup<AlphabetText>();
		add(grpOptions);

		for (i in 0...pauseOptions.length)
		{
			var songText:AlphabetText = new AlphabetText(0, (70 * i) + 30, pauseOptions[i]);
			songText.isMenuItem = true;
			songText.targetY = i;
			grpOptions.add(songText);
		}

		changeSelection();

		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];

		// rembr: add song info shit into this later and also fun facts idkdfd
		// it's like 4:45am as of writing thsi i weant to die
	}

	override function update(elapsed:Float)
	{
		if (pauseMusic.volume < 0.5)
			pauseMusic.volume += 0.01 * elapsed;

		var up = FlxG.keys.justPressed.UP;
		var down = FlxG.keys.justPressed.DOWN;
		var accept = FlxG.keys.justPressed.ENTER;

		if(up) changeSelection(-1);
		if(down) changeSelection(1);

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
					// wanna do this tomorrow
				
				case 'Exit To Menu':
					if(PlayState.storyMode)
						FlxG.switchState(new menus.StoryModeState());
					else
						FlxG.switchState(new menus.FreeplayMenuState());
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