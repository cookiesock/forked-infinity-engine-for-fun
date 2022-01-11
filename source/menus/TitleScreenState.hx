package menus;

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
	var accepted:Bool = false; // controls the ability to spam enter lol

	override public function create():Void
	{
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

		/*var sprite = new FlxSprite();
		sprite.makeGraphic(15, 15, FlxColor.TRANSPARENT);
		sprite.drawCircle();
		FlxG.mouse.load(sprite.pixels);*/

		//k but what if no, the cursor shouldn't have to be a circle ldkskl

		Options.init();
		Mods.init();
		
		persistentUpdate = true;
		persistentDraw = true;

		FlxG.fixedTimestep = false;
		
		if(!hasAlreadyAccepted) {
			FlxG.sound.playMusic(Util.getSound("menus/freakyMenu", false), 0);
			FlxG.sound.music.fadeIn(4, 0, 0.7);
		}

		logo = new FlxSprite(25, 1000);
		logo.frames = Util.getSparrow('titlescreen/logoBumpin');
		logo.animation.addByPrefix('idle', 'logo bumpin', 24, true);
		logo.animation.play('idle');
		logo.antialiasing = true;
		add(logo);

		gf = new FlxSprite(750, 1500);
		gf.frames = Util.getSparrow('titlescreen/titleGF');
		gf.animation.addByPrefix('idle', 'titleGF', 24, true);
		gf.animation.play('idle');
		gf.antialiasing = true;
		add(gf);

		pressAccept = new FlxSprite();
		pressAccept.frames = Util.getSparrow('titlescreen/titleEnter');
		pressAccept.animation.addByPrefix('idle', 'Press Enter to Begin', 24, true);
		pressAccept.animation.addByPrefix('pressed', 'ENTER PRESSED', 24, true);
		pressAccept.animation.play('idle');
		pressAccept.screenCenter(X);
		pressAccept.y = FlxG.height - 145;
		pressAccept.antialiasing = true;
		add(pressAccept);

		#if debug
		add(new AlphabetText(0, 100, '"the quick brown fox jumps \nover the lazy dog"\n\n1234567890\n\n!?.-+()*><&_\'', 35));
		#end

		/*#if desktop
		Application.current.onExit.add(function (exitCode) {
			Options.saveSettings();
			trace("GAME CLOSED WITH CODE: " + exitCode);
		});
		#end*/

		if(Options.getData('volume') != null)
			FlxG.sound.volume = Options.getData('volume');

		BasicState.changeAppTitle(Util.engineName, "Title Screen");

		super.create();
	}

	override public function update(elapsed:Float):Void
	{
		if (FlxG.keys.justPressed.ENTER && !accepted || Util.mouseOverlappingSprite(pressAccept) && FlxG.mouse.justPressed)
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

		logo.y = FlxMath.lerp(logo.y, 50, Math.max(0, Math.min(1, elapsed * 3)));
		gf.y = FlxMath.lerp(gf.y, 200, Math.max(0, Math.min(1, elapsed * 3)));
		
		super.update(elapsed);
	}
}

