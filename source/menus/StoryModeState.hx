package menus;

import lime.utils.Assets;
import mods.Mods;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.util.FlxTimer;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxObject;
import flixel.math.FlxMath;

using StringTools;

class StoryModeState extends BasicState {
    var yellowBG:FlxSprite;
    var scoreText:FlxText;
    var weekName:FlxText;
    var debugText:FlxText;
    var cover:FlxSprite;
    var weekChars:FlxTypedGroup<StoryModeCharacter>;
    var selectedWeek:Int = 0;

    var funnyWeeks:FlxTypedGroup<FlxSprite>;

    #if sys
    var jsonDirs = sys.FileSystem.readDirectory(Sys.getCwd() + "assets/weeks/");
    #else
    var jsonDirs:Array<String> = ["tutorial.json", "week1.json", "week2.json", "week3.json", "week4.json", "week5.json", "week6.json"];
    #end

    var jsons:Array<String> = [];

    var camFollow:FlxObject;
	var camFollowPos:FlxObject;

    var tutorialData:Dynamic;

    override public function create()
    {
        tutorialData = Util.getJsonContents(Util.getJsonPath('weeks/tutorial'));

		camFollow = new FlxObject(0, 0, 1, 1);
		add(camFollow);

        // week shit
        funnyWeeks = new FlxTypedGroup<FlxSprite>();
        add(funnyWeeks);

        #if sys
        if(Mods.activeMods.length > 0)
        {
            for(mod in Mods.activeMods)
            {
                if(sys.FileSystem.exists(Sys.getCwd() + 'mods/$mod/weeks/'))
                {
                    var funnyArray = sys.FileSystem.readDirectory(Sys.getCwd() + 'mods/$mod/weeks/');
                    
                    for(jsonThingy in funnyArray)
                    {
                        jsonDirs.push(jsonThingy);
                    }
                }
            }
        }
        #end

        for(dir in jsonDirs)
        {
            if(dir.endsWith(".json"))
                jsons.push(dir.split(".json")[0]);
        }

        var json_i:Int = 0;

        for(jsonName in jsons)
        {
            var data:Dynamic = tutorialData;

            #if sys
            if(Assets.exists(Util.getJsonPath('weeks/$jsonName')))
            #end
                data = Util.getJsonContents(Util.getJsonPath('weeks/$jsonName'));
            #if sys
            else
            {
                if(Mods.activeMods.length > 0)
                {
                    for(mod in Mods.activeMods)
                    {
                        if(sys.FileSystem.exists(Sys.getCwd() + 'mods/$mod/weeks/$jsonName.json'))
                        {
                            data = Util.getJsonContents('mods/$mod/weeks/$jsonName.json');
                        }
                    }
                }
            }
            #end

            var realWeek:FlxSprite = new FlxSprite(0, 600 + json_i * 125).loadGraphic(Util.getImage('weeks/images/' + data.fileName, false));
            realWeek.screenCenter(X);
            realWeek.ID = json_i;
            funnyWeeks.add(realWeek);
        
            trace('Week Data Output: ' + data);

            json_i++;
        }

        // this shit gets added last for ordering reasons :D
        cover = new FlxSprite(0, 0).makeGraphic(FlxG.width, 200, FlxColor.BLACK);
        cover.scrollFactor.set();
        add(cover);

        scoreText = new FlxText(8, 8, 0, "PERSONAL BEST: N/A", 32);
        scoreText.font = "assets/fonts/vcr.ttf";
        scoreText.color = FlxColor.WHITE;
        scoreText.scrollFactor.set();
        add(scoreText);

        yellowBG = new FlxSprite(0, 50).makeGraphic(FlxG.width, 400, 0xFFF9CF51);
        yellowBG.scrollFactor.set();
        add(yellowBG);

        weekChars = new FlxTypedGroup<StoryModeCharacter>();
        add(weekChars);

        var char:StoryModeCharacter = new StoryModeCharacter(0, 0, "dad", false);
        char.scrollFactor.set();
        weekChars.add(char);

        var char:StoryModeCharacter = new StoryModeCharacter(0, 0, "bf", true);
        char.scrollFactor.set();
        weekChars.add(char);

        var char:StoryModeCharacter = new StoryModeCharacter(0, 0, "gf", true);
        char.scrollFactor.set();
        weekChars.add(char);

        var tracksText = new FlxText(0, yellowBG.y + 50, 0, "TRACKS:");
        tracksText.screenCenter(X);
        tracksText.x -= FlxG.width - 200;
        add(tracksText);

        funkyBpm(102);

		camFollow = new FlxObject(funnyWeeks.members[selectedWeek].getGraphicMidpoint().x, funnyWeeks.members[selectedWeek].getGraphicMidpoint().y - 100, 1, 1);
		camFollowPos = new FlxObject(funnyWeeks.members[selectedWeek].getGraphicMidpoint().x, funnyWeeks.members[selectedWeek].getGraphicMidpoint().y - 100, 1, 1);
		add(camFollow);
		add(camFollowPos);
		
		FlxG.camera.follow(camFollowPos, null, 1);

        debugText = new FlxText(8, FlxG.height * 0.8, 0, "placeholder", 32);
        debugText.font = "assets/fonts/vcr.ttf";
        debugText.color = FlxColor.WHITE;
        debugText.scrollFactor.set();
        add(debugText);

        changeSelectedWeek();
        
        super.create();
    }

    override public function update(elapsed:Float)
    {
        var up = FlxG.keys.justPressed.UP;
        var down = FlxG.keys.justPressed.DOWN;
        var left = FlxG.keys.justPressed.LEFT;
        var right = FlxG.keys.justPressed.RIGHT;
        var accept = FlxG.keys.justPressed.ENTER;

		var lerpVal:Float = Util.boundTo(elapsed * 5.6, 0, 1);
		camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));

        if(FlxG.keys.justPressed.BACKSPACE)
        {
            transitionState(new MainMenuState());
        }

        if(up) changeSelectedWeek(-1);
        if(down) changeSelectedWeek(1);

        scoreText.text = "PERSONAL BEST: " + "0";

        for(i in 0...weekChars.members.length)
        {
            weekChars.members[i].x = 150 + i * 320;
            weekChars.members[i].y = yellowBG.y + 20;

            if(weekChars.members[i].isPlayer)
                weekChars.members[i].y += 20;
        }

        for(i in 0...funnyWeeks.members.length)
        {
            funnyWeeks.members[i].screenCenter(X);
        }

        debugText.text = selectedWeek+"";

        super.update(elapsed);
    }

    function changeSelectedWeek(?change:Int = 0)
    {
        selectedWeek += change;

        if(selectedWeek < 0)
            selectedWeek = jsons.length - 1;

        if(selectedWeek > jsons.length - 1)
            selectedWeek = 0;

        for(i in 0...funnyWeeks.members.length)
        {
            if(funnyWeeks.members[i].ID == selectedWeek)
                funnyWeeks.members[i].alpha = 1;
            else   
                funnyWeeks.members[i].alpha = 0.6;
        }

        camFollow.setPosition(funnyWeeks.members[selectedWeek].getGraphicMidpoint().x, funnyWeeks.members[selectedWeek].getGraphicMidpoint().y - 160);
    }
}