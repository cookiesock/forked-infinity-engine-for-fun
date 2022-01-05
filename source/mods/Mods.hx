package mods;

using StringTools;

class Mods
{
    public static var mods:Array<Array<Dynamic>> = [];

    public static var activeMods:Array<String> = [];

    public static function init()
    {
        // loads funny mods from save data
        mods = [];

        mods = Options.getData("mods");

        trace(mods);

        updateActiveMods();

        getAllMods();

        saveData();
    }

    public static function getAllMods()
    {
        #if sys
        var modDirStuffs = sys.FileSystem.readDirectory(Sys.getCwd() + "mods/");

        trace(modDirStuffs);

        if(modDirStuffs != null)
        {
            for(modDir in modDirStuffs)
            {
                if(sys.FileSystem.isDirectory(Sys.getCwd() + 'mods/$modDir'))
                {
                    var baseModPath = Sys.getCwd() + 'mods/$modDir/';

                    trace(modDir + " is a valid directory!");

                    if(sys.FileSystem.exists(baseModPath + "_mod_info.json"))
                    {
                        trace(modDir + " is a valid mod!");

                        if(sys.FileSystem.exists(baseModPath + "_mod_icon.png"))
                            trace(modDir + " has a valid mod icon!");

                        var canPush:Bool = true;

                        for(mod in mods)
                        {
                            if(mod[0] == modDir && canPush)
                                canPush = false;
                            else if(mod[0] == modDir && !canPush)
                                mods.remove(mod);
                        }

                        if(canPush)
                            mods.push([modDir, false]);
                    }
                }
            }
        }
        #end

        updateActiveMods();
        saveData();
    }

    public static function saveData()
    {
        Options.saveData("mods", mods);
    }

    public static function updateActiveMods()
    {
        activeMods = [];

        for(mod in mods)
        {
            if(mod[1] == true)
                activeMods.push(mod[0]);
        }
    }

    public static function setModActive(modName:String, ?active:Bool = true)
    {
        for(mod in mods)
        {
            if(mod[0] == modName)
                mod[1] = active;
        }

        updateActiveMods();
        saveData();
    }

    public static function getModActive(modName:String):Bool
    {
        for(mod in mods)
        {
            if(mod[0] == modName)
                return mod[1];
        }

        return false;
    }
}

typedef ModInfo = 
{
    var name:String;
    var description:String;
    var author:String;
}
