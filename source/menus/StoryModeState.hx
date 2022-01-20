package menus;

import lime.app.Application;
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
import flixel.addons.transition.FlxTransitionableState;

using StringTools;

class StoryModeState extends BasicState {
    var yellowBG:FlxSprite;
    var scoreText:FlxText;
    var weekQuote:FlxText;
    var debugText:FlxText;
    var cover:FlxSprite;
    var weekChars:FlxTypedGroup<StoryModeCharacter>;
    var selectedWeek:Int = 0;
    var doFunnyQuote:Bool = false;

    var tracksText:FlxText;

    var funnyWeeks:FlxTypedGroup<FlxSprite>;
    var grpDifficulty:FlxTypedGroup<FlxSprite>;

    #if sys
    var jsonDirs = sys.FileSystem.readDirectory(Sys.getCwd() + "assets/weeks/");
    #else
    var jsonDirs:Array<String> = ["tutorial.json", "week1.json", "week2.json", "week3.json", "week4.json", "week5.json", "week6.json"];
    #end

    var jsons:Array<String> = [];
    var weekQuotes:Array<String> = [];
    var swagSongs:Array<Dynamic> = [];
    var swagChars:Array<Dynamic> = [];

    // difficulty shit
    var swagDifficulties:Array<Dynamic> = [];
    var difficulties:Array<String> = ["Easy", "Normal", "Hard"];
    var selectedDifficulty:Int = 1;

    var camFollow:FlxObject;
	var camFollowPos:FlxObject;

    var tutorialData:Dynamic;

    override public function create()
    {
        if(FlxG.random.bool(75))
            doFunnyQuote = true;

        tutorialData = Util.getJsonContents(Util.getJsonPath('weeks/tutorial'));

		camFollow = new FlxObject(0, 0, 1, 1);
		add(camFollow);

        // week shit
        funnyWeeks = new FlxTypedGroup<FlxSprite>();
        add(funnyWeeks);

        grpDifficulty = new FlxTypedGroup<FlxSprite>();
        add(grpDifficulty);

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

            if(doFunnyQuote)
                weekQuotes.push(data.weekQuote);
            else
                weekQuotes.push(data.funnyWeekQuote);

            var realWeek:FlxSprite = new FlxSprite(0, 600 + json_i * 125).loadGraphic(Util.getImage('weeks/images/' + data.fileName, false));
            realWeek.screenCenter(X);
            realWeek.ID = json_i;
            funnyWeeks.add(realWeek);
        
            //trace('Week Data Output: ' + data);
            swagSongs.push(data.songs);
            swagChars.push(data.characters);
            swagDifficulties.push(data.difficulties);

            json_i++;
        }

        trace("Songs:\n" + swagSongs + "\n\nCharacters:\n" + swagChars + "\n\nDifficulties:\n" + swagDifficulties);

        // this shit gets added last for ordering reasons :D
        cover = new FlxSprite(0, 0).makeGraphic(FlxG.width, 200, FlxColor.BLACK);
        cover.scrollFactor.set();
        add(cover);

        scoreText = new FlxText(8, 8, 0, "PERSONAL BEST: N/A", 32);
        scoreText.setFormat("assets/fonts/vcr.ttf", 32, FlxColor.WHITE, LEFT);
        scoreText.scrollFactor.set();
        add(scoreText);

        weekQuote = new FlxText(FlxG.width * 0.7, 8, 0, "", 32);
        weekQuote.setFormat("assets/fonts/vcr.ttf", 32, FlxColor.WHITE, RIGHT);
        weekQuote.alpha = 0.7;
        weekQuote.scrollFactor.set();
        add(weekQuote);

        yellowBG = new FlxSprite(0, 50).makeGraphic(FlxG.width, 400, 0xFFF9CF51);
        yellowBG.scrollFactor.set();
        add(yellowBG);

        weekChars = new FlxTypedGroup<StoryModeCharacter>();
        add(weekChars);

        var char:StoryModeCharacter = new StoryModeCharacter(0, 0, swagChars[selectedWeek][0], false);
        char.scrollFactor.set();
        weekChars.add(char);

