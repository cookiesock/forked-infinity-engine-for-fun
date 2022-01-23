package menus;

import ui.CustomDropdown;
import flixel.addons.ui.FlxUICheckBox;
import game.PlayState;
import lime.system.Clipboard;
import flixel.ui.FlxButton;
import flixel.addons.ui.FlxUIInputText;
import flixel.addons.ui.FlxUITabMenu;
import flixel.addons.ui.FlxUI;
import flixel.FlxObject;
import flixel.FlxCamera;
import flixel.addons.display.FlxGridOverlay;
import flixel.math.FlxMath;
import lime.app.Application;
import flixel.system.FlxSound;
import lime.utils.Assets;
import mods.Mods;
import flixel.text.FlxText;
import ui.Icon;
import flixel.group.FlxGroup;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import game.Character;
import game.Stage;

using StringTools;

class CharacterEditorMenu extends BasicState
{
    var curChar:String = "dad";
    var curAnim:Int = -1;

    var offsetX:Float = 0;
    var offsetY:Float = 0;

    var animList:Array<Dynamic> = [];
    var animOffsets:Array<Dynamic> = [];

    var character:Character;

    var uiGroup:FlxGroup = new FlxGroup();
    var uiBase:FlxUI;

    var gameCam:FlxCamera;
    var hudCam:FlxCamera;
    var camFollow:FlxObject;

    var animListText:FlxText;

    var curAnimText:FlxText;

    var charNamePos:Array<Dynamic> = [];

    var characterList:Array<String> = [];

    var charNameBox:FlxUIInputText;

    var stage:Stage;

    #if sys
    var jsonDirs = sys.FileSystem.readDirectory(Sys.getCwd() + "assets/characters/");
    #else
    var jsonDirs:Array<String> = [
        "bf.json", 
        "bf-car.json", 
        "bf-christmas.json", 
        "bf-pixel.json", 
        "bf-pixel-dead.json", 
        "dad.json", 
        "gf.json", 
        "gf-car.json", 
        "gf-christmas.json", 
        "gf-pixel.json",
        "mom.json",
        "mom-car.json",
        "monster.json",
        "monster-christmas.json",
        "parents-christmas.json",
        "pico.json",
        "placeholder.json",
        "senpai.json",
        "senpai-angry.json",
        "spirit.json",
        "spooky.json"
    ];
    #end

    var jsons:Array<String> = [];
    
