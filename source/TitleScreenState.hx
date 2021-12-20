package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.util.FlxTimer;

class TitleScreenState extends FlxState
{
	public var logo:FlxSprite = new FlxSprite();
	public var pressAccept = new FlxSprite();
	
	override public function create():Void
	{
		logo.frames = Paths.getSparrowAtlas('logoBumpin');
		logo.animation.addByPrefix('idle', 'logo bumpin', 24, true);
		logo.screenCenter(X);
		logo.y = 55;
		add(logo);
		
		pressAccept.frames = Paths.getSparrowAtlas('titleEnter');
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
		if(FlxG.keys.justPressed.ENTER)
		{
			FlxG.switchState(new PlayState());
		}
		super.update(elapsed);
	}
}