        var char:StoryModeCharacter = new StoryModeCharacter(0, 0, swagChars[selectedWeek][1], true);
        char.scrollFactor.set();
        weekChars.add(char);

        var char:StoryModeCharacter = new StoryModeCharacter(0, 0, swagChars[selectedWeek][2], true);
        char.scrollFactor.set();
        weekChars.add(char);

        tracksText = new FlxText(0, yellowBG.y + (yellowBG.height + 30), 0, "TRACKS:\nplaceholder\na\npiss\n");
        tracksText.screenCenter(X);
        tracksText.setFormat("assets/fonts/vcr.ttf", 32, 0xFFBD4A90, CENTER);
        tracksText.x -= 500;
        tracksText.scrollFactor.set();
        add(tracksText);

        // difficulty shit
        var leftDiffArrow = new FlxSprite(FlxG.width * 0.68, yellowBG.y + (yellowBG.height + 30));
        leftDiffArrow.frames = Util.getSparrow('StoryMode_UI_Assets');
        leftDiffArrow.animation.addByPrefix("static", "arrow left0", 24, false);
        leftDiffArrow.animation.addByPrefix("push", "arrow push left0", 24, false);
        leftDiffArrow.animation.play("static");
        leftDiffArrow.scrollFactor.set();
        leftDiffArrow.antialiasing = Options.getData('anti-aliasing');
        grpDifficulty.add(leftDiffArrow);

        var rightDiffArrow = new FlxSprite(FlxG.width * 0.95, leftDiffArrow.y);
        rightDiffArrow.frames = Util.getSparrow('StoryMode_UI_Assets');
        rightDiffArrow.animation.addByPrefix("static", "arrow right0", 24, false);
        rightDiffArrow.animation.addByPrefix("push", "arrow push right0", 24, false);
        rightDiffArrow.animation.play("static");
        rightDiffArrow.scrollFactor.set();
        rightDiffArrow.antialiasing = Options.getData('anti-aliasing');
        grpDifficulty.add(rightDiffArrow);

        var difficultyImage = new FlxSprite(0, leftDiffArrow.y).loadGraphic(Util.getImage('weeks/difficulties/' + difficulties[selectedDifficulty].toLowerCase(), false));
        difficultyImage.scrollFactor.set();
        difficultyImage.antialiasing = Options.getData('anti-aliasing');
        grpDifficulty.add(difficultyImage);

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
        debugText.visible = false;
        add(debugText);

        changeSelectedWeek();
        changeDifficulty();

        BasicState.changeAppTitle(Util.engineName, "Story Mode Menu");
        
        super.create();

