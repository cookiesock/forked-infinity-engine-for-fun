package ui;

import flixel.FlxSprite;

class Icon extends TrackerSprite
{
	public function new(?iconPath:String = "test", ?tracker:FlxSprite, ?isPlayer:Bool = false)
	{
		super(tracker, 10, -30, RIGHT);

		loadGraphic(Util.getImage(iconPath, false), true, 150, 150);

		animation.add("default", [0], 0, false, isPlayer);
		animation.add("dead", [1], 0, false, isPlayer);
		animation.add("winning", [2], 0, false, isPlayer);

		animation.play("default");
	}
}