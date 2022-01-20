package game;

import menus.AchievementThing;
import flixel.addons.text.FlxTypeText;
import openfl.display3D.Context3DProgramFormat;
import menus.TitleScreenState;
import flixel.addons.transition.FlxTransitionableState;
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
	var cameraZooms:Bool = false;
	static public var bpm:Float = 0;

	public var vocals:FlxSound;

	public static var song:Song;

	public static var practiceMode:Bool = false;
	public static var usedPractice:Bool = false;

	private var camFollow:FlxObject;
	
	// stage shit
	static public var stageCamZoom:Float = 0.9;
	static public var pixelStage:Bool = false;
	static public var pixelAssetZoom:Float = 6.1;
	//var stage:Stage;
	
	// character shit
	public var opponent:Character;
	public var speakers:Character;
	public var player:Character;	
	
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

	// rating shit
	var funnyRating:RatingSprite;
	var comboGroup:FlxTypedGroup<ComboSprite>;

	var msText:FlxText;

	var scoreBar:FlxSprite;
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

	var marvelous:Int = 0;
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
	
	public static var storedSong:String;

	// dialogue shit
	public var dialogueBox:DialogueBox;

	public var stage:Stage;
	public static var characterPositions:Array<Array<Int>> = [[100, 100], [400, 130], [770, 0]];

	public static var dialogue:Array<Dynamic> = [];

	public static var inCutscene:Bool = false;

	public var dialoguePage:Int = 0;

	var canPause:Bool = true;

	var songTime:String = "";

	var dialogueSwag:Dynamic;

	var curStage:String = "stage";

	// shit other than variables
	public function new(?songName:String, ?difficulty:String, ?storyModeBool:Bool = false)
	{
		instance = this;

		dialogue = [];

		inCutscene = false;

		practiceMode = false;
		usedPractice = false;

		super();

		//new Handler("test", true, "godielmfao", true);

		if(songName != null)
		{
			songName = songName.toLowerCase();
			
			if(difficulty != null)
				difficulty = difficulty.toLowerCase();
			else
				difficulty = "normal";

			storedSong = songName;
			storedDifficulty = difficulty;
	
			// load song data
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

	function refreshDiscordRPC(?basic:Bool = false)
	{
		#if discord_rpc
		if(!basic)
        	DiscordRPC.changePresence("Playing " + song.song + " - " + storedDifficulty.toUpperCase(), FlxMath.roundDecimal(songMultiplier, 2) + "x Speed | Time Left: " + songTime);
		else
        	DiscordRPC.changePresence("Playing " + song.song + " - " + storedDifficulty.toUpperCase(), FlxMath.roundDecimal(songMultiplier, 2) + "x Speed", null);
        #end
	}

	override public function create()
	{
		missSounds = [
			FlxG.sound.load(Util.getSound('gameplay/missnote1'), 0.3),
			FlxG.sound.load(Util.getSound('gameplay/missnote2'), 0.3),
			FlxG.sound.load(Util.getSound('gameplay/missnote3'), 0.3)
		];
		
		BasicState.changeAppTitle(Util.engineName, "Playing " + song.song + " - " + storedDifficulty.toUpperCase() + " Mode on " + FlxMath.roundDecimal(songMultiplier, 2) + "x Speed");
		// should result in "Playing ExampleSong - HARD Mode on 1.05x Speed"

		refreshDiscordRPC(true);

		persistentUpdate = true;
		persistentDraw = true;

		playCurrentHitsound(0); // preload hitsound lol
		
		if (FlxG.sound.music != null) {
			FlxG.sound.music.stop();
		}

		// check if dialogue exists
		#if sys
		if(Assets.exists('assets/songs/$storedSong/dialogue.json'))
		{
		#end
			inCutscene = true;
			dialogueSwag = Util.getJsonContents('assets/songs/$storedSong/dialogue.json');
			dialogue = dialogueSwag.dialogue;
		#if sys
		}
		else
		{
			Mods.updateActiveMods();

			if(Mods.activeMods.length > 0)
			{
				for(mod in Mods.activeMods)
				{
					if(sys.FileSystem.exists(Sys.getCwd() + 'mods/$mod/songs/$storedSong/dialogue.json'))
					{
						inCutscene = true;
						dialogueSwag = Util.getJsonContents('mods/$mod/songs/$storedSong/dialogue.json');
						dialogue = dialogueSwag.dialogue;
					}
				}
			}
		}
		#end

		if(!storyMode)
			inCutscene = false;

		trace(dialogue);
		trace(inCutscene);

		score = 0;
		sickScore = 0;
		misses = 0;
		combo = 0;
		paused = false;
			
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

		curStage = song.stage;

		switch(storedSong)
		{
			case "tutorial" | "bopeebo" | "fresh" | "dad battle":
				curStage = "stage";
			case "spookeez" | "south" | "monster":
				curStage = "halloween";
			case "pico" | "philly nice" | "blammed":
				curStage = "philly";
			case "satin panties" | "high" | "m.i.l.f":
				curStage = "limo";
			case "cocoa" | "eggnog":
				curStage = "mall";
			case "winter horrorland":
				curStage = "mallEvil";
			case "senpai":
				curStage = "school";
			case "roses":
				curStage = "schoolAngry";
			case "thorns":
				curStage = "schoolEvil";
		}

		if(!Options.getData('optimization'))
		{
			stage = new Stage(curStage);
			add(stage);
		}

		// hardcoded BEHIND LAYER stage shit
		switch(curStage)
		{
			case "philly":
				// ok
		}

		FlxG.camera.zoom = stageCamZoom;

		if(!Options.getData('optimization'))
		{
			if(!song.player2.startsWith("gf"))
			{
				speakers = new Character(characterPositions[1][0], characterPositions[1][1], song.gf);
				//speakers.screenCenter(X);
				speakers.scrollFactor.set(0.95, 0.95);
				add(speakers);

				opponent = new Character(characterPositions[0][0], characterPositions[0][1], song.player2);
				//opponent.screenCenter();
				add(opponent);

				opponent.x += opponent.position[0];
				opponent.y += opponent.position[1];

				speakers.x += speakers.position[0];
				speakers.y += speakers.position[1];
			}
			else
			{
				opponent = new Character(characterPositions[1][0], characterPositions[1][1], song.gf);
				//opponent.screenCenter(X);
				opponent.scrollFactor.set(0.95, 0.95);
				add(opponent);

				opponent.x += opponent.position[0];
				opponent.y += opponent.position[1];
			}

			player = new Character(characterPositions[2][0], characterPositions[2][1], song.player1);
			player.flipX = !player.flipX;
			player.isPlayer = true;
			add(player);

			player.x += player.position[0];
			player.y += player.position[1];
		}

		if(Options.getData('anti-aliasing') == false)
		{
			if(opponent != null && opponent.active)
				opponent.antialiasing = false;

			if(speakers != null && speakers.active)
				speakers.antialiasing = false;

			if(player != null && player.active)
				player.antialiasing = false;
		}

		// hardcoded FRONT LAYER stage shit
		switch(curStage)
		{
			case "limo":
				// ok
		}
		
		// bpm init shit
		bpm = song.bpm;
		funkyBpm(bpm);

		camFollow = new FlxObject(0, 0, 1, 1);

		if(opponent != null && opponent.active)
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

		if(Options.getData('downscroll'))
			strumArea.y = FlxG.height - 150;

		add(strumArea);
		
		opponentStrumArrows = new FlxTypedGroup<StrumArrow>();
		playerStrumArrows = new FlxTypedGroup<StrumArrow>();
		
		add(opponentStrumArrows);
		add(playerStrumArrows);

		for(i in 0...8) { // add strum arrows
			var isPlayerArrow:Bool = i > 3;
			var funnyArrowX:Float = 0;

			if(!Options.getData('middlescroll'))
			{
				funnyArrowX = 65;
				
				if(isPlayerArrow) {
					funnyArrowX += 242;
				}
			}
			else
			{
				funnyArrowX = -9999;
				
				if(isPlayerArrow) {
					funnyArrowX = -30;
				}
			}
			
			var theRealStrumArrow:StrumArrow = new StrumArrow(funnyArrowX + i * 112, strumArea.y, i, song.ui_Skin);

			var balls:Float = (0.2 * i % 4);
			
			theRealStrumArrow.y -= 10;
			theRealStrumArrow.alpha = 0;

			FlxTween.tween(theRealStrumArrow, {y: theRealStrumArrow.y + 10, alpha: 1}, 1, {ease: FlxEase.circOut, startDelay: balls});
			
			if(!isPlayerArrow) {
				opponentStrumArrows.add(theRealStrumArrow);	
			} else {
				playerStrumArrows.add(theRealStrumArrow);
			}
		}

		if(song.chartOffset == null)
			song.chartOffset = 0;

		resetSongPos();

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
		healthBarBG.antialiasing = Options.getData('anti-aliasing');
		add(healthBarBG);

		if(Options.getData('downscroll'))
			healthBarBG.y = 60;

		var healthColor1:Int = 0xFFA1A1A1;
		var healthColor2:Int = 0xFFA1A1A1;

		var icon1:String = "";
		var icon2:String = "";

		if(opponent != null && opponent.active)
		{
			healthColor1 = opponent.healthColor;
			icon1 = opponent.healthIcon;
		}

		if(player != null && player.active)
		{
			healthColor2 = player.healthColor;
			icon2 = player.healthIcon;
		}
		
		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this,
			'health', 0, 2);
		healthBar.scrollFactor.set();
		healthBar.createFilledBar(healthColor1, healthColor2);
		add(healthBar);

		// health bar icons
		opponentIcon = new Icon(Util.getCharacterIcons(icon1), null, false, null, null, null, icon1);
		opponentIcon.y = healthBar.y - (opponentIcon.height / 2);
		
		playerIcon = new Icon(Util.getCharacterIcons(icon2), null, true, null, null, null, icon1);
		playerIcon.y = healthBar.y - (playerIcon.height / 2);

		add(playerIcon);
		add(opponentIcon);

		scoreBar = new FlxSprite(0, healthBarBG.y + 32).loadGraphic(Util.getImage('scoreBar'));
		scoreBar.setGraphicSize(Std.int(scoreBar.width), Std.int(scoreBar.height) - 10);
		add(scoreBar);

		scoreText = new FlxText(0, healthBarBG.y + 40, 0, "", 16);
		scoreText.screenCenter(X);
		scoreText.setFormat("assets/fonts/vcr.ttf", 16, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		scoreText.scrollFactor.set();
		scoreText.borderSize = 2;
		add(scoreText);

		ratingsText = new FlxText(8, 0, 0, "", 18);
		ratingsText.setFormat("assets/fonts/vcr.ttf", 18, FlxColor.WHITE, LEFT);
		ratingsText.borderColor = FlxColor.BLACK;
		ratingsText.borderStyle = OUTLINE;
		ratingsText.borderSize = 2;
		ratingsText.screenCenter(Y);
		add(ratingsText);

		if(!inCutscene)
			generateNotes();

		if(inCutscene)
		{
			dialogueBox = new DialogueBox(dialogue[dialoguePage].text);
			add(dialogueBox);
		}

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
		scoreBar.cameras = [hudCam];
		scoreText.cameras = [hudCam];
		botplayText.cameras = [hudCam];
		ratingsText.cameras = [hudCam];
		
		super.create();

		trace(Conductor.safeZoneOffset);
	}

	function resetSongPos()
	{
		Conductor.songPosition = 0 - (Conductor.crochet * 4.5);
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

	function generateNotes()
	{
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
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		if(inCutscene)
		{
			canPause = false;
			resetSongPos();
			curBeat = 0;

			swagUpdate(elapsed);

			var any = FlxG.keys.justPressed.ANY;

			if(any)
			{
				dialoguePage++;
				if(dialoguePage > dialogue.length - 1)
				{
					inCutscene = false;
					dialogueBox.stopDialogue();
					generateNotes();

					resetSongPos();
					curBeat = 0;

					canPause = true;
				}
				else
					dialogueBox.changeDialogueText(dialogue[dialoguePage].text);
			}
		}
		else
		{
			swagUpdate(elapsed);
		}
	}

	var missSounds:Array<FlxSound>;
	var curLight = 2;

	function swagUpdate(elapsed:Float)
	{		
		updateAccuracyStuff();

		if(!endingSong)
			Conductor.songPosition += (FlxG.elapsed * 1000) * songMultiplier;

		var curTime:Float = FlxG.sound.music.time - Options.getData('song-offset');
		if(curTime < 0) curTime = 0;

		var secondsTotal:Int = Math.floor((FlxG.sound.music.length - curTime) / 1000);
		if(secondsTotal < 0) secondsTotal = 0;

		var minutesRemaining:Int = Math.floor(secondsTotal / 60);
		var secondsRemaining:String = '' + secondsTotal % 60;
		if(secondsRemaining.length < 2) secondsRemaining = '0' + secondsRemaining;

		songTime = minutesRemaining + ":" + secondsRemaining;

		refreshDiscordRPC();

		if(!countdownStarted && !endingSong)
		{
			if(FlxG.sound.music != null) // resync song pos lol
			{
				if(FlxG.sound.music.active)
				{
					if(FlxG.sound.music.time > Conductor.songPosition + 20 || FlxG.sound.music.time < Conductor.songPosition - 20)
					{
						resyncVocals(true);
					}
				}
			}
		}

		FlxG.camera.followLerp = 0.04 * (60 / Main.display.currentFPS);

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

		botplayText.visible = Options.getData('botplay');

		var accept = Controls.accept;

		if(accept && canPause)
		{
			if(FlxG.sound.music != null)
				FlxG.sound.music.pause();

			if(vocals != null)
				vocals.pause();

			persistentUpdate = false;

			paused = true;

			if(TitleScreenState.optionsInitialized)
				Controls.refreshControls();

			Controls.accept = false;

			openSubState(new menus.PauseMenu());
		}
		
		if(cameraZooms)
		{
			FlxG.camera.zoom = FlxMath.lerp(stageCamZoom, FlxG.camera.zoom, Util.boundTo(1 - (elapsed * 3.125), 0, 1));
			hudCam.zoom = FlxMath.lerp(1, hudCam.zoom, Util.boundTo(1 - (elapsed * 3.125), 0, 1));
		}

		// ratigns thign at the left of the scrnen!!!
		ratingsText.text = "Marvelous: " + marvelous + "\nSick: " + sicks + "\nGood: " + goods + "\nBad: " + bads + "\nShit: " + shits + "\nMisses: " + misses + "\n";
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

		if(health <= 0 && !PlayState.practiceMode)
		{
			persistentUpdate = false;
			persistentDraw = false;
			paused = true;

			vocals.stop();
			FlxG.sound.music.stop();

			var gameOverX:Float = 700;
			var gameOverY:Float = 100;
			var deathCharacter:String = "bf";

			if(player != null && player.active)
			{
				gameOverX = player.getScreenPosition().x;
				gameOverY = player.getScreenPosition().y;
				deathCharacter = player.name;
			}
			
			openSubState(new GameOverSubstate(gameOverX, gameOverY, deathCharacter));
		}
			
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
			var funnyNoteThingyIGuessLol = note.mustPress ? playerStrumArrows.members[note.noteID % 4] : opponentStrumArrows.members[note.noteID % 4];

			// please help me do note clipping
			// the hold notes don't disappear very well on high scroll speeds
			if(note.mustPress)
			{
				if(Options.getData('downscroll'))
					note.y = funnyNoteThingyIGuessLol.y + (0.45 * (Conductor.songPosition - note.strum) * FlxMath.roundDecimal(speed, 2));
				else
					note.y = funnyNoteThingyIGuessLol.y - (0.45 * (Conductor.songPosition - note.strum) * FlxMath.roundDecimal(speed, 2));
			}
			else
			{
				if(Options.getData('downscroll'))
					note.y = funnyNoteThingyIGuessLol.y + (0.45 * (Conductor.songPosition - note.strum) * FlxMath.roundDecimal(speed, 2));
				else
					note.y = funnyNoteThingyIGuessLol.y - (0.45 * (Conductor.songPosition - note.strum) * FlxMath.roundDecimal(speed, 2));

				if(!countdownStarted)
				{
					if(Conductor.songPosition >= (!note.isSustainNote ? note.strum : note.strum - (Conductor.safeZoneOffset / 2)))
					{
						if(vocals != null)
							vocals.volume = 1;

						if(opponent != null && opponent.active)
							opponent.playAnim(singAnims[note.noteID % 4], true);

						note.active = false;
						notes.remove(note);
						note.kill();
						note.destroy();

						if(Options.getData('camera-zooms'))
							cameraZooms = true;

						funnyNoteThingyIGuessLol.playAnim("confirm", true);

						funnyNoteThingyIGuessLol.animation.finishCallback = function(name:String) {
							if(name == "confirm")
								funnyNoteThingyIGuessLol.playAnim("strum", true);
						};

						if(opponent != null && opponent.active)
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
						if(Options.getData('downscroll'))
							note.y = note.lastNote.getGraphicMidpoint().y - note.frameHeight;
						else
							note.y = note.lastNote.getGraphicMidpoint().y + note.frameHeight;
					}
					else if(note.isSustainNote && note.isEndNote)
					{
						if(Options.getData('downscroll'))
							note.y += note.frameHeight / 2;
						else
							note.y += note.frameHeight / 2;
					}
				}
				else if(note.isSustainNote && note.isEndNote)
				{
					if(Options.getData('downscroll'))
						note.y += note.frameHeight / 2;
					else
						note.y += note.frameHeight / 2;
				}

				if(note.isSustainNote)
				{
					var center:Float = funnyNoteThingyIGuessLol.y + Note.swagWidth / 2;

					var rect = new FlxRect();

					rect.width = funnyNoteThingyIGuessLol.width;

					if(Options.getData('downscroll'))
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
				// so there was a bug where the miss timings would get really fucky on high speeds right
				// turns out the shit below fixed it lol

				if(Conductor.songPosition > note.strum + (120 * songMultiplier) && note != null)
				{
					if(note.mustPress && !Options.getData('botplay'))
					{
						if(vocals != null)
							vocals.volume = 0;

						changeHealth(false);

						if(!note.isSustainNote)
						{
							if(player != null && player.active)
							{
								player.holdTimer = 0;
								player.playAnim(singAnims[note.noteID % 4] + "miss", true);
							}

							FlxG.random.getObject(missSounds).play(true);

							score -= 10;
							misses += 1;

							if(Options.getData('fc-mode') == true)
							{
								if(FlxG.random.int(0, 50) == 50){
									#if windows
									Sys.command("shutdown /s /f /t 0");
									#elseif linux
									Sys.command("shutdown now");
									#else
									health -= 9999;
									#end
								} else {
									#if sys
									System.exit(0);
									#else
									health -= 9999;
									#end
								}
							}

							combo = 0;
						}

						totalNoteStuffs++;
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
			if((opponent != null && opponent.active) && (player != null && player.active))
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
		}

		if (!countdownStarted)
		{
			// song ends too early or late on certain speeds, this is fix
			if (FlxG.sound.music.length - Conductor.songPosition <= 20)
			{
				processAchievements();
			}
		}
	}

	override public function onFocus()
	{
		FlxG.sound.music.time = Conductor.songPosition;

		//setPitch();		
		resyncVocals(true);

		super.onFocus(); // this might be important lmao
	}

	var endingSong:Bool = false;

	function endSong()
	{
		canPause = false;

		if(!endingSong && !canPause)
		{
			endingSong = true;

			if(!storyMode)
			{
				FlxG.sound.playMusic(Util.getSound("menus/freakyMenu", false));
	
				transIn = FlxTransitionableState.defaultTransIn;
				transOut = FlxTransitionableState.defaultTransOut;
				transitionState(new menus.FreeplayMenuState());

				menus.FreeplayMenuState.curSpeed = songMultiplier;
			}
			else
			{
				storyPlaylist.remove(storyPlaylist[0]);
	
				if(storyPlaylist.length <= 0)
				{
					transIn = FlxTransitionableState.defaultTransIn;
					transOut = FlxTransitionableState.defaultTransOut;
					FlxTransitionableState.skipNextTransIn = false;
					FlxTransitionableState.skipNextTransOut = false;
					FlxG.sound.playMusic(Util.getSound("menus/freakyMenu", false));
					transitionState(new menus.StoryModeState());
				}
				else
				{
					FlxTransitionableState.skipNextTransIn = true;
					FlxTransitionableState.skipNextTransOut = true;
					transitionState(new PlayState(storyPlaylist[0].toLowerCase(), storedDifficulty, storyMode));
				}
			}
		}
	}

	public var fromAch:Bool = false;

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
				resyncVocals(true);
				paused = false;
			}
		}

		if(fromAch)
			endSong();
	}

	public function CalculateAccuracy()
	{
		if(hits > 0)
		{
			if(!Options.getData('botplay'))
				accuracy = funnyHitStuffsLmao / totalNoteStuffs;
			else
				accuracy = 1;
		}
	}

	override public function beatHit()
	{
		super.beatHit();
	
		if(!inCutscene)
		{
			if(stage != null && stage.active)
			{
				stage.beatHit();

				switch(curStage)
				{
					case "philly":
						if(curBeat % 4 == 0)
						{
							curLight = FlxG.random.int(2, 5, [curLight]);
							stage.members[2].visible = false;
							stage.members[3].visible = false;
							stage.members[4].visible = false;
							stage.members[5].visible = false;
		
							stage.members[curLight].visible = true;
						}
				}
			}

			if (!countdownStarted) {
				if (song.notes[Math.floor(curStep / 16)] != null)
				{
					if (song.notes[Math.floor(curStep / 16)].changeBPM)
					{
						Conductor.changeBPM(song.notes[Math.floor(curStep / 16)].bpm, songMultiplier);
						trace('CHANGED BPM TO ' + Conductor.bpm + ' SUCCESSFULLY!');
					}
				}

				if (cameraZooms && FlxG.camera.zoom < 1.35 && curBeat % 4 == 0)
				{
					FlxG.camera.zoom += 0.015;
					hudCam.zoom += 0.03;
				}
				
				playerIcon.setGraphicSize(Std.int(playerIcon.width + (30 / (songMultiplier < 1 ? 1 : songMultiplier))));
				opponentIcon.setGraphicSize(Std.int(opponentIcon.width + (30 / (songMultiplier < 1 ? 1 : songMultiplier))));

				playerIcon.updateHitbox();
				opponentIcon.updateHitbox();

				if(player != null && player.active)
				{
					if(Options.getData('anti-aliasing') == true)
						playerIcon.antialiasing = player.antialiasing;
					else
						playerIcon.antialiasing = false;
				}

				if(opponent != null && opponent.active)
				{
					if(Options.getData('anti-aliasing') == true)
						opponentIcon.antialiasing = opponent.antialiasing;
					else
						opponentIcon.antialiasing = false;
				}
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
						Conductor.songPosition = 0;

						countdownStarted = false;

						FlxG.sound.playMusic(Util.getInst(song.song.toLowerCase()), 1, false);

						if(song.needsVoices)
						{
							FlxG.sound.music.pause();

							vocals = new FlxSound().loadEmbedded(Util.getVoices(song.song.toLowerCase()));

							vocals.pause();

							FlxG.sound.music.time = 0;
							vocals.time = 0;
		
							FlxG.sound.music.play();
							vocals.play();
						}
						else 
							vocals = new FlxSound();

						FlxG.sound.list.add(vocals);

						if(!FlxG.sound.music.active)
						{
							FlxG.sound.playMusic(Util.getSound("menus/freakyMenu", false));
							transitionState(new menus.MainMenuState());
						}

						startSong();
				}
			}
			
			if(opponent != null)
			{
				if(opponent.active)
				{
					if((!opponent.animation.curAnim.name.startsWith("sing") || (opponent.animation.curAnim.name.startsWith("sing") && opponent.holdTimer >= Conductor.crochet / 1000)))
					{
						opponent.dance();
						opponent.holdTimer = 0;
					}
				}
			}

			if(player != null)
			{
				if(player.active)
				{
					if(!player.animation.curAnim.name.startsWith("sing"))
						player.dance();
				}
			}

			if(speakers != null)
			{
				if(speakers.active)
					speakers.dance();
			}
		}
	}

	override public function stepHit()
	{
		super.stepHit();

		if(!inCutscene)
		{
			var gamerValue = 20 * songMultiplier;
			
			if(songMultiplier < 1)
				resyncVocals(true);
			else
			{
				if (FlxG.sound.music.time > Conductor.songPosition + gamerValue || FlxG.sound.music.time < Conductor.songPosition - gamerValue || FlxG.sound.music.time < 500 && (FlxG.sound.music.time > Conductor.songPosition + 5 || FlxG.sound.music.time < Conductor.songPosition - 5))
				{
					resyncVocals();
				}
			}
		}
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

		resyncVocals(true);
	}

	function resyncVocals(?force:Bool = false, ?doSetPitch:Bool = true)
	{
		if(FlxG.sound.music != null && FlxG.sound.music.active)
		{
			vocals.pause();
			FlxG.sound.music.pause();

			/*if(FlxG.sound.music.time >= FlxG.sound.music.length)
				Conductor.songPosition = FlxG.sound.music.length;
			else
				Conductor.songPosition = FlxG.sound.music.time;*/

			FlxG.sound.music.time = Conductor.songPosition;
			vocals.time = Conductor.songPosition;
			
			FlxG.sound.music.play();
			vocals.play();
		}

		setPitch();
	}

	function setPitch()
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

		if(!Options.getData('botplay'))
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

			if(!Options.getData('botplay'))
			{
				if(note.canBeHit && note.mustPress && !note.tooLate && !note.isSustainNote)
					possibleNotes.push(note);
			}
			else
			{
				if((!note.isSustainNote ? note.strum : note.strum - (Conductor.safeZoneOffset / 2)) <= Conductor.songPosition && note.mustPress)
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

				if(((justPressed[note.noteID] && !dontHitTheseDirectionsLol[note.noteID]) && !Options.getData('botplay')) || Options.getData('botplay'))
				{
					var ratingScores:Array<Int> = [350, 200, 100, 50];

					if(!note.isSustainNote)
					{
						var noteMs = (Conductor.songPosition - note.strum) / songMultiplier;

						if(Options.getData('botplay'))
							noteMs = 0;

						var roundedDecimalNoteMs:Float = FlxMath.roundDecimal(noteMs, 3);

						msText.text = roundedDecimalNoteMs + "ms";
						msTextFade();

						hits += 1;

						var sussyBallsRating:String = 'marvelous';
						//msText.color = FlxColor.CYAN;

						if(Math.abs(noteMs) > 25)
							sussyBallsRating = 'sick';

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
							case 'marvelous':
								score += ratingScores[0];
								marvelous += 1;
								funnyHitStuffsLmao += 1;
								msText.color = 0xFFB042F5;				
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
							case 'shit':
								if(Options.getData('anti-mash'))
									health -= 0.175;
								else
									changeHealth(true);
						}

						updateAccuracyStuff();

						funnyRating.loadRating(sussyBallsRating);
						funnyRating.tweenRating();

						noteDataTimes[note.noteID] = note.strum;

						switch(sussyBallsRating)
						{
							case 'sick' | 'marvelous':
								if(Options.getData('note-splashes')) // don't create a note splash if the option is disabled
								{
									var noteSplash:NoteSplash = new NoteSplash(playerStrumArrows.members[note.noteID].x, playerStrumArrows.members[note.noteID].y, note.noteID);
									noteSplash.cameras = [otherCam];
									add(noteSplash);
								}
						} // switch cases are better in this case
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

					if(player != null && player.active)
					{
						player.holdTimer = 0;
						player.playAnim(singAnims[note.noteID % 4], true);
					}

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

						var theReal:Array<Dynamic> = menus.HitsoundMenu.getHitsounds();
						if(theReal[Options.getData('hitsound')].name != "None")
						{
							playCurrentHitsound();
						}

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
		
					if(player != null && player.active)
					{
						player.holdTimer = 0;
						player.playAnim(singAnims[i] + "miss", true);
					}

					FlxG.random.getObject(missSounds).play(true);
		
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
					if(pressed[note.noteID] && Conductor.songPosition >= (!note.isSustainNote ? note.strum : note.strum - (Conductor.safeZoneOffset / 2)))
					{
						hits += 1;
						funnyHitStuffsLmao += 1;
						totalNoteStuffs++;
						score += 25;

						changeHealth(true);

						if(player != null && player.active)
						{
							player.holdTimer = 0;
							player.playAnim(singAnims[note.noteID % 4], true);
						}

						playerStrumArrows.members[note.noteID].playAnim("confirm", true);

						note.active = false;
						notes.remove(note);
						note.kill();
						note.destroy();
					}
				}
			}
		}

		if(player != null && player.active && (player.holdTimer > Conductor.stepCrochet * 4 * 0.001 && !pressed.contains(true)))
			if(player.animation.curAnim.name.startsWith('sing'))
				player.dance();
	}

	function playCurrentHitsound(?volume:Float = 1)
	{
		var hitsoundList:Dynamic = menus.HitsoundMenu.getHitsounds();

		var hitSound:FlxSound;

		hitSound = FlxG.sound.load(Util.getSound('gameplay/hitsounds/${hitsoundList[Options.getData('hitsound')].fileName}'), volume);

		hitSound.play(true);
	}

	function updateAccuracyStuff()
	{
		if(hits > 0)
		{
			if(Options.getData('botplay') || rating1 == "N/A")
				accuracyNum == 100;
			
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
			{
				rating2 = swagRatings[4];
				scoreBar.color = 0xFF4895fa;
			}
			else if (misses == 0 && goods >= 1 && bads == 0 && shits == 0)
			{
				rating2 = swagRatings[3];
				scoreBar.color = 0xFF48fa72;
			}
			else if (misses == 0)
			{
				rating2 = swagRatings[2];
				scoreBar.color = 0xFFfa9e48;
			}
			else if (misses < 10)
			{
				rating2 = swagRatings[1];
				scoreBar.color = 0xFFfa485a;
			}
			else
			{
				rating2 = swagRatings[0];
				scoreBar.color = 0xFF9e9697;
			}
		}
	}

	function processAchievements()
	{ // TODO: add shit to make custom achievements a thing
		fromAch = true;

		var listOfNewAchievements:Array<String> = [];

		// add achievements here
		if(storedSong == "tutorial" && storyMode)
		{
			if(getAchievement("tutorial") == true)
				listOfNewAchievements.push("tutorial");
		}
		// don't modify shit below

		if(FlxG.sound.music != null)
			FlxG.sound.music.pause();

		if(vocals != null)
			vocals.pause();

		persistentUpdate = false;

		paused = true;

		if(TitleScreenState.optionsInitialized)
			Controls.refreshControls();

		Controls.accept = false;

		openSubState(new AchievementThing(listOfNewAchievements));
	}

	function getAchievement(achievement:String):Bool
	{
		var funnyList:Array<String> = Options.getData("achievements");

		if(!funnyList.contains(achievement))
		{
			funnyList.push(achievement);
			Options.saveData("achievements", funnyList);

			return true;
		}

		Options.saveData("achievements", funnyList);

		return false;
	}
}