package game;

import flixel.util.FlxTimer;
import flixel.FlxG;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.ui.FlxBar;
import flixel.util.FlxColor;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.group.FlxGroup.FlxTypedGroup;
import lime.utils.Assets;
import openfl.Assets;
import game.StrumArrow;
import ui.HealthIcon;
import ui.CountdownSprite;

using StringTools;

class PlayState extends BasicState
{
	var singAnims:Array<String> = ['singLEFT', 'singDOWN', 'singUP', 'singRIGHT'];
	var cameraZooms:Bool = true;
	static public var bpm:Float = 0;
	
	// stage shit
	static public var stageCamZoom:Float = 0.9;
	static public var pixelStage:Bool = false;
	static public var pixelAssetZoom:Float = 6.1;
	//var stage:Stage;
	
	// character shit
	var opponent:Character;
	var speakers:Character;
	var player:Character;	
	var debugText:FlxText;
	
	// arrow shit
	var opponentStrumArrows:FlxTypedGroup<StrumArrow>;
	var playerStrumArrows:FlxTypedGroup<StrumArrow>;
	var strumArea:FlxSprite;
	
	// camera shit
	var hudCam:FlxCamera;
	var gameCam:FlxCamera;
	var otherCam:FlxCamera;
	
	// health bar shit
	var healthBarBG:FlxSprite;
	var healthBar:FlxBar;
	var health:Float = 1;
	
	var opponentIcon:FlxSprite;
	var playerIcon:FlxSprite;
	
	var opponentHealthColor:Int = 0xFFFFFFFF;
	var playerHealthColor:Int = 0xFFFFFFFF;
	
	// countdown shit
	var countdownStarted:Bool = true;
	var countdownNum:Int = -1;

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
		FlxG.camera.zoom = stageCamZoom;
		
		// commented out speakers/gf because my pc sucks rn - swordcube
		// that should hopefully no longer be the case on christmas - also swordcube
		
		//opponent = new Character(100, 120, "dad");
		//opponent.screenCenter();
		//add(opponent);
		
		//speakers = new Character(100, 120, "gf");
		//speakers.screenCenter(X);
		//add(speakers);

		//player = new Character(player.x + 300, player.y + 100, "bf");
		//add(player);
		
		// bpm init shit
		bpm = 190;	
		funkyBpm(bpm);

		// stage shit
		//add(stage);
		//stage = new Stage('stage');
		
		// arrow shit
		strumArea = new FlxSprite(0, 50);
		strumArea.visible = false;
		add(strumArea);
		
		opponentStrumArrows = new FlxTypedGroup<StrumArrow>();
		playerStrumArrows = new FlxTypedGroup<StrumArrow>();
		
		add(opponentStrumArrows);
		add(playerStrumArrows);

		for(i in 0...8) { // add strum arrows
			var isPlayerArrow:Bool = i > 3;
			var funnyArrowX:Float = 42;
			
			if(isPlayerArrow) {
				funnyArrowX += 242;
			}
			
			var theRealStrumArrow:StrumArrow = new StrumArrow(funnyArrowX + i * 112, strumArea.y - (i % 4 + 1) * (7 + i * 1), i, 'default');
			theRealStrumArrow.alpha = 0;
			
			if(!isPlayerArrow) {
				opponentStrumArrows.add(theRealStrumArrow);	
			} else {
				playerStrumArrows.add(theRealStrumArrow);
			}
		}
		
