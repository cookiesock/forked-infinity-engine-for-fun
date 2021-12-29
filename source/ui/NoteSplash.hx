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
		this.noteID = noteID;
		alpha = 0.6;
		doSplash();
	}

	public function doSplash()
	{
		var theFunny:String = 'note splash ' + directions[noteID % 4];
		frames = Util.getSparrow('noteskins/' + game.PlayState.song.ui_Skin + '/noteSplashes');
		animation.addByPrefix('splash', theFunny, 30, false);
		animation.play('splash');
		doingThe = true;

		//setGraphicSize(Std.int(this.width * 1));

		updateHitbox();
		centerOrigin();
		centerOffsets();
		offset.set(120, 120);
	}

	override function update(elapsed:Float)
	{
		if(animation.curAnim.finished && doingThe)
			kill();

		super.update(elapsed);
	}
}
