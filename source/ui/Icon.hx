package ui;

import mods.Mods;
import lime.utils.Assets;
import ui.TrackerSprite.TrackerDirection;
import flixel.FlxSprite;

using StringTools;

class Icon extends TrackerSprite
{
	public function new(?iconPath:String = "test", ?tracker:FlxSprite, ?isPlayer:Bool = false, ?xOff:Float = 10, ?yOff:Float = -30, ?direction:TrackerDirection = RIGHT)
	{
		super(tracker, xOff, yOff, direction);

		if(iconPath.contains('-pixel'))
			antialiasing = false;
		else
			antialiasing = true;

		#if sys
		if(Assets.exists(Util.getImage(iconPath, false)))
		#end
			loadGraphic(Util.getImage(iconPath, false), true, 150, 150);
		#if sys
		else
			loadGraphic(Util.getImage(iconPath, false), true, 150, 150);
		#end

		animation.add("default", [0], 0, false, isPlayer);
		animation.add("dead", [1], 0, false, isPlayer);
		animation.add("winning", [2], 0, false, isPlayer);

		animation.play("default");
	}
}