    override public function create()
    {
        super.create();

        trace("OLD JSON SHIT: " + jsons);

        #if sys
        if(Mods.activeMods.length > 0)
        {
            for(mod in Mods.activeMods)
            {
                if(sys.FileSystem.exists(Sys.getCwd() + 'mods/$mod/characters/'))
                {
                    var funnyArray = sys.FileSystem.readDirectory(Sys.getCwd() + 'mods/$mod/characters/');
                    
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

        trace("NEW JSON SHIT: " + jsons);

        BasicState.changeAppTitle(Util.engineName, "Character Editor - Editing Character: " + curChar);

        persistentUpdate = true;

		hudCam = new FlxCamera();
		gameCam = new FlxCamera();
		hudCam.bgColor.alpha = 0;

		FlxG.cameras.reset();

		FlxG.cameras.add(gameCam, true);
		FlxG.cameras.add(hudCam, false);

		FlxG.cameras.setDefaultDrawTarget(gameCam, true);

		FlxG.camera = gameCam;

		/*var gridBG:FlxSprite = FlxGridOverlay.create(10, 10);
		gridBG.scrollFactor.set(0, 0);
		add(gridBG);*/

        stage = new Stage('stage');
        add(stage);

        character = new Character(0, 0, curChar);
        character.screenCenter();
        add(character);

        camFollow = new FlxObject(0, 0, 2, 2);
		camFollow.screenCenter();
		add(camFollow);

        FlxG.camera.follow(camFollow);

        updateCharacter();

        animListText = new FlxText(8, 8, 0, "coolswag\nmega coolswag\n", 18, true);
        animListText.borderStyle = OUTLINE;
        animListText.borderSize = 2;
        animListText.borderColor = FlxColor.BLACK;
        animListText.color = FlxColor.CYAN;
        animListText.cameras = [hudCam];
        add(animListText);

        curAnimText = new FlxText(0, 8, 0, "super idle", 48);
        curAnimText.setFormat("assets/fonts/vcr.ttf", 48, FlxColor.WHITE, CENTER);
        curAnimText.borderStyle = OUTLINE;
        curAnimText.borderSize = 2;
        curAnimText.borderColor = FlxColor.BLACK;
        curAnimText.screenCenter(X);
        curAnimText.cameras = [hudCam];
        add(curAnimText);

        updateAnimList();

        changeAnim(1);

        character.x = PlayState.characterPositions[1][0];
        character.y = PlayState.characterPositions[1][1];

        character.x += character.position[0];
        character.y += character.position[1];

        offsetX = character.offset.x;
        offsetY = character.offset.y;

        refreshDiscordRPC();

        uiGroup.cameras = [hudCam];
        add(uiGroup);

        getCharacterList();

        create_UI();
    }

    function getCharacterList()
    {
        characterList = [];

        for(json in jsons)
        {
            characterList.push(json);
        }

        trace(characterList);
    }

    function create_UI()
    {
        uiBase = new FlxUI(null, null);
        var uiBox = new FlxUITabMenu(null, [], false);

        uiBox.resize(300, 400);
        uiBox.x = (FlxG.width - uiBox.width) - 20;
        uiBox.y = 10;

        var charName:FlxText = new FlxText(uiBox.x + 10, 20, 0, "Character Name");

        charNamePos = [];
        charNamePos.push(charName.x);
        charNamePos.push(charName.y);

        trace(charNamePos);

        var charNameTextBox:FlxUIInputText = new FlxUIInputText(charName.x, charName.y + 20, 100, curChar, 8);
        charNameBox = charNameTextBox;

        var charListMenu:CustomDropdown = new CustomDropdown(charName.x, charName.y + 20, CustomDropdown.makeStrIdLabelArray(characterList, true), function(id:String){
            character.loadCharacter(characterList[Std.parseInt(id)]);

            character.x = PlayState.characterPositions[1][0];
            character.y = PlayState.characterPositions[1][1];
    
            character.x += character.position[0];
            character.y += character.position[1];

            updateCharacter();

            updateAnimList();

            changeAnim();
        });

        var saveCharBTN:FlxButton = new FlxButton(charListMenu.x + (charListMenu.width + 10), charListMenu.y, "Save Character", function(){

        });

        var charNameWarn:FlxText = new FlxText(charName.x, charName.y + 40, 0, "Click \"Save Character\" to save your current character.");

        var charFlipBox:FlxUICheckBox = new FlxUICheckBox(charName.x, charNameWarn.y + 30, null, null, "Flip Character Horizontally", 250);
        charFlipBox.checked = character.flipX;

        charFlipBox.callback = function()
        {
            character.flipX = charFlipBox.checked;
        };

        var charLoopAnimBox:FlxUICheckBox = new FlxUICheckBox(charName.x, charFlipBox.y + 30, null, null, "Loop Animation", 250);
        charLoopAnimBox.checked = character.animation.curAnim.looped;

        charLoopAnimBox.callback = function()
        {
            // idk yet lol
        };

        uiBase.add(uiBox);
        // TEXT/TEXTBOXES
        uiBase.add(charName);
        //uiBase.add(charNameTextBox);
        uiBase.add(charNameWarn);

        // BUTTONS
        uiBase.add(saveCharBTN);

        // CHECKBOXES
        uiBase.add(charFlipBox);
        uiBase.add(charLoopAnimBox);

        // DROPDOWNS
        uiBase.add(charListMenu);

        // add the shit
        uiGroup.add(uiBase);
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);

        curAnimText.text = animList[curAnim];
        curAnimText.screenCenter(X);

        if((Controls.back && !charNameBox.hasFocus) || FlxG.keys.justPressed.ESCAPE)
            transitionState(new OptionsState());

        var leftP = FlxG.keys.pressed.J;
        var downP = FlxG.keys.pressed.K;
        var upP = FlxG.keys.pressed.I;
        var rightP = FlxG.keys.pressed.L;

        var left = FlxG.keys.justPressed.LEFT;
        var down = FlxG.keys.justPressed.DOWN;
        var up = FlxG.keys.justPressed.UP;
        var right = FlxG.keys.justPressed.RIGHT;
        var shiftP = FlxG.keys.pressed.SHIFT;

		var inputTexts:Array<FlxUIInputText> = [charNameBox];
		for (i in 0...inputTexts.length) {
			if(inputTexts[i].hasFocus) {
				if(FlxG.keys.pressed.CONTROL && FlxG.keys.justPressed.V && Clipboard.text != null) { //Copy paste
					inputTexts[i].text = ClipboardAdd(inputTexts[i].text);
					inputTexts[i].caretIndex = inputTexts[i].text.length;
					getEvent(FlxUIInputText.CHANGE_EVENT, inputTexts[i], null, []);
				}
				if(FlxG.keys.justPressed.ENTER) {
					inputTexts[i].hasFocus = false;
				}
				FlxG.sound.muteKeys = [];
				FlxG.sound.volumeDownKeys = [];
				FlxG.sound.volumeUpKeys = [];
				super.update(elapsed);
				return;
			}
		}
		FlxG.sound.muteKeys = TitleScreenState.muteKeys;
		FlxG.sound.volumeDownKeys = TitleScreenState.volumeDownKeys;
		FlxG.sound.volumeUpKeys = TitleScreenState.volumeUpKeys;

        var offsetMultiplier:Float = 0;

        var camVelocity:Float = 190;

        if(!charNameBox.hasFocus)
        {
            if (FlxG.keys.justPressed.E)
            {
                FlxG.camera.zoom += 0.1;

                if(FlxG.camera.zoom > 10)
                    FlxG.camera.zoom = 10;
            }

            if (FlxG.keys.justPressed.Q)
            {
                FlxG.camera.zoom -= 0.1;

                if(FlxG.camera.zoom < 0.1)
                    FlxG.camera.zoom = 0.1;
            }

            if(upP || leftP || downP || rightP)
            {
                if(upP)
                    camFollow.velocity.y = camVelocity;
                else if (downP)
                    camFollow.velocity.y = camVelocity * -1;
                else
                    camFollow.velocity.y = 0;

                if(leftP)
                    camFollow.velocity.x = camVelocity;
                else if(rightP)
                    camFollow.velocity.x = camVelocity * -1;
                else
                    camFollow.velocity.x = 0;
            }
            else
                camFollow.velocity.set();

            if(FlxG.keys.justPressed.W)
                changeAnim(-1);

            if(FlxG.keys.justPressed.S)
                changeAnim(1);

            if(FlxG.keys.justPressed.SPACE)
                character.playAnim(animList[curAnim], true, null, null, animOffsets[curAnim][0], animOffsets[curAnim][1]);

            if(up || left || down || right)
            {
                if(shiftP)
                    offsetMultiplier = 18;
                else
                    offsetMultiplier = 1;

                if(up)
                    offsetY += offsetMultiplier;
                else if(down)
                    offsetY -= offsetMultiplier;
                else if(left)
                    offsetX += offsetMultiplier;
                else if(right)
                    offsetX -= offsetMultiplier;

                character.offset.set(offsetX, offsetY);

                trace("Before Offset Change: [" + animOffsets[curAnim][0] + ", " + animOffsets[curAnim][1] + "]");

                animOffsets[curAnim][0] = offsetX;
                animOffsets[curAnim][1] = offsetY;

                trace("After Offset Change: [" + animOffsets[curAnim][0] + ", " + animOffsets[curAnim][1] + "]");

                updateAnimList();
            }
        }
    }

    function refreshDiscordRPC()
    {
        #if discord_rpc
        DiscordRPC.changePresence("In Character Editor - Editing " + curChar, null);
        #end
    }

    function changeAnim(?change:Int = 0)
    {
        curAnim += change;

        if(curAnim < 0)
            curAnim = animList.length - 1;

        if(curAnim > animList.length - 1)
            curAnim = 0;

        updateAnimList();

        character.playAnim(animList[curAnim], null, null, null, animOffsets[curAnim][0], animOffsets[curAnim][1]);

        offsetX = character.offset.x;
        offsetY = character.offset.y;
    }

    function updateCharacter()
    {
        animList = [];
        animOffsets = [];

        for(i in 0...character.anims.length)
        {
            animList.push(character.anims[i].anim);
            trace([character.offsetMap[character.anims[i].anim][0], character.offsetMap[character.anims[i].anim][1]]);
            animOffsets.push([character.offsetMap[character.anims[i].anim][0], character.offsetMap[character.anims[i].anim][1]]);
        }

        trace(animList);
        trace(animOffsets);
    }

    function updateAnimList()
    {
        var fuckYou:String = "";
        var fuckYou2:String = "";

        for(i in 0...animList.length)
        {
            if(animList[curAnim] == animList[i])
                fuckYou2 = "> ";
            else
                fuckYou2 = "";
            
            fuckYou += fuckYou2 + animList[i] + " [" + animOffsets[i][0] + ", " + animOffsets[i][1] + "]\n";
        }

        animListText.text = fuckYou;
    }

	function ClipboardAdd(prefix:String = ''):String {
		if(prefix.toLowerCase().endsWith('v')) //probably copy paste attempt
		{
			prefix = prefix.substring(0, prefix.length-1);
		}

		var text:String = prefix + Clipboard.text.replace('\n', '');
		return text;
	}
}