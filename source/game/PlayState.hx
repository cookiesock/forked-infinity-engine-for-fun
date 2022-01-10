package game;

import openfl.system.System;
import lime.app.Application;
import lime.ui.Window;
import flixel.math.FlxRect;
import mods.Mods;
import openfl.media.Sound;
import flixel.graphics.frames.FlxAtlasFrames;
import ui.RatingSprite;
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
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.group.FlxGroup.FlxTypedGroup;
import lime.utils.Assets;
import openfl.Assets;
import game.StrumArrow;
import ui.Icon;
import ui.CountdownSprite;
import ui.RatingSprite;
import ui.ComboSprite;
import ui.NoteSplash;
import ui.DialogueBox;

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
	static public var pixelStage:Bool = false;
	static public var pixelAssetZoom:Float = 6.1;
	//var stage:Stage;
	
	// character shit
	var opponent:Character;
	var speakers:Character;
	var player:Character;	
	
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

	// score shit
	static public var score:Int = 0;
	static public var sickScore:Int = 0;
	static public var misses:Int = 0;
	static public var combo:Int = 0;

	static public var comboArray:Array<Dynamic> = [];
	
	// countdown shit
	var countdownStarted:Bool = true;
	var countdownNum:Int = -1;

	var downscroll:Bool = Options.getData('downscroll');
	static public var botplay:Bool = Options.getData('botplay');

	static public var ghostTapping:Bool = Options.getData('ghost-tapping');

	// rating shit
	var funnyRating:RatingSprite;
	var comboGroup:FlxTypedGroup<ComboSprite>;

	var msText:FlxText;
	var scoreText:FlxText;

	var ratingsText:FlxText;

	static public var botplayText:FlxText;

	var accuracy:Float = 0;
	var accuracyNum:Float = 0;
	var rating1:String = "N/A";
	var rating2:String = "N/A";

	var letterRatings:Array<String> = [
		"S++",
		"S+",
		"S",
		"A",
		"B",
		"C",
		"D",
		"E",
		"F",
	];

	var swagRatings:Array<String> = [
		'Clear',
		'SDCB',
		'FC',
		'GFC',
		'SFC'
	];

	var sicks:Int = 0;
	var goods:Int = 0;
	var bads:Int = 0;
	var shits:Int = 0;

	var hits:Int = 0;

	// song config shit
	var speed:Float = 1;
	public static var storyMode:Bool = false;

	public static var storyPlaylist:Array<String> = [];

	public static var songMultiplier:Float = 1;

	public static var paused:Bool = false;

	// misc shit
	var funnyHitStuffsLmao:Float = 0.0;
	var totalNoteStuffs:Int = 0;

	// replay shit
	public var savedReplay:Array<Dynamic> = [];
	public var isReplayMode:Bool = false;
	
	// more misc shit
	public static var noteSplashFrames:FlxAtlasFrames;

	public static var instance:PlayState;

	public static var storedDifficulty:String;

	// shit other than variables
	public function new(?songName:String, ?difficulty:String, ?storyModeBool:Bool = false)
	{
		instance = this;

		super();

		if(songName != null)
		{
			songName = songName.toLowerCase();
			
			if(difficulty != null)
				difficulty = difficulty.toLowerCase();
			else
				difficulty = "normal";

			storedDifficulty = difficulty;
	
			#if sys
			if(Assets.exists('assets/songs/$songName/$difficulty.json'))
			#end
				song = Util.getJsonContents('assets/songs/$songName/$difficulty.json').song;
			#if sys
			else
			{
				Mods.updateActiveMods();

				if(Mods.activeMods.length > 0)
				{
					for(mod in Mods.activeMods)
					{
						if(sys.FileSystem.exists(Sys.getCwd() + 'mods/$mod/songs/$songName/$difficulty.json'))
						{
							song = Util.getJsonContents('mods/$mod/songs/$songName/$difficulty.json').song;
						}
					}
				}
			}
			#end

			storyMode = storyModeBool;
		}
	}

	override public function create()
	{
		BasicState.changeAppTitle(Util.engineName, "Playing " + song.song + " on " + FlxMath.roundDecimal(songMultiplier, 2) + "x Speed");
		
		if (FlxG.sound.music != null) {
			FlxG.sound.music.stop();
		}

		score = 0;
		sickScore = 0;
		misses = 0;
		combo = 0;
		paused = false;

		botplay = Options.getData('botplay');
			
		gameCam = new FlxCamera();
		hudCam = new FlxCamera();
		otherCam = new FlxCamera();
		hudCam.bgColor.alpha = 0;
		otherCam.bgColor.alpha = 0;

		FlxG.cameras.reset();

		FlxG.cameras.add(gameCam, true);
		FlxG.cameras.add(hudCam, false);
		FlxG.cameras.add(otherCam, false);

		FlxG.cameras.setDefaultDrawTarget(gameCam, true);

		FlxG.camera = gameCam;

		FlxG.camera.zoom = stageCamZoom;

		speed = song.speed;

		if(Options.getData('scroll-speed') > 1)
			speed = Options.getData('scroll-speed');

		#if !sys
		songMultiplier = 1;
		#end

		if(songMultiplier < 0.1)
			songMultiplier = 0.1;

		Conductor.changeBPM(song.bpm, songMultiplier);

		speed /= songMultiplier;

		if(speed < 0.1 && songMultiplier > 1)
			speed = 0.1;

		Conductor.recalculateStuff(songMultiplier);
		Conductor.safeZoneOffset *= songMultiplier;
		
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

				pixelStage = false;
		}

		noteSplashFrames = Util.getSparrow('noteskins/' + game.PlayState.song.ui_Skin + '/noteSplashes');

		if(!song.player2.startsWith("gf"))
		{
			speakers = new Character(400, 130, song.gf);
			//speakers.screenCenter(X);
			speakers.scrollFactor.set(0.95, 0.95);
			add(speakers);

			opponent = new Character(100, 100, song.player2);
			//opponent.screenCenter();
			add(opponent);

			opponent.x += opponent.position[0];
			opponent.y += opponent.position[1];

			speakers.x += speakers.position[0];
			speakers.y += speakers.position[1];
		}
		else
		{
			opponent = new Character(400, 130, song.gf);
			//opponent.screenCenter(X);
			opponent.scrollFactor.set(0.95, 0.95);
			add(opponent);

			opponent.x += opponent.position[0];
			opponent.y += opponent.position[1];
		}

		player = new Character(770, 0, song.player1);
		player.flipX = !player.flipX;
		player.isPlayer = true;
		add(player);

		player.x += player.position[0];
		player.y += player.position[1];
		
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
			var funnyArrowX:Float = 62;
			
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

		funnyRating = new RatingSprite(FlxG.width * 0.55, 300);
		funnyRating.alpha = 0;
		add(funnyRating);

		comboGroup = new FlxTypedGroup<ComboSprite>();
		add(comboGroup);

		for(i in 0...4) {
			
			var newComboNum:ComboSprite = new ComboSprite();
			newComboNum.x = funnyRating.x - 80 + i * 50;
			newComboNum.y = funnyRating.y + 85;
			newComboNum.stupidY = newComboNum.y;
			newComboNum.alpha = 0;

			comboGroup.add(newComboNum);
		}

		msText = new FlxText(funnyRating.x + 105, funnyRating.y + 105, 0, "999ms", 32, true);
		msText.color = FlxColor.CYAN;
		msText.setFormat("assets/fonts/vcr.ttf", 32, FlxColor.WHITE, null, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		msText.scrollFactor.set();
		msText.borderSize = 2;
		add(msText);

		botplayText = new FlxText(0, strumArea.y + 40, 0, "BOTPLAY", 32, true);
		botplayText.setFormat("assets/fonts/vcr.ttf", 32, FlxColor.WHITE, null, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		botplayText.scrollFactor.set();
		botplayText.borderSize = 2;
		botplayText.screenCenter(X);
		add(botplayText);

		msText.alpha = 0;
		
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
		
		playerIcon = new Icon(Util.getCharacterIcons(player.healthIcon), true);
		playerIcon.y = healthBar.y - (playerIcon.height / 2);

		add(playerIcon);
		add(opponentIcon);

		scoreText = new FlxText(0, healthBarBG.y + 35, 0, "", 18);
		scoreText.screenCenter(X);
		scoreText.setFormat("assets/fonts/vcr.ttf", 18, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		scoreText.scrollFactor.set();
		scoreText.borderSize = 2;
		add(scoreText);

		if(song.chartOffset == null)
			song.chartOffset = 0;

		for(section in song.notes)
		{
			Conductor.recalculateStuff(songMultiplier);

			for(songNotes in section.sectionNotes)
			{
				var daStrumTime:Float = songNotes[0] + song.chartOffset + (Options.getData('song-offset') * songMultiplier);
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
				swagNote.sustainLength = songNotes[2];
				swagNote.scrollFactor.set(0,0);
				swagNote.cameras = [hudCam];

				var susLength:Float = swagNote.sustainLength;
				susLength = susLength / Conductor.stepCrochet;

				var floorSus:Int = Math.floor(susLength);

				if(floorSus > 0)
				{
					for (susNote in 0...floorSus)
					{
						var sustainNote:Note = new Note((gottaHitNote ? playerStrumArrows.members[daNoteData].x : opponentStrumArrows.members[daNoteData].x), 0, daNoteData, daStrumTime + (Conductor.stepCrochet * susNote) + Conductor.stepCrochet, gottaHitNote, song.ui_Skin, true, susNote == floorSus - 1);
						sustainNote.cameras = [hudCam];

						if(!sustainNote.isPixel)
							sustainNote.x += sustainNote.width / 1;
						else
							sustainNote.x += sustainNote.width / 1.5;

						if(susNote != 0)
							sustainNote.lastNote = notes[notes.length - 1];

						add(sustainNote);

						notes.push(sustainNote);
					}
				}

				add(swagNote);

				notes.push(swagNote);
			}
		}

		notes.sort(sortByShit);

		Conductor.songPosition = 0 - (Conductor.crochet * 4.5);

		var dialogueBoxTest:DialogueBox = new DialogueBox(100, FlxG.height * 0.65);
		dialogueBoxTest.scrollFactor.set();
		dialogueBoxTest.cameras = [otherCam];
		//add(dialogueBoxTest);

		ratingsText = new FlxText(8, 0, 0, "", 18);
		ratingsText.setFormat("assets/fonts/vcr.ttf", 18, FlxColor.WHITE, LEFT);
		ratingsText.borderColor = FlxColor.BLACK;
		ratingsText.borderStyle = OUTLINE;
		ratingsText.borderSize = 2;
		ratingsText.screenCenter(Y);
		add(ratingsText);

		// camera shit
		opponentStrumArrows.cameras = [hudCam];
		playerStrumArrows.cameras = [hudCam];
		healthBarBG.cameras = [hudCam];
		healthBar.cameras = [hudCam];
		opponentIcon.cameras = [hudCam];
		playerIcon.cameras = [hudCam];
		funnyRating.cameras = [hudCam];
		comboGroup.cameras = [hudCam];
		msText.cameras = [hudCam];
		scoreText.cameras = [hudCam];
		botplayText.cameras = [hudCam];
		ratingsText.cameras = [hudCam];
		
		super.create();
	}

	public function msTextFade()
	{
		FlxTween.cancelTweensOf(msText);
		msText.alpha = 1;
		FlxTween.tween(msText, {alpha: 0}, 0.4, {
			ease: FlxEase.cubeInOut,
			startDelay: 0.4,
			onComplete: function(twn:FlxTween)
			{
				// do nothign because uhsdcjnkALehds
			}
		});
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		updateAccuracyStuff();

		Conductor.songPosition += (FlxG.elapsed * 1000) * songMultiplier;

		if(!countdownStarted)
		{
			if(FlxG.sound.music != null) // resync song pos lol
			{
				if(FlxG.sound.music.active) // resync song pos lol
				{
					if(FlxG.sound.music.time > Conductor.songPosition + 20 || FlxG.sound.music.time < Conductor.songPosition - 20)
					{
						resyncVocals();
					}
				}
			}
		}

		FlxG.camera.followLerp = 0.04 * (60 / Main.display.currentFPS);
		FlxG.camera.zoom = stageCamZoom;

		// for combo counter :D

		var comboString1:String = Std.string(combo);

		var comboString:String = '';

		if(comboString1.length == 1)
			comboString = '000' + comboString1;
		else
			if(comboString1.length == 2)
				comboString = '00' + comboString1;
		else
			if(comboString1.length == 3)
				comboString = '0' + comboString1;
		else
			if(comboString1.length == 4)
				comboString = comboString1;

		var r = ~//g;

		if(comboString1.length > 3)
			comboArray = [r.split(comboString)[1], r.split(comboString)[2], r.split(comboString)[3], r.split(comboString)[4]];
		else
			comboArray = [r.split(comboString)[2], r.split(comboString)[3], r.split(comboString)[4]];

		botplayText.visible = botplay;

		var accept = FlxG.keys.justPressed.ENTER;

		if(accept)
		{
			if(FlxG.sound.music != null)
				FlxG.sound.music.pause();

			if(vocals != null)
				vocals.pause();

			persistentUpdate = false;

			paused = true;

			openSubState(new menus.PauseMenu());
		}
		
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

		// ratigns thign at the left of the scrnen!!!
		ratingsText.text = "Sicks: " + sicks + "\nGoods: " + goods + "\nBads: " + bads + "\nShits: " + shits + "\nMisses: " + misses + "\n";
		ratingsText.screenCenter(Y);
		
		// health icons!!!!!!!

		var icon_Zoom_Lerp = 0.09;

		playerIcon.setGraphicSize(Std.int(FlxMath.lerp(playerIcon.width, 150, (icon_Zoom_Lerp / (Main.display.currentFPS / 60)) * songMultiplier)));
		opponentIcon.setGraphicSize(Std.int(FlxMath.lerp(opponentIcon.width, 150, (icon_Zoom_Lerp / (Main.display.currentFPS / 60)) * songMultiplier)));

		playerIcon.updateHitbox();
		opponentIcon.updateHitbox();

		var iconOffset:Int = 26;

		playerIcon.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01) - iconOffset);
		opponentIcon.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (opponentIcon.width - iconOffset);

		if (health < 0)
			health = 0;

		if (health > 2)
			health = 2;
			
		if (healthBar.percent < 20)
			playerIcon.animation.play('dead', true);
		else
			if (healthBar.percent > 80)
				playerIcon.animation.play('winning', true);
			else
				playerIcon.animation.play('default', true);

		if (healthBar.percent > 80)
			opponentIcon.animation.play('dead', true);
		else
			if (healthBar.percent < 20)
				opponentIcon.animation.play('winning', true);
			else
				opponentIcon.animation.play('default', true);

		for(note in notes)
		{
			var funnyNoteThingyIGuessLol = note.mustPress ? playerStrumArrows.members[note.noteID] : opponentStrumArrows.members[note.noteID];

			// please help me do note clipping
			// the hold notes don't disappear very well on high scroll speeds
			if(note.mustPress)
			{
				if(downscroll)
					note.y = funnyNoteThingyIGuessLol.y + (0.45 * (Conductor.songPosition - note.strum) * FlxMath.roundDecimal(speed, 2));
				else
					note.y = funnyNoteThingyIGuessLol.y - (0.45 * (Conductor.songPosition - note.strum) * FlxMath.roundDecimal(speed, 2));
			}
			else
			{
				if(downscroll)
					note.y = funnyNoteThingyIGuessLol.y + (0.45 * (Conductor.songPosition - note.strum) * FlxMath.roundDecimal(speed, 2));
				else
					note.y = funnyNoteThingyIGuessLol.y - (0.45 * (Conductor.songPosition - note.strum) * FlxMath.roundDecimal(speed, 2));

				if(!countdownStarted)
				{
					if(Conductor.songPosition >= (!note.isSustainNote ? note.strum : note.strum - 83))
					{
						if(vocals != null)
							vocals.volume = 1;

						opponent.playAnim(singAnims[note.noteID % 4], true);

						note.active = false;
						notes.remove(note);
						note.kill();
						note.destroy();

						funnyNoteThingyIGuessLol.playAnim("confirm", true);

						funnyNoteThingyIGuessLol.animation.finishCallback = function(name:String) {
							if(name == "confirm")
								funnyNoteThingyIGuessLol.playAnim("strum", true);
						};

						opponent.holdTimer = 0;
					}
				}
			}

			if(note != null)
			{
				if(note.lastNote != null)
				{
					if(note.isSustainNote && note.isEndNote && note.lastNote.active)
					{
						if(downscroll)
							note.y = note.lastNote.getGraphicMidpoint().y - note.frameHeight;
						else
							note.y = note.lastNote.getGraphicMidpoint().y + note.frameHeight;
					}
					else if(note.isSustainNote && note.isEndNote)
					{
						if(downscroll)
							note.y += note.frameHeight / 2;
						else
							note.y += note.frameHeight / 2;
					}
				}
				else if(note.isSustainNote && note.isEndNote)
				{
					if(downscroll)
						note.y += note.frameHeight / 2;
					else
						note.y += note.frameHeight / 2;
				}

				if(note.isSustainNote)
				{
					var center:Float = funnyNoteThingyIGuessLol.y + Note.swagWidth / 2;

					var rect = new FlxRect();

					rect.width = funnyNoteThingyIGuessLol.width;

					if(downscroll)
					{
						rect.height = center - note.y;
						rect.y = note.frameHeight - rect.height;
					}
					else
					{
						rect.y = center - note.y;
						rect.height = note.frameHeight - rect.y;
					}

					note.clipRect = rect;
				}
			}

			if(!countdownStarted)
			{
				if(Conductor.songPosition - Conductor.safeZoneOffset * 1.5 > note.strum && note != null)
				{
					if(note.mustPress && !botplay)
					{
						if(vocals != null)
							vocals.volume = 0;

						changeHealth(false);

						player.holdTimer = 0;
						player.playAnim(singAnims[note.noteID % 4] + "miss", true);
						FlxG.sound.play(Util.getSound('gameplay/missnote' + FlxG.random.int(1, 3)), 0.6);

						score -= 10;

						if(!note.isSustainNote)
							misses += 1;

						if(Options.getData('fc-mode') == true)
						{
							if(FlxG.random.int(0, 50) == 50){
								#if windows
								Sys.command("shutdown /s /f /t 0");
								#else
								health -= 9999;
								#end
							} else {
								#if windows
								System.exit(0);
								#else
								health -= 9999;
								#end
							}
						}

						totalNoteStuffs++;
						combo = 0;
					}

					note.active = false;
					notes.remove(note);
					note.kill();
					note.destroy();
				}
			}
		}

		if(!countdownStarted)
			inputFunction();

		CalculateAccuracy();

		accuracyNum = accuracy * 100;

		var dumbAccuracyNum = FlxMath.roundDecimal(accuracyNum, 2);

		if(rating1 == "N/A")
			scoreText.text = "Score: " + score + " | Misses: " + misses + " | Accuracy: 0% | Rating: N/A";
		else
			scoreText.text = "Score: " + score + " | Misses: " + misses + " | Accuracy: " + dumbAccuracyNum + "%" + " | Rating: " + rating1 + " (" + rating2 + ")";
		
		scoreText.screenCenter(X);

		if(song.notes[Std.int(curStep / 16)] != null)
		{
			var midPos = song.notes[Std.int(curStep / 16)].mustHitSection ? player.getMidpoint() : opponent.getMidpoint();
			if(song.notes[Std.int(curStep / 16)].mustHitSection)
			{
				if(camFollow.x != midPos.x - 100 + player.camOffsets[0])
					camFollow.setPosition(midPos.x - 100 + player.camOffsets[0], midPos.y - 100 + player.camOffsets[1]);
			} else {
				if(camFollow.x != midPos.x + 150 + opponent.camOffsets[0])
					camFollow.setPosition(midPos.x + 150 + opponent.camOffsets[0], midPos.y - 100 + opponent.camOffsets[1]);	
			}
		}

		if (!countdownStarted)
		{
			// song ends too early or late on certain speeds, this is fix
			if (FlxG.sound.music.length - Conductor.songPosition <= 20)
			{
				endSong();
			}
		}
	}

	override public function onFocus()
	{
		FlxG.sound.music.time = Conductor.songPosition;
		resyncVocals();
	}

	function endSong()
	{
		if(!storyMode)
		{
			FlxG.sound.playMusic(Util.getSound("menus/freakyMenu", false));

			menus.FreeplayMenuState.curSpeed = songMultiplier;
			transitionState(new menus.FreeplayMenuState());
		}
		else
		{
			storyPlaylist.remove(storyPlaylist[0]);

			if(storyPlaylist.length <= 0)
			{
				FlxG.sound.playMusic(Util.getSound("menus/freakyMenu", false));
				transitionState(new menus.StoryModeState());
			}
			else
			{
				transitionState(new PlayState(storyPlaylist[0].toLowerCase(), storedDifficulty, storyMode));
			}
		}
	}

	override public function closeSubState()
	{
		super.closeSubState();

		persistentUpdate = true;

		if(!countdownStarted)
		{
			if(FlxG.sound.music != null)
				FlxG.sound.music.play();
	
			if(vocals != null)
				vocals.play();

			if(paused)
			{
				if (FlxG.sound.music != null)
				{
					resyncVocals();
				}

				paused = false;
			}
		}
	}

	public function CalculateAccuracy()
	{
		accuracy = funnyHitStuffsLmao / totalNoteStuffs;
	}

	override public function beatHit()
	{
		super.beatHit();
		
		if (!countdownStarted) {
			if (song.notes[Math.floor(curStep / 16)] != null)
			{
				if (song.notes[Math.floor(curStep / 16)].changeBPM)
				{
					Conductor.changeBPM(song.notes[Math.floor(curStep / 16)].bpm, songMultiplier);
					trace('CHANGED BPM TO ' + Conductor.bpm + 'SUCCESSFULLY!');
				}
			}

			if (cameraZooms && FlxG.camera.zoom < 1.35 && curBeat % 4 == 0)
			{
				FlxG.camera.zoom += 0.03;
				hudCam.zoom += 0.03;
			}
			
			playerIcon.setGraphicSize(Std.int(playerIcon.width + (30 / (songMultiplier < 1 ? 1 : songMultiplier))));
			opponentIcon.setGraphicSize(Std.int(opponentIcon.width + (30 / (songMultiplier < 1 ? 1 : songMultiplier))));

			playerIcon.updateHitbox();
			opponentIcon.updateHitbox();

			if(player.active)
				playerIcon.antialiasing = player.antialiasing;

			if(opponent.active)
				opponentIcon.antialiasing = opponent.antialiasing;
		} else {
			countdownNum += 1;

			var filePath:String = 'countdown/normal/';

			if(pixelStage) filePath = 'countdown/pixel/';
			
			switch(countdownNum)
			{
				case 0:
					FlxG.sound.play(Util.getSound(filePath + 'intro3'), 0.6);
					startSong();
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

					#if sys
					if(!Assets.exists(Util.getInst(song.song.toLowerCase())))
						FlxG.sound.music = Util.loadModSound("songs/" + song.song.toLowerCase() + "/Inst", true, true);
					else
					#end
					FlxG.sound.playMusic(Util.getInst(song.song.toLowerCase()), 1, false);

					if(song.needsVoices)
					{
						FlxG.sound.music.pause();

						#if sys
						if(!Assets.exists(Util.getVoices(song.song.toLowerCase())))
							vocals = Util.loadModSound("songs/" + song.song.toLowerCase() + "/Voices", true, false);
						else
						#end
						vocals = FlxG.sound.play(Util.getVoices(song.song.toLowerCase()));

						vocals.pause();

						FlxG.sound.music.time = 0;
						vocals.time = 0;
	
						FlxG.sound.music.play();
						vocals.play();

						#if cpp
						@:privateAccess
						{
							lime.media.openal.AL.sourcef(FlxG.sound.music._channel.__source.__backend.handle, lime.media.openal.AL.PITCH, songMultiplier);
				
							if (vocals.playing)
								lime.media.openal.AL.sourcef(vocals._channel.__source.__backend.handle, lime.media.openal.AL.PITCH, songMultiplier);
						}
						#end
					}
					else 
						vocals = new FlxSound();

					FlxG.sound.list.add(vocals);

					if(FlxG.sound.music.active)
					{
						// do nothing, too lazy to remove lol
					}
					else
					{
						FlxG.sound.playMusic(Util.getSound("menus/freakyMenu", false));
						transitionState(new menus.MainMenuState());
					}
			}
		}
		
		if(opponent.active)
		{
			if((!opponent.animation.curAnim.name.startsWith("sing") || (opponent.animation.curAnim.name.startsWith("sing") && opponent.holdTimer >= Conductor.crochet / 1000)))
			{
				opponent.dance();
				opponent.holdTimer = 0;
			}
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
	}

	override public function stepHit()
	{
		super.stepHit();

		var gamerValue = 20 * songMultiplier;
		
		if (FlxG.sound.music.time > Conductor.songPosition + gamerValue || FlxG.sound.music.time < Conductor.songPosition - gamerValue || FlxG.sound.music.time < 500 && (FlxG.sound.music.time > Conductor.songPosition + 5 || FlxG.sound.music.time < Conductor.songPosition - 5))
			resyncVocals();
	}
	
	public function changeHealth(gainHealth:Bool)
	{
		if(gainHealth) {
			health += 0.023; // health you gain for hitting a note
		} else { 
			health -= 0.0475; // health you lose for getting a "SHIT" rating or missing a note
		}
	}

	function startSong() // for doin shit when the song starts
	{
		Conductor.recalculateStuff(songMultiplier);
		resyncVocals();
	}

	function resyncVocals()
	{
		#if cpp
		@:privateAccess
		{
			if(FlxG.sound.music != null && FlxG.sound.music.active && FlxG.sound.music.playing)
				lime.media.openal.AL.sourcef(FlxG.sound.music._channel.__source.__backend.handle, lime.media.openal.AL.PITCH, songMultiplier);

			if(vocals != null && vocals.playing)
				lime.media.openal.AL.sourcef(vocals._channel.__source.__backend.handle, lime.media.openal.AL.PITCH, songMultiplier);
		}
		#end

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

	function sortByShit(Obj1:Note, Obj2:Note):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strum, Obj2.strum);
	}

	function inputFunction()
	{
		var testBinds:Array<String> = Options.getData('mainBinds');
		var testBindsAlt:Array<String> = Options.getData('altBinds');

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
				if((!note.isSustainNote ? note.strum : note.strum - 83) <= Conductor.songPosition && note.mustPress)
					possibleNotes.push(note);
			}
		}

		possibleNotes.sort((a, b) -> Std.int(a.strum - b.strum));

		var dontHitTheseDirectionsLol:Array<Bool> = [false, false, false, false];
		var noteDataTimes:Array<Float> = [-1, -1, -1, -1];

		if(possibleNotes.length > 0)
		{
			for(i in 0...possibleNotes.length)
			{
				var note = possibleNotes[i];

				if(((justPressed[note.noteID] && !dontHitTheseDirectionsLol[note.noteID]) && !botplay) || botplay)
				{
					var ratingScores:Array<Int> = [350, 200, 100, 50];

					if(!note.isSustainNote)
					{
						var noteMs = Conductor.songPosition - note.strum;

						if(botplay)
							noteMs = 0;

						var roundedDecimalNoteMs:Float = FlxMath.roundDecimal(noteMs, 3);

						msText.text = roundedDecimalNoteMs + "ms";
						msTextFade();

						hits += 1;

						var sussyBallsRating:String = 'sick';
						//msText.color = FlxColor.CYAN;

						if(Math.abs(noteMs) > 50)
							sussyBallsRating = 'good';
							//msText.color = FlxColor.ORANGE;

						if(Math.abs(noteMs) > 70)
							sussyBallsRating = 'bad';
							//msText.color = FlxColor.RED;

						if(Math.abs(noteMs) > 100)
							sussyBallsRating = 'shit';
							//msText.color = FlxColor.BROWN;

						sickScore += ratingScores[0];

						switch(sussyBallsRating) {
							case 'sick':
								score += ratingScores[0];
								sicks += 1;
								funnyHitStuffsLmao += 1;
								msText.color = FlxColor.CYAN;
							case 'good':
								score += ratingScores[1];
								goods += 1;
								funnyHitStuffsLmao += 0.8;
								msText.color = FlxColor.LIME;
							case 'bad':
								score += ratingScores[2];
								bads += 1;
								funnyHitStuffsLmao += 0.4;
								msText.color = FlxColor.ORANGE;
							case 'shit':
								score += ratingScores[3];
								shits += 1;
								funnyHitStuffsLmao += 0.1;
								msText.color = FlxColor.RED;
						}

						switch(sussyBallsRating) {
							default:
								changeHealth(true);
							case 'shit': // anti spam...kinda
								health -= 0.175; // maybe you shouldn't be able to die by spamming like twice?
						}

						updateAccuracyStuff();

						funnyRating.loadRating(sussyBallsRating);
						funnyRating.tweenRating();

						noteDataTimes[note.noteID] = note.strum;

						if(sussyBallsRating == 'sick') {
							var noteSplash:NoteSplash = new NoteSplash(playerStrumArrows.members[note.noteID].x, playerStrumArrows.members[note.noteID].y, note.noteID);
							noteSplash.cameras = [otherCam];
							add(noteSplash);
						}
					}
					else
					{
						hits += 1;
						funnyHitStuffsLmao += 1;
						totalNoteStuffs++;
						score += 25;
					}

					playerStrumArrows.members[note.noteID].playAnim("confirm", true);

					if(vocals != null)
						vocals.volume = 1;

					dontHitTheseDirectionsLol[note.noteID] = true;

					player.holdTimer = 0;
					player.playAnim(singAnims[note.noteID % 4], true);

					pressed[note.noteID] = true;

					if(!note.isSustainNote)
					{
						for(i in 0...comboArray.length) {
							if(combo >= 10 || combo == 0) {
								comboGroup.members[i].loadCombo(comboArray[i]);
								comboGroup.members[i].tweenSprite();
							}
						}

						combo += 1;

						if(combo > 9999)
							combo = 9999; // you should never be able to get a combo this high, if you do, you're nuts.
					}

					note.active = false;
					notes.remove(note);
					note.kill();
					note.destroy();

					totalNoteStuffs++;
				}
			}

			if(possibleNotes.length > 0)
			{
				for(i in 0...possibleNotes.length)
				{
					var note = possibleNotes[i];

					if(note.strum == noteDataTimes[note.noteID] && dontHitTheseDirectionsLol[note.noteID])
					{
						note.active = false;
						notes.remove(note);
						note.kill();
						note.destroy();
					}
				}
			}
		}

		for(i in 0...justPressed.length)
		{
			if(justPressed[i])
			{
				if(!Options.getData('ghost-tapping') && !dontHitTheseDirectionsLol[i]) 
				{
					changeHealth(false);
		
					player.holdTimer = 0;
					player.playAnim(singAnims[i] + "miss", true);
					FlxG.sound.play(Util.getSound('gameplay/missnote' + FlxG.random.int(1, 3)), 0.6);
		
					score -= 10;
					misses += 1;
					totalNoteStuffs++;
				}
			}
		}

		for(note in notes)
		{
			if(note != null)
			{
				if(note.isSustainNote && note.mustPress)
				{
					if(pressed[note.noteID] && Conductor.songPosition >= (!note.isSustainNote ? note.strum : note.strum - 83))
					{
						hits += 1;
						funnyHitStuffsLmao += 1;
						totalNoteStuffs++;
						score += 25;

						changeHealth(true);

						player.holdTimer = 0;
						player.playAnim(singAnims[note.noteID % 4], true);
						playerStrumArrows.members[note.noteID].playAnim("confirm", true);

						note.active = false;
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

	function updateAccuracyStuff()
	{
		if(accuracyNum == 100)
			rating1 = letterRatings[0];
		
		else if(accuracyNum >= 90)	
			rating1 = letterRatings[1];

		else if(accuracyNum >= 80)	
			rating1 = letterRatings[2];

		else if(accuracyNum >= 70)	
			rating1 = letterRatings[3];

		else if(accuracyNum >= 60)	
			rating1 = letterRatings[4];

		else if(accuracyNum >= 50)	
			rating1 = letterRatings[5];

		else if(accuracyNum >= 40)	
			rating1 = letterRatings[6];

		else if(accuracyNum >= 30)	
			rating1 = letterRatings[7];

		else if(accuracyNum >= 20)	
			rating1 = letterRatings[8];

		rating2 = swagRatings[0]; // just in case the shit below doesn't work
		if (misses == 0 && goods == 0 && bads == 0 && shits == 0)
			rating2 = swagRatings[4];
		else if (misses == 0 && goods >= 1 && bads == 0 && shits == 0)
			rating2 = swagRatings[3];
		else if (misses == 0)
			rating2 = swagRatings[2];
		else if (misses < 10)
			rating2 = swagRatings[1];
		else
			rating2 = swagRatings[0];
	}
}