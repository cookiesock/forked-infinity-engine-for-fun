package ui;

import flixel.FlxSprite;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxG;

class ComboSprite extends FlxSprite
{
	public var stupidY:Float = 0;
	var dumbPath:String = 'normal/';
	var isComboText:Bool = false;

	public function new(?x = 0, ?y = 0, ?isComboTextB:Bool = false)
	{
		stupidY = y;
		isComboText = isComboTextB;
		super(x, y);
		if(!game.PlayState.pixelStage)
			antialiasing = Options.getData('anti-aliasing');
		else
			antialiasing = false;

		loadCombo('0');
	}

	public function loadCombo(daCombo:String = '0')
	{
		if(game.PlayState.pixelStage)
			dumbPath = 'pixel/';
		else
			dumbPath = 'normal/';

		loadGraphic(Util.getImage('ratings/' + dumbPath + 'num' + daCombo));

		if(game.PlayState.pixelStage)
			setGraphicSize(Std.int(this.width * game.PlayState.pixelAssetZoom * 0.95));
		else
			setGraphicSize(Std.int(this.width * 0.7));

		updateHitbox();
	}

	public function tweenSprite()
	{
		var random1:Float = FlxG.random.float(0.2, 0.6);
		var random2:Float = FlxG.random.float(20, 30);

		FlxTween.cancelTweensOf(this);
		y = stupidY;
		alpha = 1;
		FlxTween.tween(this, {y: this.y - random2}, random1, {
			ease: FlxEase.cubeOut,
			onComplete: function(twn:FlxTween)
			{
				// this probably won't work
				FlxTween.tween(this, {alpha: 0}, random1, {
					ease: FlxEase.cubeInOut,
					onComplete: function(twn:FlxTween)
					{
						// do nothign because uhsdcjnkALehds
					}
				});

			}
		});
	}
}
