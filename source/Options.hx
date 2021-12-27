package;

import flixel.FlxG;

class Options
{
    public static var downscroll:Bool = false;
    public static var botplay:Bool = false;

    public static var songOffset:Int = 0;

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

    public static var mainBinds:Array<String> = ["LEFT", "DOWN", "UP", "RIGHT"];
    public static var altBinds:Array<String> = ["A", "S", "W", "D"];

    public static function init()
    {
        FlxG.save.bind("project-refunked", "project-refunked-team");

        if(FlxG.save.data.graphicsSettings == null)
            FlxG.save.data.graphicsSettings = graphicsSettings;

        if(FlxG.save.data.gameplaySettings == null)
            FlxG.save.data.gameplaySettings = gameplaySettings;

        if(FlxG.save.data.downscroll == null)
            FlxG.save.data.downscroll = downscroll;

        if(FlxG.save.data.botplay == null)
            FlxG.save.data.botplay = botplay;

        if(FlxG.save.data.songOffset == null)
            FlxG.save.data.songOffset = songOffset;

        if(FlxG.save.data.mainBinds == null)
            FlxG.save.data.mainBinds = mainBinds;

        if(FlxG.save.data.altBinds == null)
            FlxG.save.data.altBinds = altBinds;

        loadSettings();

        FlxG.save.flush();
    }

    public static function loadSettings()
    {
        graphicsSettings = FlxG.save.data.graphicsSettings;
        gameplaySettings = FlxG.save.data.gameplaySettings;
        mainBinds = FlxG.save.data.mainBinds;
        altBinds = FlxG.save.data.altBinds;
        songOffset = FlxG.save.data.songOffset;
        botplay = FlxG.save.data.botplay;
        downscroll = FlxG.save.data.downscroll;
    }

    public static function saveSettings()
    {
        FlxG.save.data.graphicsSettings = graphicsSettings;
        FlxG.save.data.gameplaySettings = gameplaySettings;
        FlxG.save.data.mainBinds = mainBinds;
        FlxG.save.data.altBinds = altBinds;
        FlxG.save.data.songOffset = songOffset;
        FlxG.save.data.botplay = botplay;
        FlxG.save.data.downscroll = downscroll;
        FlxG.save.flush();
    }
}