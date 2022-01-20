package ui;

import flixel.FlxSprite;

class NoteSplash extends FlxSprite
{
	var directions:Array<String> = ['left', 'down', 'up', 'right'];
	var splashTexturePath:String = "";
	var noteID:Int = 0;
	var doingThe:Bool = false;

	public function new(x, y, noteID:Int = 0)
	{
		super(x, y);
		antialiasing = Options.getData('anti-aliasing');
		this.noteID = noteID;
		alpha = 0.6;
		doSplash();
	}

	public function doSplash()
	{
		var theFunny:String = 'note splash ' + directions[noteID % 4];
		frames = game.PlayState.noteSplashFrames;
		animation.addByPrefix('splash', theFunny + "0", 35, false);
		animation.play('splash');
		doingThe = true;

		setGraphicSize(Std.int(this.width * 0.8));

		updateHitbox();
		centerOrigin();
		centerOffsets();
		offset.set(120 * 1.1, 120 * 1.2);
	}

	override function update(elapsed:Float)
	{
		if(animation.curAnim.finished && doingThe)
			kill();

		super.update(elapsed);
	}
}
