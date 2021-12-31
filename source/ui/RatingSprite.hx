package ui;

import flixel.FlxSprite;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

class RatingSprite extends FlxSprite
{
	var stupidY:Float = 0;
	var dumbPath:String = 'normal/';

	public function new(x, y)
	{
		stupidY = y;
		super(x, y);
		antialiasing = true;

		loadRating('sick');
	}

	public function loadRating(daRating:String = 'sick')
	{
		if(game.PlayState.pixelStage)
			dumbPath = 'pixel/';
		else
			dumbPath = 'normal/';

		loadGraphic(Util.getImage('ratings/' + dumbPath + daRating));

		if(game.PlayState.pixelStage)
			setGraphicSize(Std.int(this.width * game.PlayState.pixelAssetZoom * 0.7));
		else
			setGraphicSize(Std.int(this.width * 0.7));

		updateHitbox();
	}

	public function tweenRating()
	{
		FlxTween.cancelTweensOf(this);
		y = stupidY;
		alpha = 1;
		FlxTween.tween(this, {y: this.y - 25}, 0.4, {
			ease: FlxEase.cubeOut,
			onComplete: function(twn:FlxTween)
			{
				// this probably won't work
				FlxTween.tween(this, {alpha: 0}, 0.4, {
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
