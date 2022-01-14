package ui;

import game.PlayState;
import flixel.FlxG;
import flixel.FlxSprite;

class DialogueBox extends FlxSprite
{
	var dialogueType:String = 'normal';

	public function new(x, y)
	{
		super(x, y);
		frames = Util.getSparrow('speech_bubble_talking');
		animation.addByPrefix('open', 'Speech Bubble Normal Open', 12, false);
		animation.addByPrefix('idle', 'speech bubble normal', 24, true);
		animation.addByPrefix('loud', 'AHH speech bubble', 24, true);
		animation.play('open');

		antialiasing = Options.getData('anti-aliasing');
	}

	override function update(elapsed:Float)
	{
		if(animation.curAnim.name == 'open' && animation.curAnim.finished)
			animation.play('idle', true);

		if(FlxG.keys.justPressed.SPACE)
		{
			kill();
			destroy();
		}

		super.update(elapsed);
	}
}
