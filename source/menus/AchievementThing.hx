package menus;

import flixel.FlxG;
import ui.AchievementIcon;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import mods.Mods;
import menus.AchievementMenu;
import flixel.FlxSprite;

class AchievementThing extends BasicSubState
{
    var dumbTimer:Float = 0.0;

    var achievementsGotten:Array<String>;

    public function new(ag:Array<String>)
    {
        achievementsGotten = ag;

        super();

        var rawSongListData:AchievementList = Util.getJsonContents(Util.getJsonPath("data/achievementList"));
        var achievementListData:Array<Achievement> = rawSongListData.achievements;

        #if sys
        Mods.updateActiveMods();
        
        if(Mods.activeMods.length > 0)
        {
            for(mod in Mods.activeMods)
            {
                if(sys.FileSystem.exists(Sys.getCwd() + 'mods/$mod/data/achievementList.json'))
                {
                    var coolData:AchievementList = Util.getJsonContents('mods/$mod/data/achievementList.json');

                    for(achievement in coolData.achievements)
                    {
                        achievementListData.push(achievement);
                    }
                }
            }
        }
        #end

        for(achievementIndex in 0...achievementsGotten.length)
        {
            var achievement = achievementsGotten[achievementIndex];

            var box:FlxSprite = new FlxSprite(15, 15 + (80 * achievementIndex));
            box.scrollFactor.set();
            box.alpha = 0.6;
            add(box);

            var name:FlxText = new FlxText(20, 20 + (80 * achievementIndex), 0, "test\nlolz", 32);
            name.font = "assets/fonts/vcr.ttf";
            name.color = FlxColor.WHITE;
            name.borderColor = FlxColor.BLACK;
            name.borderSize = 1.5;
            name.borderStyle = OUTLINE;
            name.alignment = LEFT;
            name.scrollFactor.set();
            add(name);

            var achievementData:Achievement = achievementListData[0];

            for(achievementFun in achievementListData)
            {
                if(achievementFun.file_name == achievement)
                {
                    achievementData = achievementFun;
                    break;
                }
            }

            var icon = new AchievementIcon("achievements/images/" + achievementData.file_name + "-achievement", null, null, null, LEFT);
            icon.x = 20;
            icon.y = 20 + (80 * achievementIndex);
            icon.scrollFactor.set();

            name.x = icon.x + icon.width + 2;
            name.y = icon.y;
            name.text = achievementData.name + "\n" + achievementData.description + "\n";

            box.makeGraphic(Std.int((name.x - 15) + name.width + 10), 170, FlxColor.GRAY);

            add(icon);
        }

        cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
    }

    override function update(elapsed:Float) {
        super.update(elapsed);

        dumbTimer += elapsed;

        if(dumbTimer > 5 || achievementsGotten.length < 1)
            close();
    }
}