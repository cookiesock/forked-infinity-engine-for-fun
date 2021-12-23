package game;

import flixel.util.FlxTimer;
import flixel.FlxG;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.util.FlxColor;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.group.FlxGroup.FlxTypedGroup;
import lime.utils.Assets;
import openfl.Assets;
import game.StrumArrow;

using StringTools;

class PlayState extends BasicState
{
	var singAnims:Array<String> = ['singLEFT', 'singDOWN', 'singUP', 'singRIGHT'];
	var cameraZooms:Bool = true;
	
	// stage shit
	static public var stageCamZoom:Float = 1;
	static public var pixelStage:Bool = false;
	static public var pixelAssetZoom:Float = 6.1;
	//var stage:Stage;
	
	// testing character shit
	var testChar:Character;
	var testChar2:Character;
	var debugText:FlxText;
	
	// arrow shit
	var opponentStrumArrows:FlxTypedGroup<StrumArrow>;
	var playerStrumArrows:FlxTypedGroup<StrumArrow>;
	var strumArea:FlxSprite;
	
	// camera shit
	var hudCam:FlxCamera;
	var gameCam:FlxCamera;
	var otherCam:FlxCamera;

	override public function create()
	{
		if (FlxG.sound.music != null) {
			FlxG.sound.music.stop();
		}
			
		gameCam = new FlxCamera();
		hudCam = new FlxCamera();
		otherCam = new FlxCamera();
		hudCam.bgColor.alpha = 0;
		otherCam.bgColor.alpha = 0;

		FlxG.cameras.reset(gameCam);
		FlxG.cameras.add(hudCam);
		FlxG.cameras.add(otherCam);

		FlxCamera.defaultCameras = [gameCam];
		
		// bpm init shit		
		funkyBpm(102);

		//add(stage);
		//stage = new Stage('stage');
		
		// arrow shit
		strumArea = new FlxSprite(0, 50);
		strumArea.visible = false;
		add(strumArea);
		
		opponentStrumArrows = new FlxTypedGroup<StrumArrow>();
		playerStrumArrows = new FlxTypedGroup<StrumArrow>();
		
		opponentStrumArrows.cameras = [hudCam];
		playerStrumArrows.cameras = [hudCam];
		
		add(opponentStrumArrows);
		add(playerStrumArrows);

		for(i in 0...8) { // add strum arrows
			var isPlayerArrow:Bool = i > 3;
			var funnyArrowX:Float = 42;
			
			if(isPlayerArrow) {
				funnyArrowX += 242;
			}
			
			var theRealStrumArrow:StrumArrow = new StrumArrow(funnyArrowX + i * 112, strumArea.y - (i % 4) * 10, i, 'default');
			theRealStrumArrow.alpha = 0;
			
			if(!isPlayerArrow) {
				opponentStrumArrows.add(theRealStrumArrow);	
			} else {
				playerStrumArrows.add(theRealStrumArrow);
			}
		}
		
		// debug shit

		debugText = new FlxText(0,0,FlxG.width, "", 12, true);
		debugText.color = FlxColor.WHITE;
		add(debugText);
		
		debugText.cameras = [otherCam];

		/*testChar2 = new Character(100, 120, "gf");
		testChar2.screenCenter();
		add(testChar2);

		testChar = new Character(testChar2.x + 300, testChar2.y + 100, "bf");
		add(testChar);*/
		
		// if you see this and think "why the FUCK is this commented out"
		// my pc is shit, uncomment it if you need it lmao - swordcube

		super.create();
	}

	override public function update(elapsed:Float)
	{
		debugText.text = curBeat + "\n" + curStep;
		
		if(FlxG.keys.justPressed.BACKSPACE)
		{
			FlxG.sound.playMusic(Util.getSound("menus/freakyMenu", false));
			FlxG.switchState(new menus.MainMenuState());
		} // temporary way to go back to menus without restarting the game
		// THIS WILL BE REPLACED WITH PAUSE MENU WHEN THAT IS EXIST!!!
		
		FlxG.camera.zoom = FlxMath.lerp(stageCamZoom, FlxG.camera.zoom, Util.boundTo(1 - (elapsed * 3.125), 0, 1));
		hudCam.zoom = FlxMath.lerp(1, hudCam.zoom, Util.boundTo(1 - (elapsed * 3.125), 0, 1));
		
		// tween the fucking strum arrows lol
		for(i in 0...4) {
			opponentStrumArrows.members[i].y = FlxMath.lerp(opponentStrumArrows.members[i].y, strumArea.y, Math.max(0, Math.min(1, elapsed * 3)));
			opponentStrumArrows.members[i].alpha = FlxMath.lerp(opponentStrumArrows.members[i].alpha, 1, Math.max(0, Math.min(1, elapsed * 3)));
		}
		
		for(i in 0...4) {
			playerStrumArrows.members[i].y = FlxMath.lerp(playerStrumArrows.members[i].y, strumArea.y, Math.max(0, Math.min(1, elapsed * 3)));
			playerStrumArrows.members[i].alpha = FlxMath.lerp(playerStrumArrows.members[i].alpha, 1, Math.max(0, Math.min(1, elapsed * 3)));
		}
		
		super.update(elapsed);
	}

	override public function beatHit(timer:FlxTimer)
	{
		if (cameraZooms && FlxG.camera.zoom < 1.35 && curBeat % 4 == 0)
		{
			FlxG.camera.zoom += 0.015;
			hudCam.zoom += 0.03;
		}
		
		/*testChar.dance();
		testChar2.dance();*/
		super.beatHit(timer);
	}
}
