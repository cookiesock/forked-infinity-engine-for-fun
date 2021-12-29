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

class OffsetMenu extends BasicSubState
{
	var bg:FlxSprite;
	var offsetWarning:FlxText;
	var funnyOffset:FlxText;
	var holdTime:Float = 0;
	var stupidDumb:Float = 0;

	var leftP:Bool = false;
	var left:Bool = false;
	var rightP:Bool = false;
	var right:Bool = false;
	var accept:Bool = false;

	var maxOffset:Int = 1000;

	override public function create()
	{
		bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0;
		bg.scrollFactor.set();
		add(bg);

		funnyOffset = new FlxText(0, 0, 0, "placeholder", 64);
		funnyOffset.setFormat("assets/fonts/vcr.ttf", 64, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		funnyOffset.scrollFactor.set();
		funnyOffset.screenCenter();
		funnyOffset.borderSize = 2.4;
		add(funnyOffset);

		offsetWarning = new FlxText(0, FlxG.height * 0.8, 0, "Press LEFT & RIGHT to change how early/late notes appear.", 32);
		offsetWarning.setFormat("assets/fonts/vcr.ttf", 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		offsetWarning.scrollFactor.set();
		offsetWarning.screenCenter(X);
		offsetWarning.borderSize = 2.4;
		add(offsetWarning);

		super.create();
	}

	override public function update(elapsed:Float)
	{
		leftP = FlxG.keys.justPressed.LEFT;
		left = FlxG.keys.pressed.LEFT;
		rightP = FlxG.keys.justPressed.RIGHT;
		right = FlxG.keys.pressed.RIGHT;
		accept = FlxG.keys.justPressed.ENTER;

		if(FlxG.keys.justPressed.BACKSPACE)
			close();

		if(left || right) {
			var daMultiplier:Int = left ? -1 : 1;
			changeOffset(daMultiplier);
		} else {
			holdTime = 0;
		}

		funnyOffset.text = "Current Offset: " + Options.songOffset;
		funnyOffset.screenCenter();

		bg.alpha = FlxMath.lerp(bg.alpha, 0.6, Math.max(0, Math.min(1, elapsed * 6)));

		stupidDumb = elapsed;

		super.update(elapsed);
	}

	public function changeOffset(?change:Int = 0)
	{
		holdTime += stupidDumb;

		if(holdTime > 0.5 || leftP || rightP)
		{
			Options.songOffset += change;

			if(Options.songOffset < (maxOffset * -1))
				Options.songOffset = (maxOffset * -1);

			if(Options.songOffset > maxOffset)
				Options.songOffset = maxOffset;
		}
	}
}