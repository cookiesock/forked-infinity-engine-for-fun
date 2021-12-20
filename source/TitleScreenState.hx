package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.util.FlxTimer;

class TitleScreenState extends BPMState
{
	var logo:FlxSprite;

	override public function create():Void
	{
		// var BPM = new BPMHandle(102, new TitleScreenState()); fix later lmao
		logo.frames = FlxAtlasFrames.fromSparrow("assets/images/logoBumpin.png", "assets/images/Start_Screen_Assets.xml");
		// logo.frames = FlxAtlasFrames.fromSparrow("assets/images/logoZon.png","assets/images/logoZon.xml"); // replace the other one with this for mine :) -- ZonianDX
		logo.animation.addByPrefix('idle', 'logo bumpin', 24, false);
		// logo.setGraphicSize(Std.int(logo.width - logo.width * 0.25));
		// logo.animation.addByPrefix('idle', 'logo bumping lma', 24, true);
		logo = new FlxSprite();
		logo.screenCenter();
		logo.animation.play('idle');
		add(logo);
		var pressAccept = new FlxSprite();
		pressAccept.frames = FlxAtlasFrames.fromSparrow("assets/images/titleEnter.png", "assets/images/titleEnter.xml");
		pressAccept.animation.addByPrefix('idle', 'Press Enter to Begin', 24, true);
		pressAccept.screenCenter(X);
		pressAccept.y = FlxG.height - 140;
		pressAccept.animation.addByPrefix('pressed', 'ENTER PRESSED', 24, true);
		pressAccept.animation.play('idle');
		add(pressAccept);
		super.create();
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		if (FlxG.keys.pressed.ENTER || FlxG.keys.pressed.SPACE) {}
	}
}
