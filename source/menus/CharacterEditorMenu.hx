package menus;

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
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import game.Character;

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

    var gameCam:FlxCamera;
    var hudCam:FlxCamera;
    var camFollow:FlxObject;

    var animListText:FlxText;

    var curAnimText:FlxText;
    
    override public function create()
    {
        super.create();

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

		var gridBG:FlxSprite = FlxGridOverlay.create(10, 10);
		gridBG.scrollFactor.set(0, 0);
		add(gridBG);

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

        offsetX = character.offset.x;
        offsetY = character.offset.y;

        refreshDiscordRPC();
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);

        curAnimText.text = animList[curAnim];
        curAnimText.screenCenter(X);

        if(FlxG.keys.justPressed.BACKSPACE)
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

        var offsetMultiplier:Float = 0;

        var camVelocity:Float = 190;

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
}