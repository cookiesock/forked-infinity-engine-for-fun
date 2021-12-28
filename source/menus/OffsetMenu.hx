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

	override public function create()
	{
		bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0;
		bg.scrollFactor.set();
		add(bg);

		super.create();
	}

	override public function update(elapsed:Float)
	{
		if(FlxG.keys.justPressed.BACKSPACE)
			close();

		bg.alpha = FlxMath.lerp(bg.alpha, 0.6, Math.max(0, Math.min(1, elapsed * 6)));

		super.update(elapsed);
	}
}