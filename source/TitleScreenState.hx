package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.graphics.frames.FlxAtlasFrames;

class TitleScreenState extends FlxState
{
	override public function create():Void
	{
		var logo = new FlxSprite();
		logo.frames = FlxAtlasFrames.fromSparrow("assets/images/logoBumpin.png", "assets/images/logoBumpin.xml");
		logo.animation.addByPrefix('idle', 'logo bumpin', 24, true);
		logo.animation.play('idle');
		add(logo);
		var pressAccept = new FlxSprite();
		pressAccept.frames = FlxAtlasFrames.fromSparrow("assets/images/titleEnter.png", "assets/images/titleEnter.xml");
		pressAccept.animation.addByPrefix('idle', 'Press Enter to Begin', 24, true);
		pressAccept.animation.addByPrefix('pressed', 'ENTER PRESSED', 24, true);
		pressAccept.animation.play('idle');
		add(pressAccept);
		super.create();
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
	}
}
