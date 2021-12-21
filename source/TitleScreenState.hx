package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxMath;
import flixel.util.FlxTimer;

/*import flixel.group.FlxGroup;
	import flixel.input.gamepad.FlxGamepad;
	import flixel.input.keyboard.FlxKey;
	import flixel.system.FlxSound;
	import flixel.text.FlxText;
	import flixel.tweens.FlxTween;
	import flixel.util.FlxColor;
	import lime.app.Application;
	import openfl.Assets; */
class TitleScreenState extends FlxState
{
	var logo:FlxSprite;
	var gf:FlxSprite;
	var pressAccept:FlxSprite;

	override public function create():Void
	{
		FlxG.sound.playMusic('assets/music/freakyMenu');
		FlxG.sound.music.fadeIn(4, 0, 0.7);

		logo = new FlxSprite(25, 1000);
		logo.frames = FlxAtlasFrames.fromSparrow('assets/images/logoBumpin.png', 'assets/images/logoBumpin.xml');
		logo.animation.addByPrefix('idle', 'logo bumpin', 24, true);
		logo.animation.play('idle');
		add(logo);

		gf = new FlxSprite(750, 1000);
		gf.frames = FlxAtlasFrames.fromSparrow('assets/images/titleGF.png', 'assets/images/titleGF.xml');
		gf.animation.addByPrefix('idle', 'titleGF', 24, true);
		gf.animation.play('idle');
		add(gf);

		pressAccept = new FlxSprite();
		pressAccept.frames = FlxAtlasFrames.fromSparrow('assets/images/titleEnter.png', 'assets/images/titleEnter.xml');
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
			new FlxTimer().start(1, function(tmr:FlxTimer)
			{
				FlxG.switchState(new PlayState());
			});
		}

		logo.y = FlxMath.lerp(logo.y, 100, Math.max(0, Math.min(1, elapsed * 3)));
		gf.y = FlxMath.lerp(gf.y, 250, Math.max(0, Math.min(1, elapsed * 3)));
		super.update(elapsed);
	}
}
