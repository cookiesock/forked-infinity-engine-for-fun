package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxMath;
import flixel.util.FlxTimer;

// no raf i don't fucking know what "from scratch" means - swordcube

class TitleScreenState extends FlxState
{
	var logo:FlxSprite;
	var gf:FlxSprite;
	var pressAccept:FlxSprite;

	override public function create():Void
	{	
		// can someone please tell me if this shit works the music doesn't play for me
		// i even tried replacing this with assets/music/freakyMenu
		// and even just freakyMenu but nothing works :grief:
		FlxG.sound.playMusic(SwagUtilShit.getSound('assets/music/', 'freakyMenu'));
		FlxG.sound.music.fadeIn(4, 0, 0.7);

		logo = new FlxSprite(25, 1000);
		logo.frames = SwagUtilShit.getSparrow('assets/images/', 'logoBumpin');
		logo.animation.addByPrefix('idle', 'logo bumpin', 24, true);
		logo.animation.play('idle');
		add(logo);

		gf = new FlxSprite(750, 1000);
		gf.frames = SwagUtilShit.getSparrow('assets/images/', 'titleGF');
		gf.animation.addByPrefix('idle', 'titleGF', 24, true);
		gf.animation.play('idle');
		add(gf);

		pressAccept = new FlxSprite();
		pressAccept.frames = SwagUtilShit.getSparrow('assets/images/', 'titleEnter');
		pressAccept.animation.addByPrefix('idle', 'Press Enter to Begin', 24, true);
		pressAccept.animation.addByPrefix('pressed', 'ENTER PRESSED', 24, true);
		pressAccept.animation.play('idle');
		pressAccept.screenCenter(X);
		pressAccept.y = FlxG.height - 145;
		add(pressAccept);

		super.create();
	}

	override public function update(elapsed:Float):Void
	{
		if (FlxG.keys.justPressed.ENTER)
		{
			pressAccept.animation.play('pressed');
			new FlxTimer().start(2, function(tmr:FlxTimer)
			{
				FlxG.switchState(new PlayState());
			});
		}

		logo.y = FlxMath.lerp(logo.y, 100, Math.max(0, Math.min(1, elapsed * 3)));
		gf.y = FlxMath.lerp(gf.y, 250, Math.max(0, Math.min(1, elapsed * 3)));
		super.update(elapsed);
	}
}

