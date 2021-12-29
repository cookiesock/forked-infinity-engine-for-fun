package;

import flixel.FlxG;

class Options
{
    public static var downscroll:Bool = false;
    public static var botplay:Bool = false;

    public static var ghostTapping:Bool = true;

    public static var songOffset:Int = 0;
    public static var scrollSpeed:Float = 1;

    public static var noteSkin:String = 'default';

    public static var graphicsSettings:Array<Dynamic> = [
        true, // toggle background
        false, // low quality
        true, // anti-aliasing
        false, // remove chars, 0 - just gf, 1 - everyone
    ];

    public static var altBinds:Array<String> = ["LEFT", "DOWN", "UP", "RIGHT"];
    public static var mainBinds:Array<String> = ["A", "S", "W", "D"];

    public static function init()
    {
        FlxG.save.bind("project-refunked", "project-refunked-team");

        if(FlxG.save.data.graphicsSettings == null)
            FlxG.save.data.graphicsSettings = graphicsSettings;

        if(FlxG.save.data.downscroll == null)
            FlxG.save.data.downscroll = downscroll;

        if(FlxG.save.data.botplay == null)
            FlxG.save.data.botplay = botplay;

        if(FlxG.save.data.songOffset == null)
            FlxG.save.data.songOffset = songOffset;

        if(FlxG.save.data.scrollSpeed == null)
            FlxG.save.data.scrollSpeed = scrollSpeed;

        if(FlxG.save.data.ghostTapping == null)
            FlxG.save.data.ghostTapping = ghostTapping;

        if(FlxG.save.data.mainBinds == null)
            FlxG.save.data.mainBinds = mainBinds;

        /*
        if(FlxG.save.data.altBinds == null)
            FlxG.save.data.altBinds = altBinds;*/

        loadSettings();

        FlxG.save.flush();
    }

    public static function loadSettings()
    {
        graphicsSettings = FlxG.save.data.graphicsSettings;
        mainBinds = FlxG.save.data.mainBinds;
        //altBinds = FlxG.save.data.altBinds;
        songOffset = FlxG.save.data.songOffset;
        scrollSpeed = FlxG.save.data.scrollSpeed;
        botplay = FlxG.save.data.botplay;
        downscroll = FlxG.save.data.downscroll;
        noteSkin = FlxG.save.data.noteskin;
        ghostTapping = FlxG.save.data.ghostTapping;

		if(FlxG.save.data.volume != null) {
			FlxG.sound.volume = FlxG.save.data.volume;
		}
    }

    public static function saveSettings()
    {
        FlxG.save.data.graphicsSettings = graphicsSettings;
        FlxG.save.data.mainBinds = mainBinds;
        //FlxG.save.data.altBinds = altBinds;
        FlxG.save.data.songOffset = songOffset;
        FlxG.save.data.scrollSpeed = scrollSpeed;
        FlxG.save.data.botplay = botplay;
        FlxG.save.data.downscroll = downscroll;
        FlxG.save.data.noteskin = noteSkin;
        FlxG.save.data.ghostTapping = ghostTapping;
        
        FlxG.save.flush();
    }
}