package menus;

import flixel.math.FlxMath;
import lime.app.Application;
import flixel.system.FlxSound;
import lime.utils.Assets;
import mods.Mods;
import flixel.text.FlxText;
import ui.Icon;
import ui.AlphabetText;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.FlxSprite;

using StringTools;

class FreeplayMenuState extends BasicState
{
    private var songs:Array<SongMetadata> = [];

    private var selectedSong:Int = 0;
    private var selectedDifIndex:Int = 1;

    private var bg:FlxSprite;

    private var colorTween:FlxTween;
    private var selectedColor:Int = 0xFF7F1833;

    private var songAlphabets:FlxTypedGroup<AlphabetText> = new FlxTypedGroup<AlphabetText>();
    private var songIcons:FlxTypedGroup<Icon> = new FlxTypedGroup<Icon>();

    private var selectedDifficulty:String = "normal";

    private var box:FlxSprite;

    private var scoreText:FlxText;
    private var difText:FlxText;
    private var speedText:FlxText;

    public static var curSpeed:Float = 1;

    private var vocals:FlxSound = new FlxSound();
    
    public function new()
    {
        super();

        curSpeed = 1;
        var rawSongListData:FreeplayList = Util.getJsonContents(Util.getJsonPath("data/freeplaySongs"));
        var songListData:Array<FreeplaySong> = rawSongListData.songs;

        #if sys
        Mods.updateActiveMods();
        
        if(Mods.activeMods.length > 0)
        {
            for(mod in Mods.activeMods)
            {
                if(sys.FileSystem.exists(Sys.getCwd() + 'mods/$mod/data/freeplaySongs.json'))
                {
                    var coolData:FreeplayList = Util.getJsonContents('mods/$mod/data/freeplaySongs.json');

                    for(song in coolData.songs)
                    {
                        songListData.push(song);
                    }
                }
            }
        }
        #end

        for(songData in songListData)
        {
            // Variables I like yes mmmm tasty
            var icon = songData.icon;
            var song = songData.name;
            
            var defDiffs = ["Easy", "Normal", "Hard"];

            var diffs:Array<String>;

            if(songData.difficulties == null)
                diffs = defDiffs;
            else
                diffs = songData.difficulties;

            var color = songData.bgColor;
            var actualColor:Null<FlxColor> = null;

            if(color != null)
                actualColor = FlxColor.fromString(color);

            // Creates new song data accordingly
            songs.push(new SongMetadata(song, icon, diffs, actualColor));
        }

        bg = new FlxSprite().loadGraphic(Util.getImage("menuDesat"));
		
		add(bg);
 
        box = new FlxSprite();
        box.makeGraphic(1,1,FlxColor.BLACK);
        box.alpha = 0.6;
        add(box);

        scoreText = new FlxText(0,0,0,"PERSONAL BEST: 0", 32);
        scoreText.setFormat("assets/fonts/vcr.ttf", 32, FlxColor.WHITE, RIGHT);
        add(scoreText);

        difText = new FlxText(0, scoreText.y + scoreText.height + 2, 0, "< Normal >", 24);
		difText.font = scoreText.font;
		difText.alignment = RIGHT;
		add(difText);

        speedText = new FlxText(0, difText.y + difText.height + 2, 0, "1", 24);
		speedText.font = scoreText.font;
		speedText.alignment = RIGHT;
		add(speedText);

        selectedColor = songs[selectedSong].color;
        bg.color = selectedColor;

        add(songAlphabets);
        add(songIcons);

        for(songDataIndex in 0...songs.length)
        {
            var songData = songs[songDataIndex];

            var alphabet = new AlphabetText(0, 0, songData.songName);
            alphabet.targetY = songDataIndex;
            alphabet.isMenuItem = true;

            songAlphabets.add(alphabet);

            var icon = new Icon(Util.getCharacterIcons(songData.songCharacter), alphabet);
            songIcons.add(icon);
        }

        updateSelection();

        BasicState.changeAppTitle(Util.engineName, "Freeplay Menu");
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);

        if(FlxG.keys.justPressed.BACKSPACE)
            FlxG.switchState(new menus.MainMenuState());

        if(FlxG.keys.justPressed.SPACE) {
            if (FlxG.sound.music != null) {
                FlxG.sound.music.stop();
            }

            if (vocals != null) {
                vocals.stop();
            }

            #if sys
            if(!Assets.exists(Util.getInst(songs[selectedSong].songName.toLowerCase())))
                FlxG.sound.music = Util.loadModSound("songs/" + songs[selectedSong].songName.toLowerCase() + "/Inst", true, true);
            else
            #end
            FlxG.sound.playMusic(Util.getInst(songs[selectedSong].songName.toLowerCase()), 1, false);

            /*if(song.needsVoices)
            {*/
                FlxG.sound.music.pause();

                #if sys
                if(!Assets.exists(Util.getVoices(songs[selectedSong].songName.toLowerCase())))
                    vocals = Util.loadModSound("songs/" + songs[selectedSong].songName.toLowerCase() + "/Voices", true, false);
                else
                #end
                vocals = FlxG.sound.play(Util.getVoices(songs[selectedSong].songName.toLowerCase()));

                vocals.pause();

                FlxG.sound.music.time = 0;
                vocals.time = 0;

                FlxG.sound.music.play();
                vocals.play();
            /*}
            else 
                vocals = new FlxSound();*/

            FlxG.sound.list.add(vocals);

            refreshSpeed();
        }

