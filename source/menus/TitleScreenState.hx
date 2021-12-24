package menus;

import ui.AlphabetText;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.math.FlxMath;
import flixel.util.FlxTimer;

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

		add(new AlphabetText(0, 0, true, "the quick brown fox jumps over the lazy dog\n1234567890\n!?.-"));

		super.create();
	}

	override public function update(elapsed:Float):Void
	{
		if (FlxG.keys.justPressed.ENTER && !accepted)
		{
			FlxG.sound.play(Util.getSound("menus/confirmMenu", true));
			hasAlreadyAccepted = true; // prevents title music from restarting if it's already playing
			accepted = true; // prevents spamming enter
			// there's probably a better way to do this but i don't give a shi

			pressAccept.animation.play('pressed');
			FlxG.camera.flash(FlxColor.WHITE, 2);

			new FlxTimer().start(2, function(tmr:FlxTimer)
			{
				FlxG.switchState(new MainMenuState());
			});
		}

		logo.y = FlxMath.lerp(logo.y, 100, Math.max(0, Math.min(1, elapsed * 3)));
		gf.y = FlxMath.lerp(gf.y, 250, Math.max(0, Math.min(1, elapsed * 3)));
		
		super.update(elapsed);
	}
}

