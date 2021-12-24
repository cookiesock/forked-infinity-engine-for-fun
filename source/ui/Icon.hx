package ui;

import ui.TrackerSprite.TrackerDirection;
import flixel.FlxSprite;

class Icon extends TrackerSprite
{
	public function new(?iconPath:String = "test", ?tracker:FlxSprite, ?isPlayer:Bool = false, ?xOff:Float = 10, ?yOff:Float = -30, ?direction:TrackerDirection = RIGHT)
	{
		super(tracker, xOff, yOff, direction);

		loadGraphic(Util.getImage(iconPath, false), true, 150, 150);

		animation.add("default", [0], 0, false, isPlayer);
		animation.add("dead", [1], 0, false, isPlayer);
		animation.add("winning", [2], 0, false, isPlayer);

		animation.play("default");
	}
}