        var up = FlxG.keys.justPressed.UP;
        var down = FlxG.keys.justPressed.DOWN;
        var left = FlxG.keys.justPressed.LEFT;
        var right = FlxG.keys.justPressed.RIGHT;
        var shiftP = FlxG.keys.pressed.SHIFT;
        var reset = FlxG.keys.justPressed.R;

        if(up || down)
        {
            if(up)
                selectedSong -= 1;
    
            if(down)
                selectedSong += 1;
            
            updateSelection();
        }

        if(left && !shiftP || right && !shiftP)
        {
            if(left)
                selectedDifIndex -= 1;

            if(right)
                selectedDifIndex += 1;

            updateSelection();
        }

        if(left && shiftP || right && shiftP)
        {
            var daMultiplier:Float = 0.05;

            if(left)
                changeSpeed(daMultiplier * -1);

            if(right)
                changeSpeed(daMultiplier);

            refreshSpeed();
        }

        if(reset && shiftP)
            curSpeed = 1;

        if(FlxG.keys.justPressed.ENTER)
        {
            game.PlayState.songMultiplier = curSpeed;
            FlxG.switchState(new game.PlayState(songs[selectedSong].songName.toLowerCase(), selectedDifficulty, false));
        }

        var funnyObject:FlxText = scoreText;

		if(speedText.width >= scoreText.width)
			funnyObject = speedText;

		if(difText.width >= scoreText.width)
			funnyObject = difText;

		box.x = funnyObject.x - 6;

		if(Std.int(box.width) != Std.int(funnyObject.width + 6))
			box.makeGraphic(Std.int(funnyObject.width + 6), 90, FlxColor.BLACK);

		scoreText.x = FlxG.width - scoreText.width;
		scoreText.text = "PERSONAL BEST:" + "0" /*lerpScore*/;

		difText.x = FlxG.width - difText.width;

		speedText.x = FlxG.width - speedText.width;
		speedText.text = "Speed: " + FlxMath.roundDecimal(curSpeed, 2) + " (SHIFT+R)";
    }

    function updateSelection()
    {
        if(selectedSong < 0)
            selectedSong = songs.length - 1;

        if(selectedSong > songs.length - 1)
            selectedSong = 0;

        if(selectedDifIndex > songs[selectedSong].difficulties.length - 1)
            selectedDifIndex = 0;

        if(selectedDifIndex < 0)
            selectedDifIndex = songs[selectedSong].difficulties.length - 1;

        selectedDifficulty = songs[selectedSong].difficulties[selectedDifIndex];

        difText.text = "< " + songs[selectedSong].difficulties[selectedDifIndex] + " >";

        var newColor:FlxColor = songs[selectedSong].color;

        if(newColor != selectedColor) {
            if(colorTween != null) {
                colorTween.cancel();
            }

            selectedColor = newColor;

            colorTween = FlxTween.color(bg, 0.4, bg.color, selectedColor, {
                onComplete: function(twn:FlxTween) {
                    colorTween = null;
                }
            });
        }

        if(songIcons.members.length > 0)
        {
            for (i in 0...songIcons.members.length)
            {
                songIcons.members[i].alpha = 0.6;
            }
    
            songIcons.members[selectedSong].alpha = 1;
        }

        for(itemIndex in 0...songAlphabets.members.length)
        {
            var item = songAlphabets.members[itemIndex];

            item.targetY = itemIndex - selectedSong;

            item.alpha = 0.6;

            if (item.targetY == 0)
                item.alpha = 1;
        }

        FlxG.sound.play(Util.getSound('menus/scrollMenu'));
    }

    function changeSpeed(?change:Float = 0)
    {
        curSpeed += change;

        if(curSpeed < 0.1)
            curSpeed = 0.1;
    }

    function refreshSpeed()
    {
        #if cpp
        @:privateAccess
        {
            if(FlxG.sound.music.active && FlxG.sound.music.playing)
                lime.media.openal.AL.sourcef(FlxG.sound.music._channel.__source.__backend.handle, lime.media.openal.AL.PITCH, curSpeed);

            if (vocals.active && vocals.playing)
                lime.media.openal.AL.sourcef(vocals._channel.__source.__backend.handle, lime.media.openal.AL.PITCH, curSpeed);
        }
        #end
    }
}

class SongMetadata
{
    public static var coolColors:Array<Int> = [0xFF7F1833, 0xFF7C689E, -14535868, 0xFFA8E060, 0xFFFF87FF, 0xFF8EE8FF, 0xFFFF8CCD, 0xFFFF9900];

	public var songName:String = "";
	public var songCharacter:String = "";
	public var difficulties:Array<String> = ["easy", "normal", "hard"];
	public var color:FlxColor = FlxColor.GREEN;

	public function new(song:String, songCharacter:String, ?difficulties:Array<String>, ?color:FlxColor)
	{
		this.songName = song;
		this.songCharacter = songCharacter;

		if(difficulties != null)
			this.difficulties = difficulties;

		if(color != null)
			this.color = color;
		else
            this.color = coolColors[0];
	}
}

typedef FreeplayList =
{
    var songs:Array<FreeplaySong>;
}

typedef FreeplaySong =
{
    var name:String;
    var icon:String;
    var bgColor:Null<String>;
    var difficulties:Null<Array<String>>;
}