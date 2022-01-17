package menus;

import game.Conductor;
import openfl.system.System;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.graphics.FlxGraphic;
import flixel.addons.transition.TransitionData;
import flixel.addons.transition.FlxTransitionableState;
import lime.app.Application;
import mods.Mods;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxMath;
import flixel.util.FlxTimer;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import DiscordRPC;

using flixel.util.FlxSpriteUtil;

// no raf i don't fucking know what "from scratch" means - swordcube
class TitleScreenState extends BasicState
{
	// regular vars
	var logo:FlxSprite;
	var gf:FlxSprite;
	var pressAccept:FlxSprite;
	
	// static vars
	static public var hasAlreadyAccepted:Bool = false; // controls music
	static public var optionsInitialized:Bool = false;
	var accepted:Bool = false; // controls the ability to spam enter lol

	var boppedLeft:Bool = false;

	override public function create():Void
	{
		super.create();

		funkyBpm(102);

		optionsInitialized = false;

		var diamond:FlxGraphic = FlxGraphic.fromClass(GraphicTransTileDiamond);
		diamond.persist = true;
		diamond.destroyOnNoUse = false;
		
		FlxTransitionableState.defaultTransIn = new TransitionData(FADE, FlxColor.BLACK, 1, new FlxPoint(0, -1), {asset: diamond, width: 32, height: 32},
		new FlxRect(-200, -200, FlxG.width * 1.4, FlxG.height * 1.4));
		FlxTransitionableState.defaultTransOut = new TransitionData(FADE, FlxColor.BLACK, 0.7, new FlxPoint(0, 1),
		{asset: diamond, width: 32, height: 32}, new FlxRect(-200, -200, FlxG.width * 1.4, FlxG.height * 1.4));

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		FlxTransitionableState.skipNextTransIn = true;
		FlxTransitionableState.skipNextTransOut = true;

		Options.init();
		Mods.init();
		optionsInitialized = true;
		
		persistentUpdate = true;
		persistentDraw = true;

		FlxG.fixedTimestep = false;
		
		if(!hasAlreadyAccepted) {
			FlxG.sound.playMusic(Util.getSound("menus/freakyMenu", false), 0);
			FlxG.sound.music.fadeIn(4, 0, 0.7);
		}

		gf = new FlxSprite(FlxG.width * 0.4, 2000);
		gf.frames = Util.getSparrow('titlescreen/titleGF');
		gf.animation.addByIndices('danceLeft', 'gfDance', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
		gf.animation.addByIndices('danceRight', 'gfDance', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
		gf.animation.play('danceLeft');
		gf.antialiasing = Options.getData('anti-aliasing');
		add(gf);

		if(Options.getData('engine-watermarks'))
		{
			logo = new FlxSprite(-90, 1000);
			logo.frames = Util.getSparrow('titlescreen/logoBumpinInfinity');
		}
		else
		{
			logo = new FlxSprite(-90, 1000);
			logo.frames = Util.getSparrow('titlescreen/logoBumpin');
		}
		
		logo.animation.addByPrefix('idle', 'logo bumpin', 24, false);
		logo.animation.play('idle');
		logo.antialiasing = Options.getData('anti-aliasing');
		add(logo);

		pressAccept = new FlxSprite();
		pressAccept.frames = Util.getSparrow('titlescreen/titleEnter');
		pressAccept.animation.addByPrefix('idle', 'Press Enter to Begin', 24, true);
		pressAccept.animation.addByPrefix('pressed', 'ENTER PRESSED', 24, true);
		pressAccept.animation.play('idle');
		pressAccept.screenCenter(X);
		pressAccept.y = FlxG.height - 145;
		pressAccept.antialiasing = Options.getData('anti-aliasing');
		add(pressAccept);

		#if debug
		add(new AlphabetText(0, 100, '"the quick brown fox jumps \nover the lazy dog"\n\n1234567890\n\n!?.-+()*><&_\'', 35));
		#end

		#if discord_rpc
		if(!DiscordRPC.started && Options.getData("discord-rpc"))
			DiscordRPC.initialize();

		Application.current.onExit.add(function (exitCode) {
			DiscordRPC.shutdown();
		}, false, 100);
		#end

		if(Options.getData('volume') != null)
			FlxG.sound.volume = Options.getData('volume');

		BasicState.changeAppTitle(Util.engineName, "Title Screen");
	}

	override public function update(elapsed:Float):Void
	{
		if (Controls.accept && !accepted || Util.mouseOverlappingSprite(pressAccept) && FlxG.mouse.justPressed)
		{
			FlxG.sound.play(Util.getSound("menus/confirmMenu", true));
			hasAlreadyAccepted = true; // prevents title music from restarting if it's already playing
			accepted = true; // prevents spamming enter
			FlxTransitionableState.skipNextTransIn = false;
			FlxTransitionableState.skipNextTransOut = false;

			pressAccept.animation.play('pressed');
			FlxG.camera.flash(FlxColor.WHITE, 2);

			new FlxTimer().start(2, function(tmr:FlxTimer)
			{
				transitionState(new MainMenuState());
			});
		}

		logo.y = FlxMath.lerp(logo.y, -100, Math.max(0, Math.min(1, elapsed * 3)));
		gf.y = FlxMath.lerp(gf.y, FlxG.height * 0.07, Math.max(0, Math.min(1, elapsed * 3)));
		
		Conductor.songPosition = FlxG.sound.music.time;

		super.update(elapsed);
	}

	override public function beatHit()
	{
		super.beatHit();

		logo.animation.play('idle');

		if(!boppedLeft)
			gf.animation.play('danceLeft');
		else
			gf.animation.play('danceRight');

		boppedLeft = !boppedLeft;
	}
}

