package;

import flixel.FlxG;

class Options
{
    public static var DOWNSCROLL:Bool = false;
    public static var BOTPLAY:Bool = false;

    public static var SONG_OFFSET:Int = 0;

    public static var MAIN_BINDS:Array<String> = ["LEFT", "DOWN", "UP", "RIGHT"];
    public static var ALT_BINDS:Array<String> = ["A", "S", "W", "D"];

    public static function init()
    {
        FlxG.save.bind("project-refunked", "project-refunked-team");

        if(FlxG.save.data.downscroll == null)
            FlxG.save.data.downscroll = false;

        if(FlxG.save.data.botplay == null)
            FlxG.save.data.botplay = false;

        if(FlxG.save.data.songOffset == null)
            FlxG.save.data.songOffset = 0;

        if(FlxG.save.data.mainBinds == null)
            FlxG.save.data.mainBinds = ["LEFT", "DOWN", "UP", "RIGHT"];

        if(FlxG.save.data.altBinds == null)
            FlxG.save.data.altBinds = ["A", "S", "W", "D"];

        bindPropertiesToSaveData();

        FlxG.save.flush();
    }

    public static function bindPropertiesToSaveData()
    {
        DOWNSCROLL = FlxG.save.data.downscroll;
        BOTPLAY = FlxG.save.data.botplay;
        SONG_OFFSET = FlxG.save.data.songOffset;
        MAIN_BINDS = FlxG.save.data.mainBinds;
        ALT_BINDS = FlxG.save.data.altBinds;
    }
}