		// health bar shit
		healthBarBG = new FlxSprite(0, FlxG.height - 90).loadGraphic(Util.getImage('healthBar'));
		healthBarBG.screenCenter(X);
		healthBarBG.scrollFactor.set();
		add(healthBarBG);
		
		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this,
			'health', 0, 2);
		healthBar.scrollFactor.set();
		healthBar.createFilledBar(opponentHealthColor, playerHealthColor);
		add(healthBar);
		
		// health bar icons
		opponentIcon = new HealthIcon('dad', false);
		opponentIcon.y = healthBar.y - (opponentIcon.height / 2);
		add(opponentIcon);
		
		playerIcon = new HealthIcon('bf', true);
		playerIcon.y = healthBar.y - (playerIcon.height / 2);
		add(playerIcon);
		
		// debug shit

		debugText = new FlxText(0,0,FlxG.width, "", 12, true);
		debugText.color = FlxColor.WHITE;
		add(debugText);
		
		// camera shit
		opponentStrumArrows.cameras = [hudCam];
		playerStrumArrows.cameras = [hudCam];
		healthBarBG.cameras = [hudCam];
		healthBar.cameras = [hudCam];
		opponentIcon.cameras = [hudCam];
		playerIcon.cameras = [hudCam];
		debugText.cameras = [otherCam];
		
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
		
		// health icons!!!!!!!
		playerIcon.setGraphicSize(Std.int(FlxMath.lerp(playerIcon.width, 150, 0.09 / (openfl.Lib.current.stage.frameRate / 120))));
		opponentIcon.setGraphicSize(Std.int(FlxMath.lerp(opponentIcon.width, 150, 0.09 / (openfl.Lib.current.stage.frameRate / 120))));
		
		playerIcon.updateHitbox();
		opponentIcon.updateHitbox();
		
		playerIcon.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01) - 26);
		opponentIcon.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (opponentIcon.width - 26);

		if (health < 0)
			health = 0;

		if (health > 2)
			health = 2;
			
		if (healthBar.percent < 20)
			playerIcon.animation.curAnim.curFrame = 1;
		else
			if (healthBar.percent > 80)
				playerIcon.animation.curAnim.curFrame = 2;
			else
				playerIcon.animation.curAnim.curFrame = 0;

		if (healthBar.percent > 80)
			opponentIcon.animation.curAnim.curFrame = 1;
		else
			if (healthBar.percent < 20)
				opponentIcon.animation.curAnim.curFrame = 2;
			else
				opponentIcon.animation.curAnim.curFrame = 0;
		
		super.update(elapsed);
	}

	override public function beatHit(timer:FlxTimer)
	{
		if (!countdownStarted) {
			if (cameraZooms && FlxG.camera.zoom < 1.35 && curBeat % 4 == 0)
			{
				FlxG.camera.zoom += 0.015;
				hudCam.zoom += 0.03;
			}
			
			playerIcon.setGraphicSize(Std.int(playerIcon.width + 30));
			opponentIcon.setGraphicSize(Std.int(opponentIcon.width + 30));

			playerIcon.updateHitbox();
			opponentIcon.updateHitbox();
		} else {
			countdownNum += 1;
			var filePath:String = 'countdown/normal/';
			if(pixelStage) filePath = 'countdown/pixel/';
			
			switch(countdownNum)
			{
				case 0:
					FlxG.sound.play(Util.getSound(filePath + 'intro3'), 0.6);
				case 1:
					FlxG.sound.play(Util.getSound(filePath + 'intro2'), 0.6);
					var countdown3:CountdownSprite = new CountdownSprite('ready', pixelStage);
					countdown3.cameras = [otherCam];
					add(countdown3);
				case 2:
					FlxG.sound.play(Util.getSound(filePath + 'intro1'), 0.6);
					var countdown2:CountdownSprite = new CountdownSprite('set', pixelStage);
					countdown2.cameras = [otherCam];
					add(countdown2);
				case 3:
					FlxG.sound.play(Util.getSound(filePath + 'introGo'), 0.6);
					var countdown1:CountdownSprite = new CountdownSprite('go', pixelStage);
					countdown1.cameras = [otherCam];
					add(countdown1);
				case 4:
					countdownStarted = false;
			}
		}
		
		/*opponent.dance();
		player.dance();*/
		super.beatHit(timer);
	}
	
	public function changeHealth(gainHealth:Bool)
	{
		if(gainHealth) {
			health += 0.023; // health you gain for hitting a note
		} else { 
			health -= 0.0475; // health you lose for getting a "SHIT" rating or missing a note
		}
	}
}
