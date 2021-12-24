package game;

import flixel.FlxObject;
import flixel.system.FlxSound;
import flixel.util.FlxSort;
import ui.Icon;
import flixel.input.FlxInput.FlxInputState;
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
import ui.Icon;
import ui.CountdownSprite;

using StringTools;

class PlayState extends BasicState
{
	var singAnims:Array<String> = ['singLEFT', 'singDOWN', 'singUP', 'singRIGHT'];
	var cameraZooms:Bool = true;
	static public var bpm:Float = 0;

	public var vocals:FlxSound;

	public static var song:Song;

	private var camFollow:FlxObject;
	
	// stage shit
	static public var stageCamZoom:Float = 0.9;
	public var pixelStage:Bool = false;
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
	var notes:Array<Note> = [];

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
	
	var opponentHealthColor:Int = 0xFFAF66CE;
	var playerHealthColor:Int = 0xFF31B0D1;
	
	// countdown shit
	var countdownStarted:Bool = true;
	var countdownNum:Int = -1;

	var downscroll:Bool = Options.DOWNSCROLL;
	var botplay:Bool = Options.BOTPLAY;

	var speed:Float = 1;

	public function new(?songName:String, ?difficulty:String)
	{
		super();

		if(songName != null)
		{
			songName = songName.toLowerCase();
			
			if(difficulty != null)
				difficulty = difficulty.toLowerCase();
			else
				difficulty = "normal";
	
			song = Util.getJsonContents('assets/songs/$songName/$difficulty.json').song;
		}
	}

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

		speed = song.speed;
		
		// commented out speakers/gf because my pc sucks rn - swordcube
		// that should hopefully no longer be the case on christmas - also swordcube

		switch(song.song.toLowerCase()) // gf char
		{
			case "satin panties" | "high" | "m.i.l.f":
				if(song.gf == null)
					song.gf = "gf-car";
			case "cocoa" | "eggnog" | "winter horrorland":
				if(song.gf == null)
					song.gf = "gf-christmas";
			case "senpai" | "roses" | "thorns":
				if(song.gf == null)
					song.gf = "gf-pixel";

				pixelStage = true;
			default:
				if(song.gf == null)
					song.gf = "gf";
			
				if(song.ui_Skin == null)
					song.ui_Skin = "default";
		}

		switch(song.song.toLowerCase()) // song skin
		{
			case "senpai" | "roses" | "thorns":
				if(song.ui_Skin == null)
					song.ui_Skin = "default-pixel";

				pixelStage = true;
			default:
				if(song.ui_Skin == null)
					song.ui_Skin = "default";
		}

		if(!song.player2.startsWith("gf"))
		{
			speakers = new Character(100, 120, song.gf);
			speakers.screenCenter(X);
			speakers.scrollFactor.set(0.95, 0.95);
			add(speakers);

			opponent = new Character(100, 120, song.player2);
			opponent.screenCenter();
			add(opponent);
		}
		else
		{
			opponent = new Character(100, 120, song.gf);
			opponent.screenCenter(X);
			opponent.scrollFactor.set(0.95, 0.95);
			add(opponent);
		}

		player = new Character(opponent.x + 350, opponent.y + 200, song.player1);
		player.flipX = !player.flipX;
		player.isPlayer = true;
		add(player);
		
		// bpm init shit
		bpm = song.bpm;
		funkyBpm(bpm);

		camFollow = new FlxObject(0, 0, 1, 1);

		camFollow.setPosition(opponent.getMidpoint().x + 150 + opponent.camOffsets[0], opponent.getMidpoint().y - 100 + opponent.camOffsets[1]);

		add(camFollow);

		FlxG.camera.follow(camFollow, LOCKON, 0.04 * (60 / Main.display.currentFPS));
		FlxG.camera.focusOn(camFollow.getPosition());

		// stage shit
		//add(stage);
		//stage = new Stage('stage');
		
		// arrow shit
		strumArea = new FlxSprite(0, 50);
		strumArea.visible = false;
		//strumArea.makeGraphic(FlxG.width, 25, FlxColor.WHITE);

		if(downscroll)
			strumArea.y = FlxG.height - 150;

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
			
			var theRealStrumArrow:StrumArrow = new StrumArrow(funnyArrowX + i * 112, strumArea.y - (i % 4 + 1) * (7 + i * 1), i, song.ui_Skin);
			theRealStrumArrow.alpha = 0;
			
