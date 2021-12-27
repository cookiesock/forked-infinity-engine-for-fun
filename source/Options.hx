package;

import flixel.FlxG;

class Options
{
    /*public static var DOWNSCROLL:Bool = false;
    public static var BOTPLAY:Bool = false;

    public static var SONG_OFFSET:Int = 0;*/

    public static var graphicsSettings:Array<Dynamic> = [
        true, // toggle background
        false, // low quality
        true, // anti-aliasing
        false, // remove chars, 0 - just gf, 1 - everyone
    ];

    public static var gameplaySettings:Array<Dynamic> = [
        false, // downscroll
        false, // middlescroll
        false, // botplay
        0, // hitsound, max is 2
        0, // song offset
    ];

    public static var MAIN_BINDS:Array<String> = ["LEFT", "DOWN", "UP", "RIGHT"];
    public static var ALT_BINDS:Array<String> = ["A", "S", "W", "D"];

    public static function init()
    {
        FlxG.save.bind("project-refunked", "project-refunked-team");

        if(FlxG.save.data.graphicsSettings == null)
            FlxG.save.data.graphicsSettings = graphicsSettings;

        if(FlxG.save.data.gameplaySettings == null)
            FlxG.save.data.gameplaySettings = gameplaySettings;

        if(FlxG.save.data.mainBinds == null)
            FlxG.save.data.mainBinds = ["LEFT", "DOWN", "UP", "RIGHT"];

        if(FlxG.save.data.altBinds == null)
            FlxG.save.data.altBinds = ["A", "S", "W", "D"];

        loadSettings();

        FlxG.save.flush();
    }

    public static function loadSettings()
    {
        graphicsSettings = FlxG.save.data.graphicsSettings;
        gameplaySettings = FlxG.save.data.gameplaySettings;
        MAIN_BINDS = FlxG.save.data.mainBinds;
        ALT_BINDS = FlxG.save.data.altBinds;
    }

    public static function saveSettings()
    {
        FlxG.save.data.graphicsSettings = graphicsSettings;
        FlxG.save.data.gameplaySettings = gameplaySettings;
        FlxG.save.data.mainBinds = MAIN_BINDS;
        FlxG.save.data.altBinds = ALT_BINDS;
    }
}