package;

import flixel.FlxG;

class Replays
{
    public static var funnyReplays:Array<Dynamic> = [];

    public static function init()
    {
        if(FlxG.save.data.replays != null)
            funnyReplays = FlxG.save.data.replays;
    }

    public static function saveReplays(?value:Dynamic = null)
    {
        Reflect.setProperty(FlxG.save.data, 'replays', value);
        FlxG.save.flush();
    }

    public static function getReplays():Dynamic
    {
        return Reflect.getProperty(FlxG.save.data, 'replays');
    }
}