			if(!isPlayerArrow) {
				opponentStrumArrows.add(theRealStrumArrow);	
			} else {
				playerStrumArrows.add(theRealStrumArrow);
			}
		}
		
		// health bar shit
		healthBarBG = new FlxSprite(0, FlxG.height * 0.9).loadGraphic(Util.getImage('healthBar'));
		healthBarBG.screenCenter(X);
		healthBarBG.scrollFactor.set();
		add(healthBarBG);

		if(downscroll)
			healthBarBG.y = 60;
		
		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this,
			'health', 0, 2);
		healthBar.scrollFactor.set();
		healthBar.createFilledBar(opponent.healthColor, player.healthColor);
		add(healthBar);
		
		// health bar icons
		opponentIcon = new Icon(Util.getCharacterIcons(opponent.healthIcon), false);
		opponentIcon.y = healthBar.y - (opponentIcon.height / 2);
		add(opponentIcon);
		
		playerIcon = new Icon(Util.getCharacterIcons(player.healthIcon), true);
		playerIcon.y = healthBar.y - (playerIcon.height / 2);
		add(playerIcon);
		
		// debug shit

		debugText = new FlxText(0,0,FlxG.width, "", 32, true);
		debugText.color = FlxColor.WHITE;
		debugText.font = Util.getFont("vcr");
		add(debugText);
		
		// camera shit
		opponentStrumArrows.cameras = [hudCam];
		playerStrumArrows.cameras = [hudCam];
		healthBarBG.cameras = [hudCam];
		healthBar.cameras = [hudCam];
		opponentIcon.cameras = [hudCam];
		playerIcon.cameras = [hudCam];
		debugText.cameras = [otherCam];

		if(song.chartOffset == null)
			song.chartOffset = 0;

		for(section in song.notes)
		{
			for(songNotes in section.sectionNotes)
			{
				var daStrumTime:Float = songNotes[0] + song.chartOffset + Options.SONG_OFFSET;
				var daNoteData:Int = Std.int(songNotes[1] % 4);

				var gottaHitNote:Bool = section.mustHitSection;

				if(songNotes[1] >= 4)
					gottaHitNote = !section.mustHitSection;

				/*
				var oldNote:Note;

				if (unspawnNotes.length > 0)
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
				else
					oldNote = null;*/

				var swagNote:Note = new Note((gottaHitNote ? playerStrumArrows.members[daNoteData].x : opponentStrumArrows.members[daNoteData].x), 0, daNoteData, daStrumTime, gottaHitNote, song.ui_Skin);
				swagNote.scrollFactor.set(0,0);
				swagNote.cameras = [hudCam];
				add(swagNote);

				notes.push(swagNote);
			}
		}

		notes.sort(sortByShit);

		Conductor.songPosition = -1 * (Conductor.crochet * 5);
		
		super.create();
	}

	override public function update(elapsed:Float)
	{
		Conductor.songPosition += elapsed * 1000;

		if(!countdownStarted)
		{
			if(FlxG.sound.music != null) // resync song pos lol
			{
				if(FlxG.sound.music.active) // resync song pos lol
				{
					if(FlxG.sound.music.time > Conductor.songPosition + 20 || FlxG.sound.music.time < Conductor.songPosition - 20)
					{
						Conductor.songPosition = FlxG.sound.music.time;
					}
	
					if(vocals != null)
					{
						if(vocals.active)
						{
							if(vocals.time > FlxG.sound.music.time + 20 || vocals.time < FlxG.sound.music.time - 20)
							{
								vocals.pause();
								vocals.time = FlxG.sound.music.time;
								vocals.play();
							}
						}
					}
				}
			}
		}

		debugText.text = curBeat + "\n" + curStep + "\n" + Conductor.songPosition + "\n" + FlxG.sound.music.time;
		
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

		for(note in notes)
		{
			if(note.mustPress)
			{
				if(downscroll)
					note.y = playerStrumArrows.members[note.noteID].y + (0.45 * (Conductor.songPosition - note.strum) * FlxMath.roundDecimal(speed, 2));
				else
					note.y = playerStrumArrows.members[note.noteID].y - (0.45 * (Conductor.songPosition - note.strum) * FlxMath.roundDecimal(speed, 2));
			}
			else
			{
				if(downscroll)
					note.y = opponentStrumArrows.members[note.noteID].y + (0.45 * (Conductor.songPosition - note.strum) * FlxMath.roundDecimal(speed, 2));
				else
					note.y = opponentStrumArrows.members[note.noteID].y - (0.45 * (Conductor.songPosition - note.strum) * FlxMath.roundDecimal(speed, 2));

				if(!countdownStarted)
				{
					if(Conductor.songPosition >= note.strum)
					{
						if(vocals != null)
							vocals.volume = 1;

						opponent.holdTimer = 0;
						opponent.playAnim(singAnims[note.noteID % 4], true);

						notes.remove(note);
						note.kill();
						note.destroy();

						opponentStrumArrows.members[note.noteID].playAnim("confirm", true);

						opponentStrumArrows.members[note.noteID].animation.finishCallback = function(name:String) {
							if(name == "confirm")
								opponentStrumArrows.members[note.noteID].playAnim("strum", true);
						};
					}
				}
			}

			if(!countdownStarted)
			{
				if(Conductor.songPosition - Conductor.safeZoneOffset > note.strum && note != null)
				{
					if(note.mustPress)
					{
						if(vocals != null)
							vocals.volume = 0;

						changeHealth(false);

						player.holdTimer = 0;
						player.playAnim(singAnims[note.noteID % 4] + "miss", true);
					}

					notes.remove(note);
					note.kill();
					note.destroy();
				}
			}
		}

		if(!countdownStarted)
			inputFunction();
		
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

					FlxG.sound.playMusic(Util.getInst(song.song.toLowerCase()), 1, false);

					if(song.needsVoices)
					{
						FlxG.sound.music.pause();

						vocals = FlxG.sound.play(Util.getVoices(song.song.toLowerCase()));

						vocals.pause();

						FlxG.sound.music.time = 0;
						vocals.time = 0;
	
						FlxG.sound.music.play();
						vocals.play();
					}
					else 
						vocals = new FlxSound();

					FlxG.sound.music.onComplete = function()
					{
						FlxG.sound.playMusic(Util.getSound("menus/freakyMenu", false));
						FlxG.switchState(new menus.MainMenuState());
					};
			}
		}
		
		if(opponent.active)
		{
			if((opponent.animation.curAnim.name.startsWith("sing") && opponent.animation.curAnim.finished || !opponent.animation.curAnim.name.startsWith("sing")))
				opponent.dance();
		}

		if(player.active)
		{
			if(!player.animation.curAnim.name.startsWith("sing"))
				player.dance();
		}

		if(speakers != null)
		{
			if(speakers.active)
				speakers.dance();
		}

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

	function sortByShit(Obj1:Note, Obj2:Note):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strum, Obj2.strum);
	}

	function inputFunction()
	{
		var testBinds:Array<String> = Options.MAIN_BINDS;
		var testBindsAlt:Array<String> = Options.ALT_BINDS;

		var justPressed:Array<Bool> = [false, false, false, false];
		var pressed:Array<Bool> = [false, false, false, false];
		var released:Array<Bool> = [false, false, false, false];

		if(!botplay)
		{
			for(i in 0...testBinds.length)
			{
				justPressed[i] = FlxG.keys.checkStatus(FlxKey.fromString(testBinds[i]), FlxInputState.JUST_PRESSED);
				pressed[i] = FlxG.keys.checkStatus(FlxKey.fromString(testBinds[i]), FlxInputState.PRESSED);
				released[i] = FlxG.keys.checkStatus(FlxKey.fromString(testBinds[i]), FlxInputState.RELEASED);
	
				if(released[i] == true)
				{
					justPressed[i] = FlxG.keys.checkStatus(FlxKey.fromString(testBindsAlt[i]), FlxInputState.JUST_PRESSED);
					pressed[i] = FlxG.keys.checkStatus(FlxKey.fromString(testBindsAlt[i]), FlxInputState.PRESSED);
					released[i] = FlxG.keys.checkStatus(FlxKey.fromString(testBindsAlt[i]), FlxInputState.RELEASED);
				}
			}
	
			for(i in 0...justPressed.length)
			{
				if(justPressed[i])
					playerStrumArrows.members[i].playAnim("tap", true);
			}
	
			for(i in 0...released.length)
			{
				if(released[i])
					playerStrumArrows.members[i].playAnim("strum");
			}
		}
		else
		{
			for(i in 0...released.length)
			{
				if(playerStrumArrows.members[i].animation.curAnim.name == "confirm" && playerStrumArrows.members[i].animation.curAnim.finished)
					playerStrumArrows.members[i].playAnim("strum");
			}
		}

		var possibleNotes:Array<Note> = [];

		for(note in notes)
		{
			note.calculateCanBeHit();

			if(!botplay)
			{
				if(note.canBeHit && note.mustPress && !note.tooLate && !note.isSustainNote)
					possibleNotes.push(note);
			}
			else
			{
				if(Conductor.songPosition - note.strum >= 0 && note.mustPress)
					possibleNotes.push(note);
			}
		}

		possibleNotes.sort((a, b) -> Std.int(a.strum - b.strum));

		if(possibleNotes.length > 0)
		{
			var dontHitTheseDirectionsLol:Array<Bool> = [false, false, false, false];
			var noteDataTimes:Array<Float> = [-1, -1, -1, -1];

			for(i in 0...possibleNotes.length)
			{
				var note = possibleNotes[i];

				if(((justPressed[note.noteID] && !dontHitTheseDirectionsLol[note.noteID]) && !botplay) || botplay)
				{
					var noteMs = Conductor.songPosition - note.strum;
					trace(noteMs + " ms");

					noteDataTimes[note.noteID] = note.strum;

					if(vocals != null)
						vocals.volume = 1;

					playerStrumArrows.members[note.noteID].playAnim("confirm", true);
					dontHitTheseDirectionsLol[note.noteID] = true;

					changeHealth(true);

					player.holdTimer = 0;
					player.playAnim(singAnims[note.noteID % 4], true);

					pressed[note.noteID] = true;

					notes.remove(note);
					note.kill();
					note.destroy();
				}
			}

			if(possibleNotes.length > 0)
			{
				for(i in 0...possibleNotes.length)
				{
					var note = possibleNotes[i];

					if(note.strum == noteDataTimes[note.noteID] && dontHitTheseDirectionsLol[note.noteID])
					{
						notes.remove(note);
						note.kill();
						note.destroy();
					}
				}
			}
		}

		if(player.holdTimer > Conductor.stepCrochet * 4 * 0.001 && !pressed.contains(true))
			if(player.animation.curAnim.name.startsWith('sing'))
				player.dance();
	}
}
