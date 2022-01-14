package menus;

import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
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
		"Note Splashes",
		"Adjust Hitsounds",
		"Manage Keybinds",
	];

	var pauseOptions:Array<String> = [];

	var selectedOption:Int = 0;
	var pauseMusic:FlxSound;
	var practiceText:FlxText;
	var botplayText:FlxText;
	var descText:FlxText;
	var warningText:FlxText; // shows up if you've changed smth like note splashes
	var bg:FlxSprite;

	public function new(?x:Float, ?y:Float)
	{
		super();

		pauseOptions = defaultPauseOptions;

		pauseMusic = new FlxSound().loadEmbedded('assets/music/breakfast' + Util.soundExt, true, true);
		pauseMusic.volume = 0;
		pauseMusic.play(false, FlxG.random.int(0, Std.int(pauseMusic.length / 2)));

		FlxG.sound.list.add(pauseMusic);

		bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0;
		bg.scrollFactor.set();
		add(bg);

		warningText = new FlxText(0, FlxG.height * 0.95, 0, "", 24);
		warningText.setFormat("assets/fonts/vcr.ttf", 24, FlxColor.WHITE, RIGHT);
		warningText.borderStyle = OUTLINE;
		warningText.borderSize = 2;
		warningText.borderColor = FlxColor.BLACK;
		add(warningText);

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

	/*override public function openSubState(SubState:flixel.FlxSubState)
	{
		persistentDraw = false;
		super.openSubState(SubState);
	}

	override public function closeSubState()
	{
		persistentDraw = true;
		super.closeSubState();
	}*/

	override public function update(elapsed:Float)
	{
		if (pauseMusic.volume < 0.5)
			pauseMusic.volume += 0.01 * elapsed;

		bg.alpha = FlxMath.lerp(bg.alpha, 0.6, Math.max(0, Math.min(1, elapsed * 6)));

		var up = Controls.UI_UP;
		var down = Controls.UI_DOWN;
		var accept = Controls.accept;

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
					Options.saveData('botplay', !Options.getData('botplay'));
					game.PlayState.botplayText.visible = Options.getData('botplay');
					showOptionWarning(0);

				case 'Ghost Tapping':
					Options.saveData('ghost-tapping', !Options.getData('ghost-tapping'));
					showOptionWarning(1);

				case 'Note Splashes':
					Options.saveData('note-splashes', !Options.getData('note-splashes'));
					showOptionWarning(2);

				case 'Adjust Hitsounds':
					openSubState(new HitsoundMenu()); // can you open substates in substates? sure hope you can

				case 'Manage Keybinds':
					openSubState(new KeybindMenu());

				case 'FPS Cap':
					openSubState(new FPSCapMenu());
			}
		}

		super.update(elapsed);
	}

	function showOptionWarning(?warning:Int = 0)
	{
		var swagText:String = "";
		var daString:String = "";

		switch(warning)
		{
			case 0:
				swagText = Options.getData('botplay') ? "On" : "Off";
				daString = "Botplay is now " + swagText.toLowerCase() + "!";
			case 1:
				swagText = Options.getData('ghost-tapping') ? "On" : "Off";
				daString = "Ghost Tapping is now " + swagText.toLowerCase() + "!";
			case 2:
				swagText = Options.getData('note-splashes') ? "On" : "Off";
				daString = "Note Splashes are now " + swagText.toLowerCase() + "!";
		}

		warningText.text = daString;
		warningText.x = FlxG.width - warningText.width;

		FlxTween.cancelTweensOf(warningText);
		warningText.alpha = 1;
		FlxTween.tween(warningText, {x: FlxG.width + 15, alpha: 0}, 0.4, {
			ease: FlxEase.cubeInOut,
			startDelay: 1,
			onComplete: function(twn:FlxTween)
			{
				// do nothign because uhsdcjnkALehds
			}
		});
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