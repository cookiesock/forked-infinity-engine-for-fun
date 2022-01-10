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

        #if sys
        if(Assets.exists('assets/characters/$name.json'))
        #end
            json = Util.getJsonContents('assets/characters/$name.json');
        #if sys
        else
        {
            if(Mods.activeMods.length > 0)
            {
                for(mod in Mods.activeMods)
                {
                    if(sys.FileSystem.exists(Sys.getCwd() + 'mods/$mod/characters/$name.json'))
                    {
                        json = Util.getJsonContents('mods/$mod/characters/$name.json');
                    }
                }
            }
        }
        #end

		if(iconPath.contains('-pixel'))
			antialiasing = false;
		else
			antialiasing = Options.getData('anti-aliasing');

		loadGraphic(Util.getImage(iconPath, false), true, 150, 150);

		animation.add("default", [0], 0, false, isPlayer);
		animation.add("dead", [1], 0, false, isPlayer);
		animation.add("winning", [2], 0, false, isPlayer);

		animation.play("default");
	}
}