        #if discord_rpc
        DiscordRPC.changePresence("In Story Mode", null);
        #end
    }

    var daRawSongs:Dynamic;

    var trackList:String;
    var tracksArray:Array<Dynamic>;

    override public function update(elapsed:Float)
    {
        super.update(elapsed);

        var up = Controls.UI_UP;
        var down = Controls.UI_DOWN;
        var left = Controls.UI_LEFT;
        var leftP = Controls.UI_LEFT_P;
        var right = Controls.UI_RIGHT;
        var rightP = Controls.UI_RIGHT_P;
        var accept = Controls.accept;

		var lerpVal:Float = Util.boundTo(elapsed * 5.6, 0, 1);
		camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));

        if(Controls.back)
        {
            FlxG.sound.play(Util.getSound("menus/cancelMenu", true));
			transIn = FlxTransitionableState.defaultTransIn;
			transOut = FlxTransitionableState.defaultTransOut;

            FlxTransitionableState.skipNextTransIn = false;
            FlxTransitionableState.skipNextTransOut = false;
            transitionState(new MainMenuState());
        }

        if(accept)
        {
            game.PlayState.storyPlaylist = [];
    
            for(i in 0...swagSongs[selectedWeek].length)
            {
                trace(swagSongs[selectedWeek][i].toLowerCase());
                game.PlayState.storyPlaylist.push(swagSongs[selectedWeek][i].toLowerCase());
            }

            trace(swagSongs[selectedWeek][0].toLowerCase());
            trace(difficulties[selectedDifficulty].toLowerCase());
            transitionState(new game.PlayState(swagSongs[selectedWeek][0].toLowerCase(), difficulties[selectedDifficulty].toLowerCase(), true));

            game.PlayState.songMultiplier = 1;
        }

        if(up) changeSelectedWeek(-1);
        if(down) changeSelectedWeek(1);
        
        if(left) {
            changeDifficulty(-1);
            
            grpDifficulty.members[2].y = grpDifficulty.members[0].y - 10;
            grpDifficulty.members[2].alpha = 0;
        }
        if(right) {
            changeDifficulty(1);

            grpDifficulty.members[2].y = grpDifficulty.members[0].y - 10;
            grpDifficulty.members[2].alpha = 0;
        }

        scoreText.text = "PERSONAL BEST: " + "0";

        for(i in 0...weekChars.members.length)
        {
            weekChars.members[i].x = (FlxG.width * 0.25) * (1 + i) - 150;
            weekChars.members[i].y = yellowBG.y + 20;
        }

        for(i in 0...funnyWeeks.members.length)
        {
            funnyWeeks.members[i].screenCenter(X);
        }

        debugText.text = selectedWeek+"";

        weekQuote.text = weekQuotes[selectedWeek].toUpperCase();
		weekQuote.x = FlxG.width - (weekQuote.width + 10);

        trackList = "";

        for(i in 0...swagSongs[selectedWeek].length)
        {
            trackList += swagSongs[selectedWeek][i]+'\n';
        }

        tracksText.text = "TRACKS:\n" + trackList;

        tracksText.screenCenter(X);
        tracksText.setFormat("assets/fonts/vcr.ttf", 32, 0xFFBD4A90, CENTER);
        tracksText.x -= 400;

        for(i in 0...grpDifficulty.members.length)
        {
            switch(i)
            {
                case 0:
                    if(leftP)
                        grpDifficulty.members[i].animation.play("push");
                    else
                        grpDifficulty.members[i].animation.play("static");
                case 1:
                    if(rightP)
                        grpDifficulty.members[i].animation.play("push");
                    else
                        grpDifficulty.members[i].animation.play("static");
                case 2:
                    grpDifficulty.members[i].screenCenter(X);
                    grpDifficulty.members[i].x += FlxG.width * 0.335;
                    grpDifficulty.members[i].scale.set(0.9, 0.9);
                    grpDifficulty.members[i].y = FlxMath.lerp(grpDifficulty.members[i].y, grpDifficulty.members[0].y, Math.max(0, Math.min(1, elapsed * 10)));
                    grpDifficulty.members[i].alpha = FlxMath.lerp(grpDifficulty.members[i].alpha, 1, Math.max(0, Math.min(1, elapsed * 10)));
            }
        }
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

        if(swagDifficulties[selectedWeek][selectedDifficulty] != difficulties[selectedDifficulty])
        {
            difficulties = swagDifficulties[selectedWeek];

            if(difficulties.length == 1)
                selectedDifficulty = 0;
            else
                selectedDifficulty = 1;
        }

        changeDifficulty();

        for(i in 0...weekChars.members.length)
        {
            var the:Dynamic = swagChars[selectedWeek][i];
            if(the == null)
                the = "";

            if(weekChars.members[i].name != the)
                weekChars.members[i].changeChar(the, true);
        }

        FlxG.sound.play(Util.getSound('menus/scrollMenu'));

        camFollow.setPosition(funnyWeeks.members[selectedWeek].getGraphicMidpoint().x, funnyWeeks.members[selectedWeek].getGraphicMidpoint().y - 160);
    }

    function changeDifficulty(?change:Int = 0)
    {
        selectedDifficulty += change;

        if(selectedDifficulty < 0)
            selectedDifficulty = difficulties.length - 1;

        if(selectedDifficulty > difficulties.length - 1)
            selectedDifficulty = 0;

        trace("Difficulty Selected: " + difficulties[selectedDifficulty].toLowerCase());

        grpDifficulty.members[2].loadGraphic(Util.getImage('weeks/difficulties/' + difficulties[selectedDifficulty].toLowerCase(), false));
    }
}