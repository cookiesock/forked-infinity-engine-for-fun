package menus;

import game.StrumArrow;
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

class KeybindMenu extends BasicSubState
{
	var bg:FlxSprite;
	var daNotes:FlxTypedGroup<StrumArrow>;

	public function new()
	{
		super();
		bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0;
		bg.scrollFactor.set();
		add(bg);

		daNotes = new FlxTypedGroup<StrumArrow>();
		add(daNotes);

		for (i in 0...4) {
			var note:StrumArrow = new StrumArrow((135 * i) + 375, 0, i, Options.noteSkin);
			note.antialiasing = true;
			note.screenCenter(Y);
			daNotes.add(note);
		}
	}

	override public function update(elapsed:Float)
	{
		if(FlxG.keys.justPressed.BACKSPACE)
			close();

		bg.alpha = FlxMath.lerp(bg.alpha, 0.6, Math.max(0, Math.min(1, elapsed * 6)));

		super.update(elapsed);
	}
}