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
		super.create();
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
	}
}
